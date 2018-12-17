defmodule Buzzword.Bingo.Engine.Proxy.Error do
  @moduledoc false

  require Logger

  @spec log(atom, term) :: :ok
  def log(:exit, reason), do: log(:exit, reason, Mix.env())

  ## Private functions

  @spec log(atom, term, atom) :: :ok
  defp log(:exit, _reason, :test = _env), do: :ok

  defp log(:exit, reason, _env) do
    :ok = Logger.remove_backend(:console, flush: true)

    :ok =
      Logger.error("""
      \n`exit` caught...
      • Reason:
      #{inspect(reason)}
      """)

    {:ok, _pid} = Logger.add_backend(:console, flush: true)
    :ok
  end
end
