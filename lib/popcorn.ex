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
end
