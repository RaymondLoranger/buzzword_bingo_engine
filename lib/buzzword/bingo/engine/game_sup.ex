defmodule Buzzword.Bingo.Engine.GameSup do
  use Supervisor

  alias __MODULE__
  alias Buzzword.Bingo.Engine.{DynGameSup, GameRecovery}

  @spec start_link(term) :: Supervisor.on_start()
  def start_link(:ok), do: Supervisor.start_link(GameSup, :ok, name: GameSup)

  ## Callbacks

  @spec init(term) ::
          {:ok, {:supervisor.sup_flags(), [:supervisor.child_spec()]}} | :ignore
  def init(:ok) do
    [
      # Child spec relying on `use DynamicSupervisor`...
      {DynGameSup, :ok},
      # Child spec relying on `use GenServer`...
      {GameRecovery, :ok}
    ]
    |> Supervisor.init(strategy: :rest_for_one)
  end
end
