import Config

config :gov_republish, GovRepublish.Repo,
  database: "gov_republish_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :gov_republish, ecto_repos: [GovRepublish.Repo]

config :gov_republish, Oban,
  engine: Oban.Engines.Lite,
  queues: [default: 10],
  repo: GovRepublish.Repo

config :gov_republish, Oban,
  plugins: [
    {Oban.Plugins.Cron,
     crontab: [
       {"*/15 * * * *", GovRepublish.Workers.RssReadWorker,
        max_attempts: 1, args: %{"settings_file" => "config/secrets/jcparking_bot.json"}},
       {"*/20 * * * *", GovRepublish.Workers.BlueskyPostWorker,
        max_attempts: 1, args: %{"settings_file" => "config/secrets/jcparking_bot.json"}}
     ]}
  ]

import_config "#{config_env()}.exs"
