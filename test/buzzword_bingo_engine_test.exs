defmodule Buzzword.Bingo.EngineTest do
  use ExUnit.Case
  doctest Buzzword.Bingo.Engine

  test "greets the world" do
    assert Buzzword.Bingo.Engine.hello() == :world
  end
end
