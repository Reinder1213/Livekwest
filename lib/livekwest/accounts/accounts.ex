defmodule Livekwest.Accounts do
  import Livekwest.ContextHelpers

  alias Livekwest.Accounts.User
  alias Livekwest.Repo

  @spec get_by(keyword(), [atom()]) :: %User{} | nil
  def get_by(clauses, preloads \\ []) do
    User
    |> build_query(clauses, preloads)
    |> Repo.one()
  end

  @spec list(keyword(), [atom()]) :: [%User{}]
  def list(clauses, preloads \\ []) do
    User
    |> build_query(clauses, preloads)
    |> Repo.all()
  end
end
