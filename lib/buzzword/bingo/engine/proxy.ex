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

  @spec call(tuple | atom, String.t()) :: Summary.t() | :ok
  def call(request, game_name) do
    game_name |> Server.via() |> GenServer.call(request)
  catch
    :exit, reason ->
      Error.log(:exit, reason)
      wait_and_call(request, game_name, reason)
  end

  @spec stop(atom, String.t()) :: :ok
  def stop(reason, game_name) do
    game_name |> Server.via() |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Error.log(:exit, exit_reason)
      wait_and_stop(reason, game_name, exit_reason)
  end

  ## Private functions

  @spec wait_and_call(tuple | atom, String.t(), term) :: Summary.t() | :ok
  defp wait_and_call(request, game_name, reason) do
    game_name |> wait(reason, @times) |> Server.via() |> GenServer.call(request)
  catch
    :exit, reason ->
      Error.log(:exit, reason)
      game_name |> GameNotStarted.message() |> IO.puts()
  end

  @spec wait_and_stop(atom, String.t(), term) :: :ok
  defp wait_and_stop(reason, game_name, exit_reason) do
    game_name
    |> wait(exit_reason, @times)
    |> Server.via()
    |> GenServer.stop(reason)
  catch
    :exit, exit_reason ->
      Error.log(:exit, exit_reason)
      game_name |> GameNotStarted.message() |> IO.puts()
  end

  # On restarts, wait if name not yet registered...
  @spec wait(String.t(), term, non_neg_integer) :: String.t()
  defp wait(game_name, _reason, 0), do: game_name

  defp wait(game_name, reason, times_left) do
    Info.log(:game_not_registered, game_name, @timeout, times_left, reason)
    Process.sleep(@timeout)

    case Engine.game_pid(game_name) do
      pid when is_pid(pid) ->
        Info.log(:game_registered, game_name, pid, times_left, reason)
        game_name

      nil ->
        wait(game_name, reason, times_left - 1)
    end
  end
end
