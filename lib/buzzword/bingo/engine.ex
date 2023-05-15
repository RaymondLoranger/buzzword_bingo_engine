# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Engine do
  @moduledoc """
  Models the _Multi-Player Buzzword Bingo_ game.

  ##### Based on the course [Multi-Player Bingo](https://pragmaticstudio.com/courses/unpacked-bingo) by Mike and Nicole Clark.
  """

  use GenServer.Proxy
  use PersistConfig

  alias __MODULE__.{DynGameSup, GameServer}
  alias Buzzword.Bingo.{Game, Player, Square, Summary}

  @reg get_env(:registry)
  @size_range get_env(:size_range)

  @doc """
  Starts a new game server process and supervises it.
  """
  @spec new_game(Game.name(), Game.size()) :: Supervisor.on_start_child()
  def new_game(game_name, size)
      when is_binary(game_name) and size in @size_range do
    DynamicSupervisor.start_child(DynGameSup, {GameServer, {game_name, size}})
  end

  @doc """
  Stops a game server process normally. It won't be restarted.
  """
  @spec end_game(Game.name()) :: :ok | {:error, term}
  def end_game(game_name) when is_binary(game_name),
    do: stop(game_name, :shutdown)

  @doc """
  Returns the summary of a game.
  """
  @spec game_summary(Game.name()) :: Summary.t() | {:error, term}
  def game_summary(game_name) when is_binary(game_name),
    do: call(game_name, :game_summary)

  @doc """
  Prints the summary of a game as a formatted table.
  """
  @spec print_summary(Game.name()) :: :ok | {:error, term}
  def print_summary(game_name) when is_binary(game_name),
    do: call(game_name, :print_summary)

  @doc """
  Marks a square with a player.
  """
  @spec mark_square(Game.name(), Square.phrase(), Player.t()) ::
          Summary.t() | {:error, term}
  def mark_square(game_name, phrase, %Player{} = player)
      when is_binary(game_name) and is_binary(phrase),
      do: call(game_name, {:mark_square, phrase, player})

  @doc """
  Generates a unique, URL-friendly name such as "bold-frog-8249".
  """
  @spec haiku_name :: Game.name()
  defdelegate haiku_name, to: Game

  @doc """
  Returns a sorted list of registered game names.
  """
  @spec game_names :: [Game.name() | atom]
  def game_names do
    DynamicSupervisor.which_children(DynGameSup)
    |> Enum.map(&child_name/1)
    |> Enum.sort()
  end

  @doc """
  Returns the pid of the game server process registered via the
  given `game_name`, or `nil` if no such process is registered.
  """
  @spec game_pid(Game.name()) :: pid | nil
  def game_pid(game_name),
    do: GameServer.via(game_name) |> GenServer.whereis()

  ## Private functions

  @spec child_name(tuple) :: Game.name() | atom
  defp child_name({:undefined, pid, :worker, modules}) when is_pid(pid) do
    if GameServer in modules do
      [{GameServer, game_name}] = Registry.keys(@reg, pid)
      game_name
    else
      :worker
    end
  end

  defp child_name({:undefined, :restarting, _type, _modules}), do: :restarting
  defp child_name({:undefined, _pid, :supervisor, _modules}), do: :supervisor
end
