defmodule Buzzword.Bingo.Engine.Log do
  use File.Only.Logger

  alias Buzzword.Bingo.Engine.GameServer

  error :terminate, {reason, game, env} do
    """
    \nTerminating game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{game.name |> GameServer.via() |> inspect()}
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
      #{game.name |> GameServer.via() |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'terminate' reason: #{inspect(reason)}
    • Game being terminated:
      #{inspect(game)}
    #{from()}
    """
  end

  info :save, {game, request, env} do
    """
    \nSaving game...
    • Inside function:
      #{fun(env)}
    • Server:
      #{game.name |> GameServer.via() |> inspect()}
    • Server PID: #{self() |> inspect()}
    • 'handle_call' request:
      #{inspect(request)}
    • Game being saved:
      #{inspect(game)}
    #{from()}
    """
  end

  info :spawned, {game_name, game_size, pid} do
    """
    \nSpawned game server process...
    • Game name: #{game_name}
    • Game size: #{game_size}
    • Server PID: #{inspect(pid)}
    #{from()}
    """
  end

  info :restarted, {game_name, game_size, pid} do
    """
    \nRestarted game server process...
    • Game name: #{game_name}
    • Game size: #{game_size}
    • Server PID: #{inspect(pid)}
    #{from()}
    """
  end
end
