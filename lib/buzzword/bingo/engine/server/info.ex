defmodule Buzzword.Bingo.Engine.Server.Info do
  @moduledoc """
  Logs info messages.
  """

  alias Buzzword.Bingo.Engine.Server

  require Logger

  @spec log(atom, any) :: :ok
  def log(:save, game) do
    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    game being saved...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()
  end

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game) do
    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `terminate` reason...
    #{inspect(reason, pretty: true)}
    game being terminated...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()
  end
end
