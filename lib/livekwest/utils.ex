defmodule Livekwest.Utils do
  @topic_prefix "quiz:"

  def topic(code), do: @topic_prefix <> code
end
