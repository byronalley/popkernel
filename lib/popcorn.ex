defmodule Popcorn do
  @moduledoc """
  Documentation for `Popcorn`: functions that should be in Kernel but aren't.
  """

  @doc """
  Wrap the value in an :ok tuple
  """
  def ok(value), do: {:ok, value}

  @doc """
  Wrap the message in an :error tuple
  """
  def error(msg), do: {:error, msg}

  @doc """
  Maybe execute a function: if the param is an
  `{:ok, value}` tuple, then run the function on `value`.
  If it's an `{:error, msg}` tuple, return that.
  """
  def maybe({:ok, value}, f), do: f.(value)
  def maybe({:error, _} = error_tuple, _), do: error_tuple

  @doc """
  Macro to wrap a function call so that it returns a status tuple instead of raising an exception.
    iex> tuple_wrap(5 + 5)
    {:ok, 10}

    iex> tuple_wrap(div(10, 0))
    {:error, "bad argument in arithmetic expression"}

    iex> tuple_wrap(raise FunctionClauseError)
    {:error, "FunctionClauseError"}

  ## Returns
  * `{:ok, result}` on success
  * `{:error, "string message"}` if the exception has a non-nil message
  * `{:error, "ExceptionModule"}` otherwise
  """
  defmacro tuple_wrap(function_call) do
    quote do
      (fn ->
         try do
           {:ok, unquote(function_call)}
         rescue
           error ->
             case error do
               %{message: msg} when not is_nil(msg) -> {:error, msg}
               %{__struct__: type} -> {:error, inspect(type)}
             end
         end
       end).()
    end
  end
end
