import Config

config :gov_republish, GovRepublish.Repo,
  database: "gov_republish_repo_test",
  username: "user",
  password: "pass",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
