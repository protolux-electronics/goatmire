defmodule GoatmireWeb.GalleryLive do
  use GoatmireWeb, :live_view

  alias Goatmire.Media

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="w-full grid grid-cols-3 gap-4">
        <img
          :for={{dom_id, image} <- @streams.images}
          id={dom_id}
          src={presigned_url(image.thumbnail_key)}
          alt={image.alt_text}
          class="rounded shadow"
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    images = Media.list_approved_images()
    socket = stream(socket, :images, images)

    {:noreply, socket}
  end

  defp presigned_url(key) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket(), key)
    |> case do
      {:ok, url} -> url
      _ -> nil
    end
  end

  defp bucket, do: Application.get_env(:ex_aws, :s3) |> Keyword.fetch!(:bucket)
end
