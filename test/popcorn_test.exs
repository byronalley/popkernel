defmodule PopcornTest do
  use ExUnit.Case
  # doctest Popcorn

  import Popcorn

  describe "ok/1" do
    test "returns an ok tuple with the value embedded" do
      assert {:ok, :foo} = ok(:foo)
      assert {:ok, 99} = ok(99)
    end
  end

  describe "error/1" do
    assert {:error, :foo} = error(:foo)
    assert {:error, "message"} = error("message")
  end
end
