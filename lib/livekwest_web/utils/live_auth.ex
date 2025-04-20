defmodule LivekwestWeb.Utils.LiveAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    case session do
      %{"user_token" => token} ->
        case Livekwest.Accounts.Auth.get_current_user(token) do
          {:ok, user} ->
            {:cont, assign(socket, current_user: user)}
          _ ->
            {:halt, redirect(socket, to: "/login")}
        end
      _ ->
        {:halt, redirect(socket, to: "/login")}
    end
  end
end
