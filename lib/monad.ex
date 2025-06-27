defprotocol Monad do
  @moduledoc """
  A Protocol for handling Monads in a reasonably
  idiomatic Elixir way

  Functions:
  - bind(monad, value_to_monad_function)
  - return(type, value)

  A default implementation is included for Tuples, which
  due to the way protocols work, will be called for any
  length of tuple but only handles tagged result tuples like:
  - {:ok, value}
  - {:error, reason}
  """

  @doc """
  This is intended to extract the value from a monad
  and pass it to a function that returns a monad.
  """
  def bind(monad, value_to_monad_function)

  @doc """
  Wraps the value as a type of Monad. This is a bit
  awkward since while it would probably be more natural to
  do:

  monad = Monad.return(Tuple, 99)

  Instead we have to do this:

  monad = Monad.return({}, 99)
  {:ok, 99}
  """
  def return(type, value)
end

defimpl Monad, for: Tuple do
  @spec bind(
          Popkernel.result_tuple() | :error,
          (any() -> Popkernel.result_tuple() | Popkernel.result_atom())
        ) :: Popkernel.result_tuple()
  def bind({:ok, value}, f), do: f.(value)
  def bind({:error, _} = error_tuple, _), do: error_tuple
  def bind(:error), do: :error

  def return(_, value), do: {:ok, value}
end
