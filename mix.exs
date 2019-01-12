defmodule Buzzword.Bingo.Engine.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzword_bingo_engine,
      version: "0.1.2",
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
      {:log_reset, "~> 0.1"},
      {:file_only_logger, "~> 0.1"},
      {:dynamic_supervisor_proxy, "~> 0.1"},
      {:gen_server_proxy, "~> 0.1"},
      {:persist_config, "~> 0.1"},
      {:buzzword_bingo_game, path: "../buzzword_bingo_game"},
      {:buzzword_bingo_player, path: "../buzzword_bingo_player"},
      {:buzzword_bingo_summary, path: "../buzzword_bingo_summary"},
      {:logger_file_backend, "~> 0.0.9"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
