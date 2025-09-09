defmodule GoatmireWeb.SurveyChannel do
  use GoatmireWeb, :channel

  require Logger

  @impl true
  def join("survey", _params, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("response", %{"token" => token, "response" => response}, socket) do
    Logger.info("GOT A RESPONSE")

    case Registry.lookup(Goatmire.DeviceRegistry, token) do
      [{pid, _}] ->
        send(pid, {:update, token, response})

      [] ->
        :ok
    end

    {:noreply, socket}
  end
end
