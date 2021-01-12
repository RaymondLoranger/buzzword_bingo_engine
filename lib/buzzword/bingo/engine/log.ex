defmodule Buzzword.Bingo.Engine.Log do
  use File.Only.Logger

  alias Buzzword.Bingo.Engine.GameServer

  error :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{GameServer.via(game.name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{GameServer.via(game.name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :saving, {game, request, env} do
    """
    \nSaving game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{GameServer.via(game.name) |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request:
      #{inspect(request)}
    • Game being saved:
      #{inspect(game)}
    #{from()}
    """
  end

  info :spawned, {game_name, game_size} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Game size: #{game_size}
    • Server PID: #{self() |> inspect()}
    #{from()}
    """
  end

  info :restarted, {game_name, game_size} do
    """
    \nRestarted game server process...
    • Game name: #{game_name}
    • Game size: #{game_size}
    • Server PID: #{self() |> inspect()}
    #{from()}
    """
  end
end
