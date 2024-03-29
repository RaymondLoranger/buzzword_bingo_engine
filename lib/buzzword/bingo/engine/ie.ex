defmodule Buzzword.Bingo.Engine.IE do
  @moduledoc false

  ## Example of an IEx session...
  #
  #   iex -S mix
  #
  #   use Buzzword.Bingo.Engine.IE
  #   Engine.new_game("icy-moon", 4)
  #   Engine.new_game("icy-moon", 5) # => {:error, {:already_started, <pid>}}
  #   Engine.new_game("crimson-sun", 5)
  #   Engine.game_pid("icy-moon")
  #   Engine.game_pid("crimson-sun")
  #   Engine.game_names
  #   :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   Engine.print_summary("icy-moon")
  #   Engine.mark_square("icy-moon", "<phrase-in-table>", ray)
  #   Engine.print_summary("icy-moon")
  #   Engine.game_summary("icy-moon")
  #   Engine.end_game("icy-moon")
  #   Engine.end_game("crimson-sun")

  use PersistConfig

  alias Buzzword.Bingo.{Engine, Game, Player, Square}

  @size_range get_env(:size_range)

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      alias unquote(__MODULE__)
      alias Log.Reset

      alias Buzzword.Bingo.Engine.{
        DynGameSup,
        Ets,
        GameRecovery,
        GameServer,
        GameSup,
        GenServerProxy,
        Log,
        Reg,
        TopSup
      }

      alias Buzzword.Bingo.{Engine, Game, Player, Square, Summary}
      alias Buzzword.Cache
      alias IO.ANSI.Plus, as: ANSI
      :ok
    end
  end

  ## Example of an IEx session...
  #
  #   iex -S mix
  #
  #   use Buzzword.Bingo.Engine.IE
  #   new_games(2) # starts 2 games with last called "blue-moon"
  #   Reset.reset_logs([:debug]) # optional
  #   Reset.reset_logs(:all) # optional
  #   :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   Engine.game_names()
  #   Engine.print_summary(blue_moon)
  #   mark_square(blue_moon, "<phrase-in-table>") # and then check the logs
  #   Engine.print_summary(blue_moon)
  #   Engine.game_names() |> Enum.each(&Engine.end_game/1)

  ## Example of an IEx session...
  #
  #   iex -S mix
  #
  #   use Buzzword.Bingo.Engine.IE
  #   new_games(400) # starts 400 games with last called "blue-moon"
  #   Reset.reset_logs([:debug]) # optional
  #   Reset.reset_logs(:all) # optional
  #   :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   Engine.game_names
  #   Engine.print_summary(blue_moon)
  #   mark_square(DynGameSup, "<phrase-in-table>") # and then check the logs
  #   Engine.print_summary(blue_moon)
  #   Engine.game_names() |> Stream.map(&Engine.end_game/1) |> Enum.to_list()

  ## Example of an IEx session...
  #
  #   iex -S mix
  #
  #   use Buzzword.Bingo.Engine.IE
  #   new_games(300) # starts 300 new games with last called "blue-moon"
  #   Reset.reset_logs([:debug]) # optional
  #   Reset.reset_logs(:all) # optional
  #   :ets.match(Ets, {{GameServer, :"$1"}, :_})
  #   Engine.game_names
  #   Engine.print_summary(blue_moon)
  #   mark_square(GameSup, "<phrase-in-table>") # and then check the logs
  #   Engine.print_summary(blue_moon)
  #   Engine.game_names() |> Stream.map(&Engine.end_game/1) |> Enum.to_list()

  @spec ray :: Player.t()
  def ray, do: Player.new("Ray", "light_yellow")

  @spec blue_moon :: Game.name()
  def blue_moon, do: "blue-moon"

  @spec keep_killing(atom | binary) :: pid
  def keep_killing(name) when is_atom(name) or is_binary(name) do
    spawn(fn ->
      for _ <- Stream.cycle([:ok]) do
        pid(name)
        |> IO.inspect(label: "Killing #{inspect(name)}")
        |> Process.exit(:kill)

        pause(name)
        |> IO.inspect(label: "Between kills (ms)")
        |> Process.sleep()
      end
    end)
  end

  @spec new_games(pos_integer) :: [{Game.name(), Supervisor.on_start_child()}]
  def new_games(count) when count in 2..500 do
    Enum.reduce(0..(count - 2), [blue_moon()], fn _, acc ->
      [Game.haiku_name() | acc]
    end)
    |> Enum.map(fn name ->
      {name, Engine.new_game(name, Enum.random(@size_range))}
    end)
  end

  @spec mark_square(atom | binary, Square.phrase()) :: :ok
  def mark_square(target, phrase)
      when (is_atom(target) or is_binary(target)) and is_binary(phrase) do
    keep_killing(target) |> do_mark_square(phrase)
  end

  ## Private functions

  @spec do_mark_square(pid, Square.phrase()) :: :ok
  defp do_mark_square(killer_pid, phrase) do
    for _ <- 1..10 do
      Engine.mark_square(blue_moon(), phrase, ray())
      Process.sleep(10)
      Engine.game_pid(blue_moon())
    end
    |> Enum.any?(&is_nil/1)
    |> if(
      do: print_summary(killer_pid),
      else: do_mark_square(killer_pid, phrase)
    )
  end

  @spec print_summary(pid) :: :ok
  defp print_summary(killer_pid) do
    true = Process.exit(killer_pid, :kill)
    :ok = Engine.print_summary(blue_moon())
  end

  @spec pid(atom | binary) :: pid
  defp pid(name) when is_atom(name) do
    case Process.whereis(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        snooze() |> Process.sleep()
        pid(name)
    end
  end

  defp pid(name) when is_binary(name) do
    case Engine.game_pid(name) do
      pid when is_pid(pid) ->
        pid

      nil ->
        snooze() |> Process.sleep()
        pid(name)
    end
  end

  @spec pause(atom | binary) :: pos_integer
  defp pause(Buzzword.Bingo.Engine.DynGameSup),
    do: get_env(:between_dyn_sup_kills)

  defp pause(Buzzword.Bingo.Engine.GameSup),
    do: get_env(:between_sup_kills)

  defp pause(_), do: get_env(:between_server_kills)

  @spec snooze :: pos_integer
  defp snooze, do: get_env(:between_registration_checks)
end
