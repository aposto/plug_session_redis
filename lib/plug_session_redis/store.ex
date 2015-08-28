

defmodule PlugSessionRedis.Store do
  @moduledoc """

  ## Options
   
  ## Examples
      
  """

  @behaviour Plug.Session.Store
  
  def init(opts) do

    {Keyword.fetch!(opts, :table), Keyword.get(opts, :ttl, :infinite)}
  end

  def get(_conn, sid, {table, _}) do
    case :poolboy.transaction(table, fn(client) ->
      :redo.cmd(client, ["GET", sid])
    end) do
      :undefined ->
        {nil, %{}}
      data ->
        {sid, :erlang.binary_to_term(data)}
    end
  end

  def put(_conn, nil, data, state) do
    put_new(data, state)
  end

  def put(_conn, sid, data, {table, _}) do
    :poolboy.transaction(table, fn(client) ->
      :redo.cmd(client, ["SET", sid, :erlang.term_to_binary(data)])
    end)
    sid
  end

  def delete(_conn, sid, {table, _}) do
    :poolboy.transaction(table, fn(client) ->
      :redo.cmd(client, ["DEL", sid])
    end)
    :ok
  end

  defp put_new(data, {table, ttl}, counter \\ 0)
      when counter < @max_tries do
    sid = :crypto.strong_rand_bytes(96) |> Base.encode64
    case :poolboy.transaction(table, fn(client) ->
      _store_data_with_ttl(client, ttl, sid, :erlang.term_to_binary(data))
    end) do
      "OK" ->
        sid
      _ ->
        put_new(data, table, counter + 1)
    end
  end

  defp _store_data_with_ttl(client, :infinite, sid, bin) do
    :redo.cmd(client, ["SET", sid, bin])
  end
  defp _store_data_with_ttl(client, ttl, sid, bin) do
    [ret, _] = :redo.cmd(client, [["SET", sid, bin], ["EXPIRE", sid, ttl]])
    ret
  end
end
