defmodule Livekwest.QuizSupervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_quiz_session(code) do
    spec = {Livekwest.QuizSession, code}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
