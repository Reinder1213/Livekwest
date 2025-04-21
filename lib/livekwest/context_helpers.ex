defmodule Livekwest.ContextHelpers do
  @moduledoc """
  Helper function for gathering and filtering data
  """

  import Ecto.Query

  @doc """
  Builds a query for a given schema with optional where clauses and preloads.
  Used across contexts for list and get_by calls.
  """
  def build_query(schema, where_clauses, preloads) do
    schema
    |> where(^where_clauses)
    |> preload(^preloads)
  end
end
