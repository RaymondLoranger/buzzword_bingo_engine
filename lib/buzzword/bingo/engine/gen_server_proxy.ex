defmodule Buzzword.Bingo.Engine.GenServerProxy do
  @behaviour GenServer.Proxy

  alias Buzzword.Bingo.Engine.GameServer
  alias IO.ANSI

  @impl GenServer.Proxy
  @spec server_name(String.t()) :: GenServer.name()
  defdelegate server_name(game_name), to: GameServer, as: :via

  @impl GenServer.Proxy
  @spec server_unregistered(String.t()) :: :ok
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
    |> ANSI.format()
    |> IO.puts()
  end
end
