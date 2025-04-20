defmodule LivekwestWeb.JoinLive do
  use LivekwestWeb, :live_view

  import Livekwest.Utils, only: [topic: 1]
  import LivekwestWeb.Utils.LiveHelpers

  alias Livekwest.QuizManager
  alias Phoenix.PubSub

  @avatar_options [
    "bear.png",
    "buffalo.png",
    "chick.png",
    "chicken.png",
    "cow.png",
    "crocodile.png",
    "dog.png",
    "duck.png",
    "elephant.png",
    "frog.png",
    "giraffe.png",
    "goat.png",
    "gorilla.png",
    "hippo.png",
    "horse.png",
    "monkey.png",
    "moose.png",
    "narwhal.png",
    "owl.png",
    "panda.png",
    "parrot.png",
    "penguin.png",
    "pig.png",
    "rabbit.png",
    "rhino.png",
    "sloth.png",
    "snake.png",
    "walrus.png",
    "whale.png",
    "zebra.png"
  ]

  def mount(_params, _session, socket) do
    socket
    |> assign(:participant, nil)
    |> assign(:joined, false)
    |> assign(:code, nil)
    |> assign(:selected_avatar, @avatar_options |> Enum.random())
    |> assign(:current_question, nil)
    |> assign(:started, false)
    |> assign_avatar_options(@avatar_options)
    |> ok()
  end

  def handle_event("join", %{"code" => code, "name" => name}, socket) do
    with :ok <- connect_to_quiz(code),
         {:ok, id} <-
           QuizManager.add_participant(code, %{name: name, avatar: socket.assigns.selected_avatar}) do
      socket
      |> put_flash(:info, "Succefully joined room")
      |> assign(:joined, true)
      |> assign(:code, code)
      |> assign(:participant, %{name: name, id: id})
      |> noreply()
    else
      error ->
        socket
        |> put_flash(:error, inspect(error))
        |> noreply()
    end
  end

  def handle_event("select_avatar", %{"url" => url}, socket) do
    socket
    |> assign(:selected_avatar, url)
    |> noreply()
  end

  def handle_info({:removed_participant, id}, socket) do
    if socket.assigns.participant.id == id do
      Process.send_after(self(), :kick_redirect, 2000)

      socket
      |> put_flash(:warn, "You were removed from the quiz")
      |> redirect(to: ~p"/join")
      |> noreply()
    else
      {:noreply, socket}
    end
  end

  def handle_info(:quiz_started, socket) do
    question = QuizManager.get_active_question(socket.assigns.code)

    {:noreply,
     socket
     |> assign(:current_question, question)
     |> assign(:started, true)}
  end

  def handle_info({:active_question_changed, question}, socket) do
    {:noreply, assign(socket, :question, question)}
  end

  def handle_info(:kick_redirect, socket) do
    {:noreply, redirect(socket, to: ~p"/join")}
  end

  def handle_info({:submit_answer, %{question_id: qid, answer: value}}, socket) do
    QuizManager.submit_answer(socket.assigns.code, qid, socket.assigns.participant.id, value)
    {:noreply, socket}
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "#{__MODULE__} | Unhandled PubSub message")
    {:noreply, socket}
  end

  defp connect_to_quiz(code) do
    topic = topic(code)
    PubSub.subscribe(Livekwest.PubSub, topic)
  end

  defp assign_avatar_options(
         %{assigns: %{selected_avatar: selected}} = socket,
         avatars
       ) do
    head = avatars |> Enum.find(&String.equivalent?(&1, selected))
    tail = avatars |> Enum.reject(&String.equivalent?(&1, selected)) |> Enum.shuffle()
    assign(socket, :avatar_options, [head] ++ tail)
  end
end
