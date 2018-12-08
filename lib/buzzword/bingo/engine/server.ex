defmodule Buzzword.Bingo.Engine.Server do
  @moduledoc """
  A server process that holds a game struct as its state.
  """

  use GenServer, restart: :transient
  use PersistConfig

  alias __MODULE__
  alias __MODULE__.{Error, Info}
  alias Buzzword.Bingo.{Game, Summary}

  @type from :: GenServer.from()
  @type reply :: {:reply, Summary.t(), Game.t(), timeout}

  @ets Application.get_env(@app, :ets_name)
  @reg Application.get_env(@app, :registry)
  @timeout :timer.hours(2)
  @timeout_in_ms 500

  @doc """
  Spawns a new game server process to be registered under `game_name`.
  """
  @spec start_link({game_name :: String.t(), size :: pos_integer}) ::
          GenServer.on_start()
  def start_link({game_name, size} = _tuple),
    do: GenServer.start_link(Server, {game_name, size}, name: via(game_name))

  @doc """
  Returns a tuple used to register and lookup a game server process by name.
  """
  @spec via(String.t()) :: {:via, Registry, tuple}
  def via(game_name), do: {:via, Registry, {@reg, key(game_name)}}

  ## Private functions

  @spec key(String.t()) :: tuple
  defp key(game_name), do: {Server, game_name}

  @spec game(String.t(), pos_integer) :: Game.t()
  defp game(game_name, size) do
    case :ets.lookup(@ets, key(game_name)) do
      [] -> game_name |> Game.new(size) |> save()
      [{_key, game}] -> game
    end
  end

  @spec save(Game.t()) :: Game.t()
  defp save(game) do
    :ok = Info.log(:save, game)
    true = :ets.insert(@ets, {key(game.name), game})
    game
  end

  @spec reply(Game.t()) :: reply
  defp reply(game), do: {:reply, Summary.new(game), game, @timeout}

  ## Callbacks

  @spec init({String.t(), pos_integer}) :: {:ok, Game.t(), timeout}
  def init({game_name, size}) do
    game = game(game_name, size)
    {:ok, game, @timeout}
  end

  @spec handle_call(term, from, Game.t()) :: reply
  def handle_call(:summary, _from, game), do: reply(game)

  def handle_call({:mark, phrase, player}, _from, game),
    do: game |> Game.mark(phrase, player) |> save() |> reply()

  @spec handle_info(:timeout, Game.t()) :: {:stop, reason :: tuple, Game.t()}
  def handle_info(:timeout, game), do: {:stop, {:shutdown, :timeout}, game}

  @spec terminate(term, Game.t()) :: :ok
  def terminate(reason, game)
      when reason in [:shutdown, {:shutdown, :timeout}] do
    :ok = Info.log(:terminate, reason, game)
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@timeout_in_ms)
  end

  def terminate(reason, game) do
    :ok = Error.log(:terminate, reason, game)
    true = :ets.delete(@ets, key(game.name))
    # Ensure message logged before exiting...
    Process.sleep(@timeout_in_ms)
  end
end
