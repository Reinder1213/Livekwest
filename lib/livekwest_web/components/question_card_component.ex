defmodule LivekwestWeb.QuestionCardComponents do
  use Phoenix.Component

  def question_card(assigns) do
    ~H"""
    <div class="card card-xl bg-base-100 shadow-md border">
      <div class="card-body">
        <h2 class="card-title">{@label}</h2>
        <p class="text-xl">{@question.text}</p>
      </div>
    </div>
    """
  end
end
