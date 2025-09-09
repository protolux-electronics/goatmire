defmodule GoatmireWeb.DeviceConfigChannel do
  use GoatmireWeb, :channel

  require Logger

  @impl true
  def join("config:" <> token, params, socket) do
    Registry.register(Goatmire.DeviceRegistry, token, params)

    {:ok, socket}
  end
end
