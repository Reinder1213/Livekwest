defmodule Livekwest.Accounts.Guardian do
  use Guardian, otp_app: :livekwest

  alias Livekwest.Accounts
  alias Livekwest.Accounts.User

  @spec subject_for_token(map(), any()) :: {:error, :no_id_provided} | {:ok, binary()}
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_id_provided}
  end

  @spec resource_from_claims(map()) :: {:ok, %User{}} | {:error, :not_found | :no_id_provided}
  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_by(id: id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_) do
    {:error, :no_id_provided}
  end
end
