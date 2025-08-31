defmodule GoatmireWeb.HomeLive do
  use GoatmireWeb, :live_view

  alias Goatmire.Media

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="container py-24 mx-auto">
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
              <.input field={f[:alt_text]} label="Image description (alt text)" phx-debounce="blur" />
              <.input
                type="checkbox"
                field={f[:accept_terms]}
                label="I understand that files uploaded here will be publicly accessible and agree to their use"
              />
              <.button class="btn btn-primary w-full">Upload</.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    changeset = Media.change_image(%Media.Image{})

    socket =
      socket
      |> assign(form: to_form(changeset))
      |> allow_upload(:image, accept: ~w(.jpg .jpeg .png), external: &presign_upload/2)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"image" => upload_params}, socket) do
    changeset = Media.change_image(%Media.Image{}, upload_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("submit", %{"image" => _upload_params}, socket) do
    {:noreply, put_flash(socket, :error, "NOT IMPLEMENTED")}
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

  def bucket, do: Application.get_env(:ex_aws, :s3) |> Keyword.fetch!(:bucket)
end
