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
                />
              </div>
            </fieldset>

            <fieldset class="fieldset px-2">
              <legend class="fieldset-legend">
                Greeting display settings (optional, rendered above your name)
              </legend>
              <div class="px-2">
                <.input
                  field={f[:greeting]}
                  label="Greeting"
                  placeholder="Hello! My name is"
                  required
                />
                <.input
                  field={f[:greeting_size]}
                  type="number"
                  label="Font size"
                  min={12}
                  max={96}
                />
              </div>
            </fieldset>

            <fieldset class="fieldset px-2">
              <legend class="fieldset-legend">
                Company display settings (optional, rendered below your name)
              </legend>
              <div class="px-2">
                <.input
                  field={f[:company]}
                  label="Company"
                  placeholder="Goatmire Inc."
                  required
                />
                <.input
                  field={f[:company_size]}
                  type="number"
                  label="Font size"
                  min={12}
                  max={96}
                />
              </div>
            </fieldset>

            <fieldset class="fieldset px-2">
              <legend class="fieldset-legend">
                Spacing settings (optional)
              </legend>
              <div class="px-2">
                <.input
                  field={f[:spacing]}
                  type="number"
                  label="Spacing"
                  min={12}
                  max={96}
                />
              </div>
            </fieldset>

            <fieldset class="fieldset px-2">
              <legend class="fieldset-legend">Preview</legend>
              <div class="px-2">
                <.async_result :let={preview} assign={@preview}>
                  <:loading>Loading preview...</:loading>
                  <:failed :let={_failure}>there was an error loading the preview</:failed>
                  <img
                    src={preview}
                    alt="Preview of the rendered content. If you see this, the template probably has an error"
                    class="w-full"
                  />
                </.async_result>
              </div>
            </fieldset>

            <button class="btn btn-primary w-full">Apply</button>
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
      [{pid, config}] ->
        Process.monitor(pid)

        config =
          config
          |> Map.put_new("name_size", 32)
          |> Map.put_new("greeting_size", 24)
          |> Map.put_new("company_size", 24)
          |> Map.put_new("spacing", 24)

        socket =
          socket
          |> assign(token: token, config: config)
          |> assign_async(:preview, fn -> {:ok, %{preview: render_config(config)}} end)

        {:ok, socket}

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
    socket =
      socket
      |> assign(config: config)
      |> assign_async(:preview, fn -> {:ok, %{preview: render_config(config)}} end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"config" => config}, socket) do
    GoatmireWeb.Endpoint.broadcast("config:" <> socket.assigns.token, "apply", config)

    socket =
      socket
      |> assign(config: config)
      |> put_flash(:success, "Configuration was applied")

    {:noreply, socket}
  end

  defp render_config(config) do
    button_hints = %{a: "Next", b: "Back"}

    greeting_element =
      case config["greeting"] do
        nil ->
          ""

        "" ->
          ""

        greeting when is_binary(greeting) ->
          "text(font: \"New Amsterdam\", size: #{config["greeting_size"]}pt)[#{greeting}],"
      end

    company_element =
      case config["company"] do
        nil ->
          ""

        "" ->
          ""

        company when is_binary(company) ->
          "text(font: \"New Amsterdam\", size: #{config["company_size"]}pt)[#{company}],"
      end

    """
    #set page(width: 400pt, height: 300pt, margin: 32pt);

    #place(
      top + right,
      dy: -24pt,
      dx: 24pt,
      box(height: 16pt, stack(dir: ltr, spacing: 8pt,
        image("images/icons/battery-50.png"), 
        image("images/icons/wifi.png"),
        image("images/icons/link.png"), 
      ))
    )

    #place(
      top + left,
      dx: -28pt,
      stack(dir: ttb, spacing: 16pt,
        circle(radius: 8pt, stroke: 1.25pt)[
          #set align(center + horizon)
          #text(size: 16pt, weight: "bold", font: "New Amsterdam", "A")
        ],
        circle(radius: 8pt, stroke: 1.25pt)[
          #set align(center + horizon)
          #text(size: 16pt, weight: "bold", font: "New Amsterdam", "B")
        ],
      )
    );

    #place(bottom + center, dy: 24pt,
      stack(dir: ltr, spacing: 20pt,
          stack(dir: ltr, spacing: 8pt,
            circle(radius: 8pt, stroke: 1.25pt)[
              #set align(center + horizon)
              #text(size: 16pt, weight: "bold", font: "New Amsterdam", "A")
            ],
            align(horizon, text(size: 20pt, font: "New Amsterdam", "#{button_hints.a}"))
          ),

          stack(dir: ltr, spacing: 8pt,
            circle(radius: 8pt, stroke: 1.25pt)[
              #set align(center + horizon)
              #text(size: 16pt, weight: "bold", font: "New Amsterdam", "B")
            ],
            align(horizon, text(size: 20pt, font: "New Amsterdam", "#{button_hints.b}"))
          )
      )
    );


    #place(center + horizon,
      stack(dir: ttb, spacing: #{config["spacing"]}pt,

        #{greeting_element}
        text(font: "New Amsterdam", size: #{config["name_size"]}pt, "#{config["first_name"]} #{config["last_name"]}"),
        #{company_element}
      )
    );
    """
    |> Typst.render_to_png([],
      root_dir: Application.app_dir(:goatmire, "priv/typst"),
      extra_fonts: [Application.app_dir(:goatmire, "priv/typst/fonts")]
    )
    |> case do
      {:ok, [png | _rest]} ->
        "data:image/png;base64,#{Base.encode64(png)}"

      {:error, reason} when is_binary(reason) ->
        IO.puts(reason)
        nil
    end
  end
end
