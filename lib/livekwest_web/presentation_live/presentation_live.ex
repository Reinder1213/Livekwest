defmodule LivekwestWeb.PresentationLive do
  use LivekwestWeb, :live_view

  import Livekwest.Utils, only: [topic: 1]

  alias Livekwest.QuizManager
  alias Phoenix.PubSub

  def mount(%{"code" => code}, _session, socket) do
    topic = topic(code)
    PubSub.subscribe(Livekwest.PubSub, topic)

    quiz = QuizManager.get_quiz(code)
    participants = QuizManager.get_participants(code)
    question = QuizManager.get_active_question(code)

    {:ok,
     socket
     |> assign(:code, code)
     |> assign(:current_question, question)
     |> assign(:participants, participants)
     |> assign(:latest_participant, nil)
     |> assign(:started, quiz && quiz.started?)}
  end

  def handle_info({:new_participant, participant}, socket) do
    Process.send_after(self(), :clear_latest_participant, 5000)

    {:noreply,
     socket
     |> assign(:latest_participant, participant)}
  end

  def handle_info(:participants_updated, socket) do
    participants = QuizManager.get_participants(socket.assigns.code)
    {:noreply, assign(socket, :participants, participants)}
  end

  def handle_info(:quiz_started, socket) do
    question = QuizManager.get_active_question(socket.assigns.code)

    {:noreply,
     socket
     |> assign(:current_question, question)
     |> assign(:started, true)}
  end

  def handle_info(:clear_latest_participant, socket) do
    {:noreply, assign(socket, :latest_participant, nil)}
  end

  def handle_info({:active_question_changed, question}, socket) do
    {:noreply, assign(socket, :current_question, question)}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "#{__MODULE__} | Unhandled PubSub message")
    {:noreply, socket}
  end
end
