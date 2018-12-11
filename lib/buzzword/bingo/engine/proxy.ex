defmodule Buzzword.Bingo.Engine.Proxy do
  @moduledoc """
  Runs function `GenServer.call` on behalf of module `Buzzword.Bingo.Engine`
  while providing increased fault-tolerance capability.
  """

  alias __MODULE__.{Error, GameNotStarted, Info}
  alias Buzzword.Bingo.Engine.Server
  alias Buzzword.Bingo.{Engine, Summary}

  @timeout 10
  @times 5

  @spec call(tuple | atom, String.t(), tuple) :: Summary.t() | :ok
  def call(request, game_name, caller) do
    game_name |> Server.via() |> GenServer.call(request)
  catch
    :exit, reason ->
      Error.log(:exit, reason, caller)
      wait_and_call(request, game_name, caller)
  end

  @spec stop(atom, String.t(), tuple) :: Summary.t() | :ok
  def stop(reason, game_name, caller) do
    game_name |> Server.via() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Error.log(:exit, exit_reason, caller)
      wait_and_stop(reason, game_name, caller)
  end

  ## Private functions

  @spec wait_and_call(tuple | atom, String.t(), tuple) :: Summary.t() | :ok
  defp wait_and_call(request, game_name, caller) do
    game_name |> wait(caller, @times) |> Server.via() |> GenServer.call(request)
  catch
    :exit, reason ->
      Error.log(:exit, reason, caller)
      game_name |> GameNotStarted.message() |> IO.puts()
  end

  @spec wait_and_stop(atom, String.t(), tuple) :: Summary.t() | :ok
  defp wait_and_stop(reason, game_name, caller) do
    game_name |> wait(caller, @times) |> Server.via() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Error.log(:exit, exit_reason, caller)
      game_name |> GameNotStarted.message() |> IO.puts()
  end

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), tuple, non_neg_integer) :: String.t()
  defp wait(game_name, _caller, 0), do: game_name

  defp wait(game_name, caller, times_left) do
    Info.log(:game_not_registered, game_name, @timeout, times_left, caller)
    Process.sleep(@timeout)

    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        Info.log(:game_registered, game_name, pid, times_left, caller)
        game_name

      nil ->
        wait(game_name, caller, times_left - 1)
    end
  end
end
