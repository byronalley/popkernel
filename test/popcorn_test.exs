defmodule PopcornTest do
  use ExUnit.Case
  doctest Popcorn

  test "greets the world" do
    assert Popcorn.hello() == :world
  end
end
