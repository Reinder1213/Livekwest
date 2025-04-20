defmodule Livekwest.Quizzes.Question do
  use Ecto.Schema
  import Ecto.Changeset

  alias Livekwest.Quizzes.Quiz

  @required [:content, :index, :quiz_id]
  @optional [:content, :type, :index, :quiz_id]
  @question_types ~w(open multiple_choice)a

  schema "questions" do
    field(:content, :string)
    field(:type, Ecto.Enum, values: @question_types, default: :open)
    field(:index, :integer)

    belongs_to(:quiz, Quiz)

    timestamps()
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:type, @question_types)
    |> foreign_key_constraint(:quiz_id)
  end
end
