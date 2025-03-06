defmodule GovRepublish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger(encode: false, level: :debug)

    children = [
      # Starts a worker by calling: DataCollector.Worker.start_link(arg)
      GovRepublish.Repo,
      {Oban, Application.fetch_env!(:gov_republish, Oban)}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GovRepublish.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
