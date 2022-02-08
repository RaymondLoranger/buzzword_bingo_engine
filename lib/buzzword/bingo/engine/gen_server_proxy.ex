defmodule Buzzword.Bingo.Engine.GenServerProxy do
  @behaviour GenServer.Proxy

  alias Buzzword.Bingo.Engine.GameServer
  alias Buzzword.Bingo.Game

  @impl GenServer.Proxy
  @spec server_name(Game.name()) :: GenServer.name()
  defdelegate server_name(game_name), to: GameServer, as: :via

  @impl GenServer.Proxy
  @spec server_unregistered(Game.name()) :: :ok
  def server_unregistered(game_name) do
    [
      :blue_background,
      :light_white,
      "Game ",
      :light_green,
      "#{game_name}",
      :light_white,
      " not started."
    ]
    |> IO.ANSI.format()
    |> IO.puts()
  end
end
