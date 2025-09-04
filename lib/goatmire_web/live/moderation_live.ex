defmodule GoatmireWeb.ModerationLive do
  use GoatmireWeb, :live_view

  alias Goatmire.Media

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex justify-between items-center">
        <div>Moderation</div>
        <div class="dropdown dropdown-end dropdown-hover">
          <div tabindex="0" role="button" class="btn m-1">Image Mode</div>
          <ul
            tabindex="0"
            class="dropdown-content menu bg-base-100 rounded-box z-1 w-52 p-2 shadow-sm"
          >
            <li><.link patch={~p"/moderation"}>Color</.link></li>
            <li>
              <.link patch={~p"/moderation?#{[image_key: :dithered_key]}"}>Dithered B/W</.link>
            </li>
          </ul>
        </div>
      </div>

      <div id="moderation-stack" class="stack w-full" phx-update="stream">
        <div
          :for={{dom_id, image} <- @streams.moderation_queue}
          id={dom_id}
          class="flex justify-between gap-4 items-center first:[&>button]:visible [&>button]:invisible"
        >
          <button
            class="bg-error shadow p-2 text-white rounded-full cursor-pointer"
            phx-click="reject"
            phx-value-image_id={image.id}
          >
            <.icon name="hero-hand-thumb-down" class="w-8 h-8" />
          </button>
          <img
            src={presigned_url(Map.get(image, @image_key))}
            alt={image.alt_text}
            class="w-full rounded-lg shadow"
          />
          <button
            class="bg-success shadow p-2 text-white rounded-full cursor-pointer"
            phx-click="approve"
            phx-value-image_id={image.id}
          >
            <.icon name="hero-hand-thumb-up" class="w-8 h-8" />
          </button>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> assign(image_key: image_key(params))
      |> assign_moderation_queue()

    {:noreply, socket}
  end

  @impl true
  def handle_event("approve", %{"image_id" => image_id}, socket) do
    {:ok, image} =
      Media.get_image!(image_id)
      |> Media.approve_image()

    Phoenix.PubSub.broadcast(Goatmire.PubSub, "gallery", {:add_image, image})

    {:noreply, stream_delete(socket, :moderation_queue, image)}
  end

  @impl true
  def handle_event("reject", %{"image_id" => image_id}, socket) do
    {:ok, image} =
      Media.get_image!(image_id)
      |> Media.reject_image()

    {:noreply, stream_delete(socket, :moderation_queue, image)}
  end

  defp assign_moderation_queue(socket) do
    queue = Media.list_moderation_queue()

    stream(socket, :moderation_queue, queue)
  end

  defp image_key(%{"image_key" => "dithered_key"}), do: :dithered_key
  defp image_key(_params), do: :thumbnail_key
end
