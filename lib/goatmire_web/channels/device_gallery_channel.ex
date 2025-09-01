defmodule GoatmireWeb.DeviceGalleryChannel do
  use GoatmireWeb, :channel

  @impl true
  def join("device_gallery:lobby", payload, socket) do
    if authorized?(payload) do
      Phoenix.PubSub.subscribe(Goatmire.PubSub, "device_gallery")

      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (device_gallery:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:gallery_image, image}, socket) do
    IO.inspect(image, label: "GALLERY IMAGE FOR DEVICE CHANNEL")

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
