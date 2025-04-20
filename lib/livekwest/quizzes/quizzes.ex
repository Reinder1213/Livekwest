defmodule Livekwest.Quizzes do
  import Ecto.Query

  alias Livekwest.Quizzes.Quiz
  alias Livekwest.Repo

  def get(id, user_id) do
    from(q in Quiz,
      where: q.id == ^id and q.user_id == ^user_id,
      preload: [:questions]
    )
    |> Repo.one()
  end

  def list(user_id) do
    from(q in Quiz,
      where: q.user_id == ^user_id,
      preload: [:questions]
    )
    |> Repo.all()
  end
end
