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

  describe "maybe/2" do
    test "with an ok tuple runs the function on the extracted value" do
      f = fn x -> 10 * x end

      assert 90 == maybe({:ok, 9}, f)

      assert "foo" == maybe({:ok, :foo}, &to_string/1)
    end

    test "with an error tuple runs the function on the extracted value" do
      assert {:error, "reason"} == maybe({:error, "reason"}, &Kernel.+/2)

      assert {:error, :reason} == maybe({:error, :reason}, &to_string/1)
    end
  end
end
