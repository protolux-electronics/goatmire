defmodule GoatmireWeb.SurveyLive do
  use GoatmireWeb, :live_view

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="card card-border card-lg bg-base-100 shadow-sm">
        <div class="card-body space-y-4">
          <div>
            <div class="card-title">Ask a survey question</div>
            <p class="text-sm text-neutral/50">
              Pick a question, any question...
            </p>
          </div>

          <.form
            :let={f}
            for={to_form(@survey, as: :survey)}
            phx-submit="submit"
            class="space-y-4"
          >
            <.input
              field={f[:question]}
              label="Survey question"
              placeholder="Have you used Nerves before?"
              required
            />

            <button class="btn btn-primary w-full">Send</button>
          </.form>

          <div :for={question <- @questions}>
            <p>{question["text"]}</p>
            <div>Yes: {question["yes"]}</div>
            <div>No: {question["no"]}</div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(survey: %{}, questions: [])

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"survey" => %{"question" => question} = survey}, socket) do
    token =
      :crypto.strong_rand_bytes(20)
      |> Base.encode16()

    Registry.register(Goatmire.DeviceRegistry, token, nil)

    GoatmireWeb.Endpoint.broadcast!("survey", "question", %{token: token, question: question})

    new_questions = [
      %{"yes" => 0, "no" => 0, "text" => question, "id" => token} | socket.assigns.questions
    ]

    {:noreply, assign(socket, questions: new_questions, survey: survey)}
  end

  @impl true
  def handle_info({:update, token, response}, socket) do
    Logger.info("GOT UPDATE")

    updated_questions =
      Enum.map(socket.assigns.questions, fn
        %{"id" => ^token} = q -> Map.update(q, response, 0, &(&1 + 1))
        other -> other
      end)

    {:noreply, assign(socket, questions: updated_questions)}
  end
end
