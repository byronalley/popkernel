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
end
