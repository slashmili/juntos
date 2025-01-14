defmodule Juntos.Repo do
  use Ecto.Repo,
    otp_app: :juntos,
    adapter: Ecto.Adapters.Postgres
end
