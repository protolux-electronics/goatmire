defmodule GoatmireWeb.HomeLive do
  use GoatmireWeb, :live_view

  alias Goatmire.Media

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="card card-border card-lg bg-base-100 shadow-sm">
        <div class="card-body space-y-4">
          <div>
            <div class="card-title">Upload an image</div>
            <p class="text-sm text-neutral/50">
              Images will be center cropped with a 4:3 aspect ratio
            </p>
          </div>

          <.form
            :let={f}
            for={@form}
            phx-change="validate"
            phx-submit="submit"
            phx-debounce="blur"
            class="space-y-4"
          >
            <div
              phx-drop-target={@uploads.image.ref}
              class="flex flex-col items-center justify-center w-full p-8 rounded-lg border border-dashed border-neutral/50"
            >
              <.icon name="hero-arrow-up-circle text-neutral/50 mb-4" class="w-10 h-10" />

              <p class="">Drag and drop here</p>
              <p class="divider w-32 mx-auto">or</p>

              <label class="btn btn-soft">
                Select from device <.live_file_input upload={@uploads.image} class="hidden" />
              </label>
            </div>
            <div
              :for={entry <- @uploads.image.entries}
              class="flex rounded-lg border border-neutral/20 p-4 gap-4"
            >
              <.live_img_preview entry={entry} class="h-14 rounded" />

              <div class="w-full flex flex-col gap-4">
                <div class="w-full flex justify-between">
                  <span>{entry.client_name}</span>
                  <span>{Float.round(entry.client_size / 1_000_000, 1)} MB</span>
                </div>

                <progress value={entry.progress} max="100" class="progress progress-secondary">
                  {entry.progress}%
                </progress>
              </div>
            </div>
            <.input
              field={f[:alt_text]}
              label="Image description (alt text)"
              phx-debounce="blur"
              required
            />
            <.input
              type="checkbox"
              field={f[:accept_terms]}
              label="I understand that files uploaded here will be publicly accessible and agree to their use"
            />
            <.button class="btn btn-primary w-full">Upload</.button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = Media.Image.new_changeset(%Media.Image{}, %{})

    socket =
      socket
      |> assign(form: to_form(changeset))
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), external: &presign_upload/2)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"image" => params}, socket) do
    changeset = Media.Image.new_changeset(%Media.Image{}, params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("submit", %{"image" => params}, socket) do
    with {:ok, _image} <-
           Media.Image.new_changeset(%Media.Image{}, params)
           |> Ecto.Changeset.apply_action(:insert),
         {:ok, s3_key} <- consume_s3_entry(socket),
         {:ok, _image} <-
           Map.put(params, "s3_key", s3_key)
           |> Media.create_and_process_image() do
      socket =
        socket
        |> put_flash(:success, "Image was uploaded and pending moderation")
        |> push_navigate(to: "/gallery")

      {:noreply, socket}
    else
      {:error, :no_uploads} ->
        {:noreply, put_flash(socket, :error, "Please select a file for upload")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
    end
  end

  def presign_upload(entry, socket) do
    config = ExAws.Config.new(:s3)
    key = "images/#{entry.uuid}/#{entry.client_name}"

    {:ok, url} =
      ExAws.S3.presigned_url(config, :put, bucket(), key,
        expires_in: 3600,
        query_params: [{"Content-Type", entry.client_type}]
      )

    {:ok, %{uploader: "S3", key: key, url: url}, socket}
  end

  defp consume_s3_entry(socket) do
    consume_uploaded_entries(socket, :image, fn %{key: key}, _entry -> {:ok, key} end)
    |> case do
      [] -> {:error, :no_uploads}
      [s3_key] -> {:ok, s3_key}
    end
  end
end
