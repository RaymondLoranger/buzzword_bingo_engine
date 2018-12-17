defmodule Buzzword.Bingo.Engine.Proxy.Error do
  @moduledoc false

  require Logger

  @spec log(atom, term) :: :ok
  def log(:exit, reason) do
    Logger.remove_backend(:console, flush: true)

    Logger.error("""
    \n`exit` caught...
    • Reason:
    #{inspect(reason)}
    """)

    Logger.add_backend(:console, flush: true)
    :ok
  end
end
