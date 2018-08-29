defmodule Recorder.MixProject do
  use Mix.Project

  def project do
    [
      app: :recorder,
      version: "0.1.0",
      elixir: "~> 1.7",
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
      {:poison, "~> 2.2 or ~> 3.0", optional: true},
      {:httpoison, "~> 1.3"},
      {:cortex, "~> 0.4"},
      {:flexi, "~> 0.4"}
    ]
  end
end
