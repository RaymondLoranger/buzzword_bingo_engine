defmodule Buzzword.Bingo.Engine.Proxy.GameNotStarted do
  alias IO.ANSI

  @spec message(String.t()) :: ANSI.ansilist()
  def message(game_name) do
    [
      :blue_background,
      :light_white,
      "Game ",
      :light_green,
      "#{game_name}",
      :light_white,
      " not started."
    ]
    |> ANSI.format()
  end
end
