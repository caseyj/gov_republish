defmodule GovRepublish.MixProject do
  use Mix.Project

  def project do
    [
      app: :gov_republish,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:saxy, "~> 1.6"},
      {:date_time_parser, "~> 1.2.0"},
      {:mock, "~> 0.3.0", only: :test},
      {:httpoison, "~> 2.0"},
      {:poison, "~> 6.0"},
      {:ecto_sqlite3, "~> 0.17"},
      {:oban, "~> 2.19"},
      {:jason, "~> 1.4"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
