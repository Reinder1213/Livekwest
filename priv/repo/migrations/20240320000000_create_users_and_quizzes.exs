defmodule Livekwest.Repo.Migrations.CreateUsersAndQuizzes do
  use Ecto.Migration

  def change do
    create table(:users) do
        add :name, :string, null: false
        add :email, :string, null: false
        add :password_hash, :string, null: false

      timestamps()
    end

    create unique_index(:users, [:email])

    create table(:quizzes) do
      add :title, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:quizzes, [:user_id])

    create table(:questions) do
      add :content, :text, null: false
      add :type, :string, default: "open"
      add :index, :integer, null: false
      add :quiz_id, references(:quizzes, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:questions, [:quiz_id])
  end
end
