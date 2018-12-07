defmodule Buzzword.Bingo.Engine.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzword_bingo_engine,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Buzzword.Bingo.Engine.App, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mix_tasks,
       github: "RaymondLoranger/mix_tasks", only: :dev, runtime: false},
      {:log_reset, github: "RaymondLoranger/log_reset"},
      {:buzzword_bingo_game, path: "../buzzword_bingo_game"},
      {:buzzword_bingo_player, path: "../buzzword_bingo_player"},
      {:buzzword_bingo_summary, path: "../buzzword_bingo_summary"},
      {:persist_config, "~> 0.1"},
      {:logger_file_backend, "~> 0.0.9"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end