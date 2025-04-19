defmodule LivekwestWeb.ControlLive do
  use LivekwestWeb, :live_view

  import Livekwest.Utils, only: [topic: 1]

  alias Livekwest.QuizManager
  alias Phoenix.PubSub

  @questions [
    ~s(Which country hosted the first Winter Olympic Games after World War II?),
    ~s(What countries were involved in the Wars of the Three Kingdoms?),
    ~s(Which conflict ended with the "Good Friday Agreement"?),
    ~s(What was the first live-stream video on the internet?),
    ~s(What was Che Guevara's real first name?),
    ~s(Who was America's first billionaire?),
    ~s(In what century did the Dodo become extinct?),
    ~s(What year was construction of the Sistine Chapel completed in?)
  ]

  def mount(_params, _session, socket) do
    code = :rand.uniform(99999) |> Integer.to_string() |> String.pad_leading(5, "0")
    topic = topic(code)

    PubSub.subscribe(Livekwest.PubSub, topic)
    QuizManager.init_quiz(code, @questions)

    {:ok,
     socket
     |> assign(:code, code)
     |> assign(:participants, [])
     |> assign(:current_index, 0)
     |> assign(:current_question, nil)
     |> assign(:started?, false)}
  end

  def handle_event("start_quiz", _, socket) do
    QuizManager.start_quiz(socket.assigns.code)

    {:noreply, assign(socket, :started?, true)}
  end

  def handle_event("next_question", _, socket) do
    next_index = socket.assigns.current_index + 1
    QuizManager.set_active_question(socket.assigns.code, next_index)
    {:noreply, assign(socket, :current_index, next_index)}
  end

  def handle_event("prev_question", _, socket) do
    prev_index = max(socket.assigns.current_index - 1, 0)
    QuizManager.set_active_question(socket.assigns.code, prev_index)
    {:noreply, assign(socket, :current_index, prev_index)}
  end

  def handle_event("remove_participant", %{"id" => id}, socket) do
    QuizManager.remove_participant(socket.assigns.code, id)

    {:noreply, socket}
  end

  def handle_info(:quiz_started, socket) do
    question = QuizManager.get_active_question(socket.assigns.code)

    {:noreply,
     socket
     |> assign(:current_question, question)
     |> assign(:started, true)}
  end

  def handle_info({:active_question_changed, question}, socket) do
    {:noreply, assign(socket, :current_question, question)}
  end

  def handle_info(:participants_updated, socket) do
    participants = QuizManager.get_participants(socket.assigns.code)
    {:noreply, assign(socket, :participants, participants)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "#{__MODULE__} | Unhandled PubSub message")
    {:noreply, socket}
  end
end
