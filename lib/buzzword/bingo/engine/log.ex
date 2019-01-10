defmodule Buzzword.Bingo.Engine.Log do
  use File.Only.Logger
  use PersistConfig

  alias Buzzword.Bingo.Engine.Server

  error :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • PID: #{self() |> inspect(pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end

  info :terminate, {reason, game} do
    """
    \nTerminating game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • PID: #{self() |> inspect(pretty: true)}
    • 'terminate' reason: #{inspect(reason, pretty: true)}
    • Game being terminated:
      #{inspect(game, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end

  info :save, {game, request} do
    """
    \nSaving game...
    • Server:
      #{game.name |> Server.via() |> inspect(pretty: true)}
    • PID: #{self() |> inspect(pretty: true)}
    • 'handle_call' request:
      #{inspect(request, pretty: true)}
    • Game being saved:
      #{inspect(game, pretty: true)}
    • App: #{Mix.Project.config()[:app]}
    • Library: #{@app}
    • Module: #{inspect(__MODULE__)}
    """
  end
end
