defmodule Livekwest.Repo do
  use Ecto.Repo,
    otp_app: :livekwest,
    adapter: Ecto.Adapters.Postgres
end 