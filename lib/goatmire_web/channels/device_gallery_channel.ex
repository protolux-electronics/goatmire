defmodule GoatmireWeb.DeviceGalleryChannel do
  use GoatmireWeb, :channel

  require Logger

  @impl true
  def join("device_gallery", payload, socket) do
    {:ok, socket}
  end
end
