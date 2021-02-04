defmodule Buzzword.Bingo.Engine.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzword_bingo_engine,
      version: "0.1.15",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Buzzword.Bingo.Engine.TopSup, :ok}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:buzzword_bingo_game, github: "RaymondLoranger/buzzword_bingo_game"},
      {:buzzword_bingo_player, github: "RaymondLoranger/buzzword_bingo_player"},
      {:buzzword_bingo_summary,
       github: "RaymondLoranger/buzzword_bingo_summary"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:dynamic_supervisor_proxy, "~> 0.1"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:file_only_logger, "~> 0.1"},
      {:gen_server_proxy, "~> 0.1"},
      {:log_reset, "~> 0.1"},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end
end
