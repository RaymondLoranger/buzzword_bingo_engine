defmodule Buzzword.Bingo.Engine.HaikuName do
  @moduledoc """
  Generates a unique, URL-friendly name such as "bold-frog-8249".
  """

  use PersistConfig

  @adjectives get_env(:haiku_adjectives)
  @nouns get_env(:haiku_nouns)

  @doc """
  Generates a unique, URL-friendly name such as "bold-frog-8249".
  """
  @spec generate :: String.t()
  def generate do
    [Enum.random(@adjectives), Enum.random(@nouns), :rand.uniform(9999)]
    |> Enum.join("-")
  end
end
