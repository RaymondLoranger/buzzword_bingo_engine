# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Engine do
  @moduledoc """
  Models the _Multi-Player Bingo_ game.

  ##### Based on the course [Multi-Player Bingo](https://pragmaticstudio.com/courses/unpacked-bingo) by Mike and Nicole Clark.
  """

  use GenServer.Proxy
  use PersistConfig

  alias Buzzword.Bingo.Engine.{DynGameSup, GameServer}
  alias Buzzword.Bingo.{Game, Player, Summary}

  @reg get_env(:registry)
  @size_range get_env(:size_range)

  @doc """
  Starts a new game server process and supervises it.
  """
  @spec new_game(String.t(), pos_integer) :: Supervisor.on_start_child()
  def new_game(game_name, size)
      when is_binary(game_name) and size in @size_range do
    DynamicSupervisor.start_child(DynGameSup, {GameServer, {game_name, size}})
  end

  @doc """
  Stops a game server process normally. It won't be restarted.
  """
  @spec end_game(String.t()) :: :ok | {:error, term}
  def end_game(game_name) when is_binary(game_name),
    do: stop(:shutdown, game_name)

  @doc """
  Returns the summary of a game.
  """
  @spec game_summary(String.t()) :: Summary.t() | {:error, term}
  def game_summary(game_name) when is_binary(game_name),
    do: call(:game_summary, game_name)

  @doc """
  Prints the summary of a game as a formatted table.
  """
  @spec print_summary(String.t()) :: :ok | {:error, term}
  def print_summary(game_name) when is_binary(game_name),
    do: call(:print_summary, game_name)

  @doc """
  Marks a square for a player.
  """
  @spec mark_square(String.t(), String.t(), Player.t()) ::
          Game.t() | {:error, term}
  def mark_square(game_name, phrase, %Player{} = player)
      when is_binary(game_name) and is_binary(phrase),
      do: call({:mark_square, phrase, player}, game_name)

  @doc """
  Returns a sorted list of registered game names.
  """
  @spec game_names :: [String.t() | atom]
  def game_names do
    DynamicSupervisor.which_children(DynGameSup)
    |> Enum.map(&child_name/1)
    |> Enum.sort()
  end

  @doc """
  Returns the `pid` of the game server process registered via the
  given `game_name`, or `nil` if no such process is registered.
  """
  @spec game_pid(String.t()) :: pid | nil
  def game_pid(game_name),
    do: game_name |> GameServer.via() |> GenServer.whereis()

  ## Private functions

  @spec child_name(tuple) :: String.t() | atom
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
