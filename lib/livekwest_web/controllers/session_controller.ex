defmodule LivekwestWeb.SessionController do
  use LivekwestWeb, :controller

  alias Livekwest.Accounts.Auth

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Auth.authenticate_user(email, password) do
      {:ok, %{user: _user, token: token}} ->
        conn
        |> put_session(:user_token, token)
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: ~p"/")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> render(:new)
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_token)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/")
  end
end
