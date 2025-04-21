defmodule LivekwestWeb.ControlLive do
  use LivekwestWeb, :live_view

  import Livekwest.Utils, only: [topic: 1]

  alias Livekwest.Quizzes
  alias Livekwest.QuizManager
  alias Phoenix.PubSub

  on_mount LivekwestWeb.Utils.LiveAuth

  def mount(%{"id" => quiz_id}, _session, socket) do
    code = :rand.uniform(99999) |> Integer.to_string() |> String.pad_leading(5, "0")
    topic = topic(code)
    quiz = Quizzes.get_by([id: quiz_id, user_id: socket.assigns.current_user.id], [:questions])

    PubSub.subscribe(Livekwest.PubSub, topic)
    QuizManager.init_quiz(code, quiz.questions)

    {:ok,
     socket
     |> assign(:code, code)
     |> assign(:participants, [])
     |> assign(:current_index, 0)
     |> assign(:current_question, nil)
     |> assign(:started, false)}
  end

  def handle_event("start_quiz", _, socket) do
    QuizManager.start_quiz(socket.assigns.code)

    {:noreply, socket}
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
