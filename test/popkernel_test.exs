defmodule PopkernelTest do
  use ExUnit.Case

  doctest Popkernel, import: true

  use Popkernel

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

  describe "bind/2" do
    test "with an ok tuple runs the function on the extracted value" do
      f = fn x -> {:ok, 10 * x} end

      assert {:ok, 90} == bind({:ok, 9}, f)
    end

    test "with an error tuple simply returns the error" do
      assert {:error, "reason"} == bind({:error, "reason"}, &Kernel.+/2)

      assert {:error, :reason} == bind({:error, :reason}, &to_string/1)
    end
  end

  describe "tuple_wrap/1" do
    defmodule ErrorException do
      defexception [:message]
    end

    test "returns ok tuple if function succeeds" do
      assert {:ok, 5} == tuple_wrap(10 / 2)

      assert {:ok, "FOO"} == tuple_wrap(String.upcase("foo"))
    end

    test "returns error tuple with string message if function raises error with message" do
      assert {:error, "bad argument in arithmetic expression"} = tuple_wrap(10 / 0)
    end

    test "if function raises an error without a message, returns error tuple with module name as string" do
      f = fn -> raise FunctionClauseError end
      assert {:error, "FunctionClauseError"} = tuple_wrap(f.())
    end

    test "when message is nil, returns error tuple with module name as string" do
      f = fn -> raise FunctionClauseError end
      assert {:error, "FunctionClauseError"} = tuple_wrap(f.())
    end
  end

  describe "id/1" do
    test "returns self for different types" do
      data = [1, :a, [], {:ok, "string"}, %{a: 5}]

      assert data == Enum.map(data, &id/1)
    end
  end
end
