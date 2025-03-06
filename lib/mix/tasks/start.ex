defmodule Mix.Tasks.Start do
  @moduledoc "Starts the jobs configured in config/confix.exs"
  @shortdoc "Starts all cron jobs"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().cmd("cd infra/nitter; docker-compose up -d", [])
    Mix.Tasks.Run.run(["--no-halt"])
  end
end
