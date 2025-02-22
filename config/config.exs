import Config

config :gov_republish, GovRepublish.Repo,
  database: "gov_republish_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :gov_republish, ecto_repos: [GovRepublish.Repo]
