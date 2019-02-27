defmodule Buzzword.Bingo.Engine.App do
  # @moduledoc false

  use Application
  use PersistConfig

  alias __MODULE__
  alias Buzzword.Bingo.Engine.Sup

  @ets Application.get_env(@app, :ets_name)
  @reg Application.get_env(@app, :registry)

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    :ets.new(@ets, [:public, :named_table])

    [
      {Registry, keys: :unique, name: @reg},
      # Child spec relying on `use Supervisor`...
      {Sup, :ok}
    ]
    |> Supervisor.start_link(name: App, strategy: :rest_for_one)
  end
end
