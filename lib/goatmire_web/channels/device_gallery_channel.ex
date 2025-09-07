defmodule GoatmireWeb.DeviceGalleryChannel do
  use GoatmireWeb, :channel

  require Logger

  @impl true
  def join("device_gallery", _payload, socket) do
    {:ok, socket}
  end
end
