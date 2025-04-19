defmodule LivekwestWeb.AnswerForm do
  use Phoenix.LiveComponent

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:input_value, "")
     |> assign(:original_value, nil)
     |> assign(:can_submit, false)}
  end

  @impl true
  def update(%{question: question}, socket) do
    # Reset input when question changes
    {:ok,
     socket
     |> assign(:question, question)
     |> assign(:input_value, "")
     |> assign(:original_value, nil)
     |> assign(:can_submit, false)}
  end

  @impl true
  def handle_event("answer_change", %{"answer" => value}, socket) do
    value = String.trim(value)

    can_submit =
      value != "" and
        (socket.assigns.original_value == nil or socket.assigns.original_value != value)

    {:noreply,
     socket
     |> assign(:input_value, value)
     |> assign(:can_submit, can_submit)}
  end

  def handle_event("submit_answer", _, socket) do
    send(self(), {
      :submit_answer,
      %{
        question_id: socket.assigns.question.id,
        answer: socket.assigns.input_value
      }
    })

    {:noreply,
     socket
     |> assign(:original_value, socket.assigns.input_value)
     |> assign(:can_submit, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-6">
      <form phx-change="answer_change" phx-submit="submit_answer" phx-target={@myself}>
        <input
          type="text"
          name="answer"
          value={@input_value}
          placeholder="Type your answer"
          class="input input-bordered w-full"
          phx-debounce="300"
        />

        <button type="submit" class="btn btn-primary mt-4 w-full" disabled={!@can_submit}>
          {if @original_value == nil, do: "Submit", else: "Resubmit"}
        </button>
      </form>
    </div>
    """
  end
end
