defmodule LivekwestWeb.PresentationLive do
  use LivekwestWeb, :live_view

  import Livekwest.Utils, only: [topic: 1]

  alias Livekwest.QuizSession
  alias Phoenix.PubSub

  def mount(%{"code" => code}, _session, socket) do
    topic = topic(code)
    PubSub.subscribe(Livekwest.PubSub, topic)

    quiz = QuizSession.get_quiz(code)
    participants = QuizSession.get_participants(code)
    question = QuizSession.get_active_question(code)

    {:ok,
     socket
     |> assign(:code, code)
     |> assign(:current_question, question)
     |> assign(:participants, participants)
     |> assign(:latest_participant, nil)
     |> assign(:answered_participant_ids, MapSet.new())
     |> assign(:latest_answered, MapSet.new())
     |> assign(:started, quiz && quiz.started)}
  end

  def handle_info({:new_participant, participant}, socket) do
    Process.send_after(self(), :clear_latest_participant, 5000)

    {:noreply,
     socket
     |> assign(:latest_participant, participant)}
  end

  def handle_info(:participants_updated, socket) do
    participants = QuizSession.get_participants(socket.assigns.code)
    {:noreply, assign(socket, :participants, participants)}
  end

  def handle_info(:clear_latest_participant, socket) do
    {:noreply, assign(socket, :latest_participant, nil)}
  end

  def handle_info(:quiz_started, socket) do
    question = QuizSession.get_active_question(socket.assigns.code)

    {:noreply,
     socket
     |> assign(:current_question, question)
     |> assign(:started, true)}
  end

  def handle_info({:active_question_changed, question}, socket) do
    {:noreply,
     socket
     |> assign(:current_question, question)
     |> assign(:answered_participant_ids, MapSet.new())}
  end

  def handle_info({:answer_submitted, qid, pid}, socket) do
    if socket.assigns.current_question && socket.assigns.current_question.id == qid do
      updated_ids = socket.assigns.answered_participant_ids |> MapSet.new() |> MapSet.put(pid)
      latest = MapSet.put(socket.assigns.latest_answered, pid)

      Process.send_after(self(), {:clear_just_answered, pid}, 1000)

      {:noreply,
       socket
       |> assign(:answered_participant_ids, updated_ids)
       |> assign(:latest_answered, latest)}
    else
      {:noreply, socket}
    end
  end

  # Replace with JS animation later
  def handle_info({:clear_just_answered, pid}, socket) do
    {:noreply, update(socket, :latest_answered, &MapSet.delete(&1, pid))}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "#{__MODULE__} | Unhandled PubSub message")
    {:noreply, socket}
  end
end
