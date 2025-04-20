defmodule Livekwest.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Livekwest.Repo

  @email_regex ~r/^[^\s]+@[^\s]+$/
  @password_min_length 8

  @required [:email, :password, :name]

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :name, :string

    field :password, :string, virtual: true

    has_many :quizzes, Livekwest.Quizzes.Quiz
    has_many :questions, through: [:quizzes, :questions]

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_format(:email, @email_regex)
    |> validate_length(:password, min: @password_min_length)
    |> unique_constraint(:email)
    |> unique_constraint(:name)
    |> put_password_hash()
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  def get_by_id(id) do
    from(u in __MODULE__, where: u.id == ^id)
    |> Repo.one()
  end
end
