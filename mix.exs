defmodule GovRepublish.MixProject do
  use Mix.Project

  def project do
    [
      app: :gov_republish,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:date_time_parser, "~> 1.2.0"}
    ]
  end
end
