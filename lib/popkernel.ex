defmodule Popkernel do
  @moduledoc """
  Documentation for `Popkernel`: functions that should be in Kernel but aren't.
  """

  @type result_atom :: :ok | :error

  @type ok_tuple :: {:ok, any()}
  @type error_tuple :: {:error, String.t() | atom}
  @type result_tuple :: ok_tuple() | error_tuple()
  @type maybe_any :: any() | nil

  @type result :: result_atom() | result_tuple()

  defmacro __using__(_) do
    quote do
      require Popkernel
      import Popkernel
    end
  end

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
  Given a Monadic type such as a result tuple, (maybe) execute a function based on the wrapped value, that returns a Monad of the same type. The bind/2 function delegates to the Popkernel.Monad.bind/2 protocol.

  It's implemented for result tuples. For example:
  - If the param is an `{:ok, value}` tuple, then run the function
  on `value`.
  - If it's an `{:error, msg}` tuple, return that.

  This is mainly an alternative to using `with` blocks, so that you can pipe a function that returns a tuple, directly into another function that expects a simple value -- but only if it's an ok tuple:

    iex> {:ok, [1, 2, 3]}
    iex> |> bind(& Enum.fetch(&1, 0))
    {:ok, 1}

    iex> {:error, :invalid}
    iex> |> bind(&to_string/1)
    {:error, :invalid}

  Note that you can't give it an `:ok` atom as input because there's no clearly defined behaviour for this: it's not an error but also shouldn't be expected to be used as input directly into another function.

  This is still a clunky interface: see the ~> operator
  for a cleaner approach.
  """
  defdelegate bind(monad, f), to: Monad

  @doc """
  Macro to wrap an expression so that it returns a result tuple instead of raising an exception.

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
  defmacro tuple_wrap(expression) do
    quote do
      (fn ->
         try do
           {:ok, unquote(expression)}
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

  @doc """
  Shorter alias for the identity function (Function.identity/1)

  The downside is that it could conflict with using `id` as a variable name.
  """
  @spec id(term) :: term
  defdelegate id(term), to: Function, as: :identity

  @doc """
  Bind alias

  iex> {:ok, "666F6F"} ~> Base.decode16()
  {:ok, "foo"}

  iex> {:ok, "invalid date"} ~> NaiveDateTime.from_iso8601()
  {:error, :invalid_format}

  iex> {:ok, "invalid"} ~> Base.decode16()
  :error

  iex> {:error, :oops} ~> Base.decode16()
  {:error, :oops}

  TODO: Anonymous functions aren't working yet
  Eg:

  # iex> user = %{id: 1234, name: "Jim Bob"}
  # iex> get_id = & Map.fetch(&1, :id)
  # iex> get_id.(user)
  # {:ok, 1234}
  # iex> {:ok, user} ~> get_id1.()
  # {:ok, 1234}
  # iex> {:error, "reason"} ~> get_id2.()
  # {:error, "reason"}

  """
  defmacro left ~> right do
    case right do
      # x ~> Module.function()
      {{:., _, [{:__aliases__, _context, modules}, function]}, _context2, []} ->
        module = Module.safe_concat(modules)

        quote do
          bind(
            unquote(left),
            &(unquote(module).unquote(function) / 1)
          )
        end

      # x ~> Module.function
      {{:., _context1, [{function, _context2, nil}]}, _context3, []} ->
        function = {function, [], Elixir}

        quote do
          bind(unquote(left), unquote(function))
        end

      # FIXME
      # x ~> function
      {function, context, atom} when is_atom(atom) ->
        f = {function, context, atom}

        quote do
          bind(unquote(left), unquote(f))
        end

      # FIXME
      # x ~> function.() - Pass the function variable directly
      {{:., [], [function]}, [], []} ->
        quote do
          bind(unquote(left), var!(unquote(function)))
        end

      # Handle multiple args — maybe this should be allowed?
      {{:., _, [{:__aliases__, _context, modules}, function]}, _context2, args} ->
        module = Module.safe_concat(modules)

        raise "Compiler Error: ~> operator expected #{module}.#{function} to receive one argument, got additional: #{inspect(args)}"

      other ->
        raise "Compiler Error: #{inspect(other)}"
    end
  end

  @doc """
  Unwraps an ok tuple and pulls out the value.
  iex> {:ok, "value"}
  iex> |> unwrap()
  "value"

  If it's not an ok tuple, raise an exception.

  iex> {:error, :reason}
  iex> |> unwrap()
  ** (ArgumentError) expected :ok tuple but got: {:error, :reason}
  """
  @spec unwrap(result_tuple() | :error) :: term | no_return
  def unwrap({:ok, any}), do: any
  def unwrap(other), do: raise(ArgumentError, "expected :ok tuple but got: #{inspect(other)}")

  @doc """
  Unwraps an ok tuple and returns the value.

  iex> {:ok, "value"}
  iex> |> unwrap_or("unused")
  "value"

  Or if it's not an ok tuple, return an alternate default value.

  iex> {:error, :reason}
  iex> |> unwrap_or("default")
  "default"

  iex> :error
  iex> |> unwrap_or("default")
  "default"

  Note that only :ok tuples, :error tuples, and :error are supported.

  iex> %{this: "does not work"}
  iex> |> unwrap_or("default")
  ** (ArgumentError) expected :ok tuple but got: %{this: "does not work"}
  """
  @spec unwrap_or(result_tuple() | :error, term) :: term
  def unwrap_or({:ok, value}, _), do: value
  def unwrap_or({:error, _reason}, default), do: default
  def unwrap_or(:error, default), do: default

  def unwrap_or(other, _),
    do: raise(ArgumentError, "expected :ok tuple but got: #{inspect(other)}")

  @doc """
  Extract a value from an :ok tuple or else raise a custom exception.

  iex> {:ok, "value"}
  iex> |> or_raise("unused error")
  "value"

  iex> {:error, :reason}
  iex> |> or_raise("Error Message")
  ** (RuntimeError) Error Message

  """
  @spec or_raise(term, String.t()) :: term | no_return
  def or_raise({:ok, value}, _message), do: value
  def or_raise(_, message), do: raise(message)

  @doc """
  The &&& operator adapts the idea of && (with values that might
  be nil) to result tuples.

  It's a shorthand way of returning the last success point or
  first failure.

    iex> {:ok, "happy"} &&& {:ok, "success"}
    {:ok, "success"}

    iex> {:ok, "happy"} &&& {:error, "failure"}
    {:error, "failure"}

    iex> {:error, "failure"} &&& {:ok, "happy"}
    {:error, "failure"}

    TODO: This should be made a macro so we can have short circuit evaluation.
  """
  def result1 &&& result2 do
    case {result1, result2} do
      {{:ok, _}, result_tuple} -> result_tuple
      {{:error, _} = err, _} -> err
      _ -> raise ArgumentError
    end
  end

  @doc """
  The ||| operator adapts the idea of || (with values that might
  be nil) to result tuples.

  It's a shorthand way of returning either the first success point or last failure.

    iex> {:ok, "happy"} ||| {:ok, "success"}
    {:ok, "happy"}

    iex> {:ok, "happy"} ||| {:error, "failure"}
    {:ok, "happy"}

    iex> {:error, "failure"} ||| {:ok, "happy"}
    {:ok, "happy"}

    iex> {:error, "failure"} ||| {:error, "oops"}
    {:error, "oops"}

    TODO: This should be made a macro so we can have short circuit evaluation.
  """
  def result1 ||| result2 do
    case {result1, result2} do
      {{:ok, _} = success, _} -> success
      {{:error, _}, result} -> result
      _ -> raise ArgumentError
    end
  end
end
