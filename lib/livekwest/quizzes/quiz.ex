defmodule Livekwest.Quizzes.Quiz do
  use Ecto.Schema
  import Ecto.Changeset

  alias Livekwest.Accounts.User
  alias Livekwest.Quizzes.Question

  @required [:title, :user_id]

  schema "quizzes" do
    field :title, :string

    belongs_to :user, User
    has_many :questions, Question, on_delete: :delete_all

    timestamps()
  end

  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
  end
end
