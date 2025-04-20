defmodule LivekwestWeb.Utils.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller
1
  alias Livekwest.Accounts.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    with token when not is_nil(token) <- get_session(conn, :user_token),
         {:ok, user} <- Auth.get_current_user(token) do
      conn
      |> assign(:current_user, user)
    else
      _ ->
        conn
        |> put_flash(:error, "Unauthorized")
        |> redirect(to: "/login")
        |> halt()
    end
  end
end
