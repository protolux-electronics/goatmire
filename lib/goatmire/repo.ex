defmodule Goatmire.Repo do
  use Ecto.Repo,
    otp_app: :goatmire,
    adapter: Ecto.Adapters.SQLite3
end
