defmodule Buzzword.Bingo.Engine.Callback do
  @moduledoc false

  @behaviour GenServer.Proxy.Behaviour

  alias Buzzword.Bingo.Engine.Server
  alias IO.ANSI

  @impl GenServer.Proxy.Behaviour
  @spec server_name(String.t()) :: GenServer.name()
  def server_name(game_name), do: Server.via(game_name)

  @impl GenServer.Proxy.Behaviour
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
