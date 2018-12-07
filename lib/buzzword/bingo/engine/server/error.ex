defmodule Buzzword.Bingo.Engine.Server.Error do
  @moduledoc """
  Logs error messages.
  """

  alias Buzzword.Bingo.Engine.Server

  require Logger

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game),
    do: if(Mix.env() == :test, do: :ok, else: do_log(:terminate, reason, game))

  ## Private functions

  @spec do_log(atom, any, any) :: :ok
  defp do_log(:terminate, reason, game) do
    """
    \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
    `terminate` reason...
    #{inspect(reason, pretty: true)}
    game being terminated...
    #{inspect(game, pretty: true)}
    """
    |> Logger.error()
  end
end
