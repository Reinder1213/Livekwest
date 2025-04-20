defmodule LivekwestWeb.Utils.LiveHelpers do
  @moduledoc """
  Helpers to make LiveView function returns more pipe-friendly.
  """

  @doc """
  Wraps a socket in a `{:noreply, socket}` tuple for use in LiveView callbacks.
  """
  def noreply(socket), do: {:noreply, socket}

  @doc """
  Allows piping a function result into an `:ok` tuple.
  """
  def ok(result), do: {:ok, result}

  @doc """
  Allows piping a function result into an `:error` tuple.
  """
  def error(reason), do: {:error, reason}
end
