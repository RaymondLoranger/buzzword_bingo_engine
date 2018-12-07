defmodule Buzzword.Bingo.Engine.Server.Info do
  @moduledoc """
  Logs info messages.
  """

  alias Buzzword.Bingo.Engine.Server

  require Logger

  @spec log(atom, any) :: :ok
  def log(:save, game),
    do: if(Mix.env() == :test, do: :ok, else: do_log(:save, game))

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game),
    do: if(Mix.env() == :test, do: :ok, else: do_log(:terminate, reason, game))

  ## Private functions

  @spec do_log(atom, any) :: :ok
  def do_log(:save, game) do
    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    game being saved...
    #{inspect(game, pretty: true)}
    """
    |> Logger.info()
  end

  @spec do_log(atom, any, any) :: :ok
  def do_log(:terminate, reason, game) do
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
