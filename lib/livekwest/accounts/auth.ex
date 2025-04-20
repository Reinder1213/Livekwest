defmodule Livekwest.Accounts.Auth do
  alias Livekwest.Accounts.{User, Guardian}
  alias Livekwest.Repo

  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      nil ->
        {:error, :invalid_credentials}
      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, token, _claims} = Guardian.encode_and_sign(user)
          {:ok, %{user: user, token: token}}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def get_current_user(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      {:ok, user}
    else
      _ -> {:error, :invalid_token}
    end
  end
end
