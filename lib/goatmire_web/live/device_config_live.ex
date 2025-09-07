defmodule GoatmireWeb.DeviceConfigLive do
  use GoatmireWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="card card-border card-lg bg-base-100 shadow-sm">
        <div class="card-body space-y-4">
          <div>
            <div class="card-title">Adjust device settings</div>
            <p class="text-sm text-neutral/50">
              Press any button on the device to exit configuration mode
            </p>
          </div>

          <.form
            :let={f}
            for={to_form(@config, as: :config)}
            phx-submit="submit"
            phx-change="render_preview"
            class="space-y-4"
          >
            <fieldset class="fieldset px-2">
              <legend class="fieldset-legend">Name display settings</legend>
              <div class="px-2">
                <.input field={f[:first_name]} label="First Name" placeholder="Goat" required />
                <.input field={f[:last_name]} label="Last Name" placeholder="McMire" required />
                <.input
                  field={f[:name_size]}
                  type="number"
                  label="Font size"
                  min={12}
                  max={96}
                  step={4}
                />
              </div>
            </fieldset>

            <.input field={f[:greeting]} label="Greeting (optional)" placeholder="Hello! My name is" />
            <.input field={f[:company]} label="Company (optional)" />

            <fieldset class="fieldset px-2">
              <legend class="fieldset-legend">Preview</legend>
              <div class="px-2"></div>
            </fieldset>

            <button class="btn btn-primary">Apply</button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    token = Map.get(params, "token")

    case Registry.lookup(Goatmire.ConfigRegistry, token) do
      [{pid, params}] ->
        Process.monitor(pid)
        {:ok, assign(socket, token: token, config: params)}

      [] ->
        {:ok, socket |> put_flash(:error, "No device connected") |> push_navigate(to: "/gallery")}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, _object, _reason}, socket) do
    {:noreply,
     socket |> put_flash(:error, "Lost connection to device") |> push_navigate(to: "/gallery")}
  end

  @impl true
  def handle_event("render_preview", %{"config" => config}, socket) do
    {:noreply, assign(socket, config: config)}
  end

  @impl true
  def handle_event("submit", %{"config" => config}, socket) do
    GoatmireWeb.Endpoint.broadcast("config:" <> socket.assigns.token, "apply", config)

    {:noreply, assign(socket, config: config)}
  end
end
