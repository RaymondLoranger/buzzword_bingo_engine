defmodule Buzzword.Bingo.Engine.Server.Error do
  @moduledoc """
  Logs error messages.
  """

  alias Buzzword.Bingo.Engine.Server

  require Logger

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game) do
    log(:terminate, reason, game, Mix.env())
  end

  ## Private functions

  @spec log(atom, any, any, atom) :: :ok
  defp log(:terminate, _reason, _game, :test = _env), do: :ok

  defp log(:terminate, reason, game, _env) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      """
      \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
      `terminate` reason...
      #{inspect(reason, pretty: true)}
      game being terminated...
      #{inspect(game, pretty: true)}
      """
      |> Logger.error()

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end
end
