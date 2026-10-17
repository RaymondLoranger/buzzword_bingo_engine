defmodule Buzzword.Bingo.Engine.GameRecovery do
  @moduledoc """
  Makes processes under the game supervisor fault-tolerant. If any crashes (or
  is killed), it is immediately restarted and the system remains undisturbed.
  """

  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Buzzword.Bingo.Engine.{DynGameSup, GameServer}
  alias Buzzword.Bingo.Game

  @ets get_env(:ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(_arg = :ok),
    do: GenServer.start_link(GameRecovery, :ok, name: GameRecovery)

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(_init_arg = :ok), do: {:ok, restart_servers()}

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    :ets.match_object(@ets, {{GameServer, :_}, :_})
    |> Enum.each(fn {{GameServer, _game_name}, %Game{name: name, size: size}} ->
      # Child may already be started...
      DynamicSupervisor.start_child(DynGameSup, {GameServer, {name, size}})
    end)
  end
end
