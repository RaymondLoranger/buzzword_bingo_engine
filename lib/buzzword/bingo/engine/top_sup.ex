defmodule Buzzword.Bingo.Engine.TopSup do
  use Application
  use PersistConfig

  alias __MODULE__
  alias Buzzword.Bingo.Engine.GameSup

  @ets get_env(:ets_name)
  @reg get_env(:registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_start_type, :ok = _start_args) do
    :ets.new(@ets, [:public, :named_table])

    [
      {Registry, keys: :unique, name: @reg},

      # Child spec relying on `use Supervisor`...
      {GameSup, :ok}
    ]
    |> Supervisor.start_link(name: TopSup, strategy: :one_for_one)
  end
end
