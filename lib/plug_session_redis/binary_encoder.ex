defmodule PlugSessionRedis.BinaryEncoder do
  def encode(data) do
    {:ok, encode!(data)}
  end

  def encode!(data) do
    :erlang.term_to_binary(data)
  end

  def decode(data) do
    try do
      {:ok, decode!(data)}
    rescue
      reason -> {:error, reason}
    end
  end

  def decode!(data) do
    :erlang.binary_to_term(data)
  end
end
