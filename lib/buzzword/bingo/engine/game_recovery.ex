defmodule Buzzword.Bingo.Engine.GameRecovery do
  @moduledoc """
  Makes processes under the game supervisor fault-tolerant. If any crashes (or
  is killed), it is immediately restarted and the system remains undisturbed.
  """

  use GenServer
  use PersistConfig

  alias __MODULE__
  alias Buzzword.Bingo.Engine.{DynGameSup, GameServer}

  @ets get_env(:ets_name)

  @spec start_link(term) :: GenServer.on_start()
  def start_link(_arg = :ok),
    do: GenServer.start_link(GameRecovery, :ok, name: GameRecovery)

  ## Private functions

  @spec restart_servers :: :ok
  defp restart_servers do
    :ets.match_object(@ets, {{GameServer, :_}, :_})
    |> Enum.each(fn {{GameServer, _game_name}, game} ->
      # Child may already be started...
      DynamicSupervisor.start_child(
        DynGameSup,
        {GameServer, {game.name, game.size}}
      )
    end)
  end

  ## Callbacks

  @spec init(term) :: {:ok, term}
  def init(_init_arg = :ok), do: {:ok, restart_servers()}
end
