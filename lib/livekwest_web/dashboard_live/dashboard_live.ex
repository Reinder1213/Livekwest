defmodule LivekwestWeb.DashboardLive do
  use LivekwestWeb, :live_view

  alias Livekwest.Quizzes

  on_mount LivekwestWeb.Utils.LiveAuth

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    quizzes = Quizzes.list([user_id: user.id], [:questions])

    {:ok,
     socket
     |> assign(:quizzes, quizzes)
     |> assign(:page_title, "Your Quiz list")}
  end
end
