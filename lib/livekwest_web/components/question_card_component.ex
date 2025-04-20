defmodule LivekwestWeb.QuestionCardComponents do
  use Phoenix.Component

  attr :label, :string, required: true
  attr :question, :map, required: true
  slot :inner_block

  def question_card(assigns) do
    ~H"""
    <div class="card card-xl bg-base-100 shadow-md border">
      <div class="card-body">
        <h2 class="card-title">{@label}</h2>
        <p class="text-xl">{@question.content}</p>

        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
