defmodule GovRepublish.Repo do
  use Ecto.Repo,
    otp_app: :gov_republish,
    adapter: Ecto.Adapters.SQLite3
end
