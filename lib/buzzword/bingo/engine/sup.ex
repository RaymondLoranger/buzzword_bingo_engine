defmodule Buzzword.Bingo.Engine.Sup do
  @moduledoc false

  use Supervisor

  alias __MODULE__
  alias Buzzword.Bingo.Engine.Server.Restart
  alias Buzzword.Bingo.Engine.DynSup

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok), do: Supervisor.start_link(Sup, :ok, name: Sup)

  ## Callbacks

  @spec init(term) ::
          {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(:ok) do
    [
      # Child spec relying on `use DynamicSupervisor`...
      {DynSup, :ok},
      # Child spec relying on `use GenServer`...
      {Restart, :ok}
    ]
    |> Supervisor.init(strategy: :rest_for_one)
  end
end
