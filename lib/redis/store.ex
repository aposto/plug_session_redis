

defmodule PlugSessionRedis.Redis.Store do
  @moduledoc """

  ## Options
    * `:table` - ETS table name (required)
  For more information on ETS tables, visit the Erlang documentation at
  http://www.erlang.org/doc/man/ets.html.
  ## Storage
  The data is stored in ETS in the following format:
      {sid :: String.t, data :: map, timestamp :: :erlang.timestamp}
  The timestamp is updated whenever there is a read or write to the
  table and it may be used to detect if a session is still active.
  ## Examples
      # Create an ETS table when the application starts
      :ets.new(:session, [:named_table, :public, read_concurrency: true])
      # Use the session plug with the table name
      plug Plug.Session, store: :ets, key: "sid", table: :session
  """

  @behaviour Plug.Session.Store
  @max_tries 100

  def init(opts) do
    {PlugSessionRedis.Redis.Pool.pool_name(), Keyword.get(opts, :ttl, :infinite)}
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
    IO.puts("**** Redis Session Delete")
   
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
