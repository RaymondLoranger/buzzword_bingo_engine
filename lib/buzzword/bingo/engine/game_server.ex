defmodule Buzzword.Bingo.Engine.GameServer do
  @moduledoc """
  A server process that holds a game struct as its state.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias Buzzword.Bingo.Engine.Log
  alias Buzzword.Bingo.{Game, Summary}

  @typep handle_call :: {:reply, term, Game.t(), timeout}
  @typep handle_info ::
           {:stop, reason :: tuple, Game.t()} | {:noreply, Game.t()}

  @ets get_env(:ets_name)
  @reg get_env(:registry)
  @timeout :timer.minutes(30)
  @wait 500

  @doc """
  Spawns a new game server process to be registered via `game_name`.
  """
  @spec start_link({game_name :: String.t(), size :: pos_integer}) ::
          GenServer.on_start()
  def start_link({game_name, size}) do
    GenServer.start_link(GameServer, {game_name, size}, name: via(game_name))
  end

  @doc """
  Returns a tuple used to register and look up a game server process by name.
  """
  @spec via(String.t()) :: {:via, Registry, tuple}
  def via(game_name), do: {:via, Registry, {@reg, key(game_name)}}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(game_name), do: {GameServer, game_name}

  @spec game(String.t(), pos_integer) :: Game.t()
  defp game(game_name, size) do
    case :ets.lookup(@ets, key(game_name)) do
      [] ->
        :ok = Log.info(:spawned, {game_name, size, self()})
        game_name |> Game.new(size) |> save(nil)

      [{_key, game}] ->
        :ok = Log.info(:restarted, {game_name, size, self()})
        game
    end
  end

  @spec save(Game.t(), term) :: Game.t()
  defp save(game, request) do
    :ok = Log.info(:save, {game, request, __ENV__})
    true = :ets.insert(@ets, {key(game.name), game})
    game
  end

  ## Callbacks

  @spec init({String.t(), pos_integer}) :: {:ok, Game.t(), timeout}
  def init({game_name, size}), do: {:ok, game(game_name, size), @timeout}

  @spec handle_call(term, GenServer.from(), Game.t()) :: handle_call
  def handle_call(:game_summary, _from, game) do
    {:reply, Summary.new(game), game, @timeout}
  end

  def handle_call(:print_summary, _from, game) do
    :ok = game |> Summary.new() |> Summary.print()
    {:reply, :ok, game, @timeout}
  end

  def handle_call({:mark_square, phrase, player} = request, _from, game) do
    game = game |> Game.mark_square(phrase, player) |> save(request)
    {:reply, game, game, @timeout}
  end

  @spec handle_info(term, Game.t()) :: handle_info
  def handle_info(:timeout, game), do: {:stop, {:shutdown, :timeout}, game}
  def handle_info(_message, game), do: {:noreply, game}

  @spec terminate(term, Game.t()) :: :ok
  def terminate(reason, game)
      when reason in [:shutdown, {:shutdown, :timeout}] do
    :ok = Log.info(:terminate, {reason, game, __ENV__})
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@wait)
  end

  def terminate(reason, game) do
    :ok = Log.error(:terminate, {reason, game, __ENV__})
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@wait)
  end
end
