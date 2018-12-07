defmodule Buzzword.Bingo.Engine.App do
  @moduledoc false

  use Application
  use PersistConfig

  alias __MODULE__
  alias Buzzword.Bingo.Engine.Sup
  alias Log.Reset

  @ets Application.get_env(@app, :ets_name)
  @reg Application.get_env(@app, :registry)

  @error_path Application.get_env(:logger, :error_log)[:path]
  @info_path Application.get_env(:logger, :info_log)[:path]
  @warn_path Application.get_env(:logger, :warn_log)[:path]

  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, :ok) do
    unless Mix.env() == :test do
      [@error_path, @info_path, @warn_path] |> Enum.each(&Reset.clear_log/1)
    end

    :ets.new(@ets, [:public, :named_table])

    [
      {Registry, keys: :unique, name: @reg},
      # Child spec relying on use GenServer...
      {Sup, :ok}
    ]
    |> Supervisor.start_link(name: App, strategy: :rest_for_one)
  end
end
