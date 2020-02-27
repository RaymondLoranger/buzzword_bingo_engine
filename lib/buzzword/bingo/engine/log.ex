defmodule Buzzword.Bingo.Engine.Log do
  @moduledoc false

  use File.Only.Logger

  alias Buzzword.Bingo.Engine.Server

  error :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end

  info :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end

  info :save, {game, request} do
    """
    \nSaving game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • Server PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(request, pretty: true)}
    • Game being saved:
      #{inspect(game, pretty: true)}
    #{from()}
    """
  end
end
