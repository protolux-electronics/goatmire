defmodule GoatmireWeb.GalleryLive do
  use GoatmireWeb, :live_view

  alias Goatmire.Media

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex justify-between items-center">
        <div>Gallery</div>
        <div class="dropdown dropdown-end dropdown-hover">
          <div tabindex="0" role="button" class="btn m-1">Image Mode</div>
          <ul
            tabindex="0"
            class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm"
          >
            <li><.link patch={~p"/gallery"}>Color</.link></li>
            <li>
              <.link patch={~p"/gallery?#{[image_key: :dithered_key]}"}>Dithered B/W</.link>
            </li>
          </ul>
        </div>
      </div>

      <div id="images-grid" class="w-full grid grid-cols-3 gap-4" phx-update="stream">
        <img
          :for={{dom_id, image} <- @streams.images}
          id={dom_id}
          src={presigned_url(Map.get(image, @image_key))}
          alt={image.alt_text}
          class="rounded-lg shadow"
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Goatmire.PubSub, "gallery")

    images = Media.list_approved_images()

    socket =
      socket
      |> stream(:images, images)
      |> assign(image_key: image_key(params))

    {:noreply, socket}
  end

  @impl true
  def handle_info({:add_image, image}, socket) do
    socket = stream_insert(socket, :images, image, at: 0)

    {:noreply, socket}
  end

  defp image_key(%{"image_key" => "dithered_key"}), do: :dithered_key
  defp image_key(_params), do: :thumbnail_key
end
