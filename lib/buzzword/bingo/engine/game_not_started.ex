defmodule Buzzword.Bingo.Engine.GameNotStarted do
  alias IO.ANSI

  @spec message(String.t()) :: ANSI.ansilist()
  def message(game_name) do
    [
      :red_background,
      :light_white,
      "Game ",
      :black,
      "#{game_name}",
      :light_white,
      " not started."
    ]
  end
end
