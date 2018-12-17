defmodule Buzzword.Bingo.Engine.Proxy.Info do
  @moduledoc false

  require Logger

  @spec log(atom, String.t(), timeout | pid, pos_integer, term) :: :ok
  def log(:game_not_registered, game_name, timeout, times_left, reason) do
    log(:game_not_registered, game_name, timeout, times_left, reason, Mix.env())
  end

  def log(:game_registered, game_name, pid, times_left, reason) do
    log(:game_registered, game_name, pid, times_left, reason, Mix.env())
  end

  ## Private functions

  @spec log(atom, String.t(), timeout | pid, pos_integer, term, atom) :: :ok
  defp log(_, _, _, _, _, :test = _env), do: :ok

  defp log(:game_not_registered, game_name, timeout, times_left, reason, _) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      Logger.info("""
      \nGame #{inspect(game_name)} not registered:
      • Waiting: #{timeout} ms
      • Waits left: #{times_left}
      • Reason:
      #{inspect(reason)}
      """)

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end

  defp log(:game_registered, game_name, pid, times_left, reason, _) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      Logger.info("""
      \nGame #{inspect(game_name)} registered:
      • PID: #{inspect(pid)}
      • Waits left: #{times_left}
      • Reason:
      #{inspect(reason)}
      """)

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end
end
