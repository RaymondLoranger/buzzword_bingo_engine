# ┌────────────────────────────────────────────────────────────────────┐
# │ Based on the course "Multi-Player Bingo" by Mike and Nicole Clark. │
# └────────────────────────────────────────────────────────────────────┘
defmodule Buzzword.Bingo.Engine do
  use PersistConfig

  @course_ref Application.get_env(@app, :course_ref)

  @moduledoc """
  Models the _Multi-Player Bingo_ game.
  \n##### #{@course_ref}
  """

  alias Buzzword.Bingo.Engine.{DynSup, Server}
  alias Buzzword.Bingo.{Player, Summary}

  @reg Application.get_env(@app, :registry)
  @size_range Application.get_env(@app, :size_range)
  @timeout_in_ms 10
  @times 100

  @doc """
  Starts a new game server process and supervises it.
  """
  @spec new_game(String.t(), pos_integer) :: Supervisor.on_start_child()
  def new_game(game_name, size)
      when is_binary(game_name) and size in @size_range do
    DynamicSupervisor.start_child(DynSup, {Server, {game_name, size}})
  end

  @doc """
  Stops a game server process normally. It won't be restarted.
  """
  @spec end_game(String.t()) :: :ok
  def end_game(game_name) when is_binary(game_name),
    do: game_name |> Server.via() |> GenServer.stop(:shutdown)

  @doc """
  Returns the summary of a game.
  """
  @spec summary(String.t()) :: Summary.t()
  def summary(game_name) when is_binary(game_name),
    do: game_name |> Server.via() |> GenServer.call(:summary)

  @doc """
  Prints the summary of a game as a table.
  """
  @spec summary_table(String.t()) :: :ok
  def summary_table(game_name) when is_binary(game_name),
    do: game_name |> summary() |> Summary.table()

  @doc """
  Marks a square for a player.
  """
  @spec mark(String.t(), String.t(), Player.t()) :: Summary.t()
  def mark(game_name, phrase, %Player{} = player)
      when is_binary(game_name) and is_binary(phrase) do
    game_name |> Server.via() |> GenServer.call({:mark, phrase, player})
  catch
    :exit, "no process" <> _etc ->
      game_name
      |> wait(@times)
      |> Server.via()
      |> GenServer.call({:mark, phrase, player})
  end

  @doc """
  Returns a sorted list of registered game names.
  """
  @spec game_names :: [String.t() | atom]
  def game_names do
    DynamicSupervisor.which_children(DynSup)
    |> Enum.map(&child_name/1)
    |> Enum.sort()
  end

  @doc """
  Returns the `pid` of the game server process registered under the
  given `game_name`, or `nil` if no process is registered.
  """
  @spec game_pid(String.t()) :: pid | nil
  def game_pid(game_name), do: game_name |> Server.via() |> GenServer.whereis()

  ## Private functions

  @spec child_name(tuple) :: String.t() | atom
  defp child_name({:undefined, pid, :worker, modules}) when is_pid(pid) do
    if Server in modules do
      [{Server, game_name}] = Registry.keys(@reg, pid)
      game_name
    else
      :worker
    end
  end

  defp child_name({:undefined, :restarting, _type, _modules}), do: :restarting
  defp child_name({:undefined, _pid, :supervisor, _modules}), do: :supervisor

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), non_neg_integer) :: String.t()
  defp wait(game_name, 0), do: game_name

  defp wait(game_name, times_left) do
    case game_pid(game_name) do
      pid when is_pid(pid) ->
        game_name

      nil ->
        Process.sleep(@timeout_in_ms)
        wait(game_name, times_left - 1)
    end
  end
end
