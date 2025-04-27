defmodule Livekwest.Quizzes do
  import Livekwest.ContextHelpers

  alias Livekwest.Quizzes.Quiz
  alias Livekwest.Repo

  @spec get_by(keyword(), [atom()]) :: %Quiz{} | nil
  def get_by(clauses, preloads \\ []) do
    Quiz
    |> build_query(clauses, preloads)
    |> Repo.one()
  end

  @spec list(keyword(), [atom()]) :: [%Quiz{}]
  def list(clauses, preloads \\ []) do
    Quiz
    |> build_query(clauses, preloads)
    |> Repo.all()
  end
end
