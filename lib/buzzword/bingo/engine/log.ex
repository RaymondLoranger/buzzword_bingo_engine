defmodule Buzzword.Bingo.Engine.Log do
  use File.Only.Logger

  alias Buzzword.Bingo.Engine.GameServer

  error :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Server: #{GameServer.via(game.name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason) |> maybe_break(22)}
    • Game being terminated: #{inspect(game) |> maybe_break(25)}
    #{from(env, __MODULE__)}
    """
  end

  info :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Server: #{GameServer.via(game.name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason) |> maybe_break(22)}
    • Game being terminated: #{inspect(game) |> maybe_break(25)}
    #{from(env, __MODULE__)}
    """
  end

  info :saving, {game, request, env} do
    """
    \nSaving game...
    • Server: #{GameServer.via(game.name) |> inspect() |> maybe_break(10)}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request: #{inspect(request) |> maybe_break(25)}
    • Game being saved: #{inspect(game) |> maybe_break(20)}
    #{from(env, __MODULE__)}
    """
  end

  info :spawned, {game_name, game_size, env} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Game size: #{game_size}
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}
    """
  end

  info :restarted, {game_name, game_size, env} do
    """
    \nRestarted game server process...
    • Game name: #{game_name}
    • Game size: #{game_size}
    • Server PID: #{self() |> inspect()}
    #{from(env, __MODULE__)}
    """
  end
end
