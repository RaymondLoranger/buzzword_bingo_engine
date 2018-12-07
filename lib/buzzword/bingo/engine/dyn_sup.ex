defmodule Buzzword.Bingo.Engine.DynSup do
  @moduledoc """
  A supervisor that starts game server processes dynamically.
  """

  use DynamicSupervisor

  alias __MODULE__

  @timeout_in_ms 10

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok) do
    DynamicSupervisor.start_link(DynSup, :ok, name: maybe_wait(DynSup))
  end

  ## Private functions

  # On restarts, wait if name still registered...
  @spec maybe_wait(atom) :: atom
  defp maybe_wait(name) do
    case Process.whereis(name) do
      nil ->
        name

      pid when is_pid(pid) ->
        Process.sleep(@timeout_in_ms)
        maybe_wait(name)
    end
  end

  ## Callbacks

  @spec init(term) :: {:ok, DynamicSupervisor.sup_flags()} | :ignore
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
