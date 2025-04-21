defmodule Livekwest.Quizzes do
  import Livekwest.ContextHelpers

  alias Livekwest.Quizzes.Quiz
  alias Livekwest.Repo

  def get_by(clauses, preloads \\ []) do
    Quiz
    |> build_query(clauses, preloads)
    |> Repo.one()
  end

  def list(clauses, preloads \\ []) do
    Quiz
    |> build_query(clauses, preloads)
    |> Repo.all()
  end
end
