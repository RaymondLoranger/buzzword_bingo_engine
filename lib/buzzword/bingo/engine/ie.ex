defmodule Buzzword.Bingo.Engine.IE do
  @moduledoc false

  # Example of an IEx session...
  #
  #   use Buzzword.Bingo.Engine.IE
  #   ray = Player.new("Ray", "light_yellow")
  #   Engine.new_game("blue-moon", 4)
  #   Engine.summary_table("blue-moon")
  #   Engine.mark("blue-moon", "Drill Down", ray)
  #   Engine.summary_table("blue-moon")
  #   etc.

  alias Buzzword.Bingo.Engine

  # Supervisor option defaults for :max_restarts and :max_seconds
  @max_restarts 3
  @max_seconds 5
  @seconds_per_restart Float.round(@max_seconds / @max_restarts, 0)
  @pause round(@seconds_per_restart * 1000)
  @snooze 10

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias Buzzword.Bingo.Engine.Server.Restart

      alias Buzzword.Bingo.Engine.{
        App,
        Callback,
        DynSup,
        Log,
        Server,
        Sup
      }

      alias Buzzword.Bingo.{Engine, Game, Player, Square, Summary}
      alias Buzzword.Cache
      :ok
    end
  end

  # :observer.start
  # use Buzzword.Bingo.Engine.IE
  # pid = keep_killing(Sup)
  # pid = keep_killing(DynSup)
  # pid = keep_killing("icy-moon")
  # Process.exit(pid, :kill)
  @spec keep_killing(atom | binary) :: pid
  def keep_killing(name) do
    spawn(fn ->
      for _ <- Stream.cycle([:ok]) do
        name |> pid() |> Process.exit(:kill)
        Process.sleep(@pause)
      end
    end)
  end

  ## Private functions

  @spec pid(atom | binary) :: pid
  defp pid(name) when is_atom(name) do
    case Process.whereis(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        Process.sleep(@snooze)
        pid(name)
    end
  end

  defp pid(name) when is_binary(name) do
    case Engine.game_pid(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        Process.sleep(@snooze)
        pid(name)
    end
  end
end
