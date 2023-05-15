defmodule Buzzword.Bingo.Engine.MixProject do
  use Mix.Project

  def project do
    [
      app: :buzzword_bingo_engine,
      version: "0.1.27",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      name: "Buzzword Bingo Engine",
      source_url: source_url(),
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp source_url do
    "https://github.com/RaymondLoranger/buzzword_bingo_engine"
  end

  defp description do
    """
    Models the Multi-Player Buzzword Bingo game.
    """
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README*",
        "config/persist*.exs",
        "assets/buzzwords.csv"
      ],
      maintainers: ["Raymond Loranger"],
      licenses: ["MIT"],
      links: %{"GitHub" => source_url()}
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
      {:buzzword_bingo_game, "~> 0.1"},
      {:buzzword_bingo_player, "~> 0.1"},
      {:buzzword_bingo_summary, "~> 0.1"},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:dynamic_supervisor_proxy, "~> 0.1"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:file_only_logger, "~> 0.2"},
      {:gen_server_proxy, "~> 0.1"},
      {:log_reset, "~> 0.1"},
      {:persist_config, "~> 0.4", runtime: false}
    ]
  end
end
