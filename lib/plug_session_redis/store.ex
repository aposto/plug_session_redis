defmodule PlugSessionRedis.Store do
  @moduledoc """
  To configure and install, add in your plug pipeline code like the following:

  ```
  plug Plug.Session,
    store: PlugSessionRedis.Store,
    key: "_my_app_key",           # Cookie name where the id is stored
    table: :redis_sessions,       # Name of poolboy queue, make up anything
    signing_salt: "123456",       # Keep this private
    encryption_salt: "654321",    # Keep this private
    ttl: 360                      # Optional, defaults to :infinity
    serializer: CustomSerializer  # Optional, defaults to `PlugSessionRedis.BinaryEncoder`
  ```

  Custom Serializers can work to provide a way to encode and decode the data stored in Redis if you're integrating
  with a legacy system. You provide the module name that implements `encode/1`, `encode!/1`, `decode/1`, and `decode!/1`
  which is called by `Plug` when fetching and storing the session state back.
  """
  alias PlugSessionRedis.BinaryEncoder
  @behaviour Plug.Session.Store

  def init(opts) do
    {Keyword.fetch!(opts, :table), Keyword.get(opts, :ttl, :infinite), Keyword.get(opts, :serializer, BinaryEncoder)}
  end

  def get(_conn, sid, {table, _, serializer}) do
    case :poolboy.transaction(table, fn(client) ->
      :redo.cmd(client, ["GET", sid])
    end) do
      :undefined ->
        {nil, %{}}
      data ->
        {sid, serializer.decode!(data)}
    end
  end

  def put(_conn, nil, data, state) do
    put_new(data, state)
  end

  def put(_conn, sid, data, {table, _, serializer}) do
    :poolboy.transaction(table, fn(client) ->
      :redo.cmd(client, ["SET", sid, serializer.encode!(data)])
    end)
    sid
  end

  def delete(_conn, sid, {table, _, _}) do
    :poolboy.transaction(table, fn(client) ->
      :redo.cmd(client, ["DEL", sid])
    end)
    :ok
  end

  @max_tries 5
  defp put_new(data, {table, ttl, serializer}, counter \\ 0)
      when counter < @max_tries do
    sid = :crypto.strong_rand_bytes(96) |> Base.encode64
    case :poolboy.transaction(table, fn(client) ->
      store_data_with_ttl(client, ttl, sid, serializer.encode!(data))
    end) do
      "OK" ->
        sid
      _ ->
        put_new(data, {table, ttl, serializer}, counter + 1)
    end
  end

  defp store_data_with_ttl(client, :infinite, sid, bin) do
    :redo.cmd(client, ["SET", sid, bin])
  end
  defp store_data_with_ttl(client, ttl, sid, bin) do
    [ret, _] = :redo.cmd(client, [["SET", sid, bin], ["EXPIRE", sid, ttl]])
    ret
  end
end
