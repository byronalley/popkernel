defmodule Popcorn do
  @moduledoc """
  Documentation for `Popcorn`: functions that should be in Kernel but aren't.
  """

  @type ok_tuple :: {:ok, any()}
  @type error_tuple :: {:error, String.t() | atom}
  @type status_tuple :: ok_tuple() | error_tuple()
  @type maybe_any :: any() | nil

  @doc """
  Wrap the value in an :ok tuple. The main purpose of this function is to use at the end of a pipe:

    iex> %{foo: "bar"}
    iex> |> Map.get(:foo)
    iex> |> ok()
    {:ok, "bar"}
  """
  @spec ok(any()) :: ok_tuple()
  def ok(value), do: {:ok, value}

  @doc """
  Wrap the message in an :error tuple. The main purpose of this function is to use at the end of a pipe:
    iex> %{error: "fail"}
    iex> |> Map.get(:error)
    iex> |> error()
    {:error, "fail"}
  """
  @spec error(any()) :: error_tuple()
  def error(msg), do: {:error, msg}

  @doc """
  Given a status tuple, maybe execute a function:
  - If the param is an `{:ok, value}` tuple, then run the function
  on `value`.
  - If it's an `{:error, msg}` tuple, return that.

  This is mainly an alternative to using `with` blocks, so that
  you can pipe a function that returns a tuple, directly
  into another function that expects a simple value -- but only
  if it's a success tuple:

    iex> {:ok, 10}
    iex> |> Popcorn.bind(&to_string/1)
    "10"

    iex> {:error, :invalid}
    iex> |> Popcorn.bind(&to_string/1)
    {:error, :invalid}
  """
  @spec bind(status_tuple(), (any() -> status_tuple())) :: status_tuple()
  def bind({:ok, value}, f), do: f.(value)
  def bind({:error, _} = error_tuple, _), do: error_tuple

  @doc """
  Maybe execute a function if the given param is not nil:
  - If the param is not `nil`, then run the function on `value`.
  - If it's an `{:error, msg}` tuple, return that.

  This is mainly an alternative to using `with` blocks, so that
  you can pipe a function that returns a tuple, directly
  into another function that expects a simple value -- but only
  if it's a success tuple:

    iex> 10
    iex> |> Popcorn.maybe(&to_string/1)
    "10"

    iex> nil
    iex> |> Popcorn.maybe(&to_string/1)
    nil
  """
  @spec maybe(maybe_any(), (any -> any)) :: maybe_any()
  def maybe(nil, _f), do: nil
  def maybe(value, f), do: f.(value)

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
