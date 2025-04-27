defmodule Livekwest.Accounts.Auth do
  alias Livekwest.Accounts
  alias Livekwest.Accounts.{User, Guardian}

  @spec authenticate_user(String.t(), String.t()) :: {:ok, map()} | {:error, :invalid_credentials}
  def authenticate_user(email, password) do
    user = Accounts.get_by(email: email)

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

  @spec get_current_user(String.t()) :: {:ok, %User{}} | {:error, :invalid_token}
  def get_current_user(token) do
    with {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims) do
      {:ok, user}
    else
      _ -> {:error, :invalid_token}
    end
  end
end
