defmodule Buzzword.Bingo.EngineTest do
  use ExUnit.Case, async: true

  alias Buzzword.Bingo.Engine

  doctest Engine

  test "the truth" do
    assert 1 + 2 == 3
  end
end
