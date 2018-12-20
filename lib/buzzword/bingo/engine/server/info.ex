defmodule Buzzword.Bingo.Engine.Server.Info do
  @moduledoc """
  Logs info messages.
  """

  use PersistConfig

  alias Buzzword.Bingo.Engine.Server

  require Logger

  @env Application.get_env(@app, :env)

  @spec log(atom, any) :: :ok
  def log(:save, game) do
    do_log(:save, game, @env)
  end

  @spec log(atom, any, any) :: :ok
  def log(:terminate, reason, game) do
    do_log(:terminate, reason, game, @env)
  end

  ## Private functions

  @dialyzer {:nowarn_function, do_log: 3}
  @spec do_log(atom, any, atom) :: :ok
  defp do_log(:save, _game, :test = _env), do: :ok

  defp do_log(:save, game, _env) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      """
      \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
      game being saved...
      #{inspect(game, pretty: true)}
      """
      |> Logger.info()

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end

  @dialyzer {:nowarn_function, do_log: 4}
  @spec do_log(atom, any, any, atom) :: :ok
  defp do_log(:terminate, _reason, _game, :test = _env), do: :ok

  defp do_log(:terminate, reason, game, _env) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      """
      \n#{game.name |> Server.via() |> inspect()} #{self() |> inspect()}
      `terminate` reason...
      #{inspect(reason, pretty: true)}
      game being terminated...
      #{inspect(game, pretty: true)}
      """
      |> Logger.info()

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end
end
