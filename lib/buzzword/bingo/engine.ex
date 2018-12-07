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

  @size_range Application.get_env(@app, :size_range)
  @timeout_in_ms 10
  @timeout_times 100

  @doc """
  Starts a game server process and supervises it.
  """
  @spec start_game(String.t(), pos_integer) :: Supervisor.on_start_child()
  def start_game(game_name, size)
      when is_binary(game_name) and size in @size_range do
    # child_spec = %{
    #   id: Server,
    #   start: {Server, :start_link, [game_name, size]},
    #   restart: :transient
    # }
    # DynamicSupervisor.start_child(DynSup, child_spec)
    DynamicSupervisor.start_child(DynSup, {Server, {game_name, size}})
  end

  @doc """
  Stops a game server process normally. It won't be restarted.
  """
  @spec stop_game(String.t()) :: :ok
  def stop_game(game_name) when is_binary(game_name) do
    game_name |> Server.via() |> GenServer.stop(:shutdown)
  end

  @doc """
  Returns the summary of a game.
  """
  @spec summary(String.t()) :: Summary.t()
  def summary(game_name) when is_binary(game_name) do
    game_name |> Server.via() |> GenServer.call(:summary)
  end

  @doc """
  Prints the summary of a game as a table.
  """
  @spec summary_table(String.t()) :: :ok
  def summary_table(game_name) when is_binary(game_name) do
    game_name |> summary() |> Summary.table()
  end

  @doc """
  Marks a square for a player.
  """
  @spec mark(String.t(), String.t(), Player.t()) :: Summary.t()
  def mark(game_name, phrase, %Player{} = player)
      when is_binary(game_name) and is_binary(phrase) do
    game_name
    |> maybe_wait(@timeout_times)
    |> Server.via()
    |> GenServer.call({:mark, phrase, player})
  end

  ## Private functions

  # On restarts, wait if name not yet registered...
  @spec maybe_wait(String.t(), non_neg_integer) :: String.t()
  defp maybe_wait(game_name, 0), do: game_name

  defp maybe_wait(game_name, timeout_times_left) do
    case Server.game_pid(game_name) do
      pid when is_pid(pid) ->
        game_name

      nil ->
        Process.sleep(@timeout_in_ms)
        maybe_wait(game_name, timeout_times_left - 1)
    end
  end
end
