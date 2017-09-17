PlugSessionRedis
================
[![hex.pm version](https://img.shields.io/hexpm/v/plug_session_redis.svg)](https://hex.pm/packages/plug_session_redis)

The Redis Plug.Session adapter for the Phoenix framework.
Poolboy + Redis.

## 1

## Usage
```elixir
# mix.exs
def application do
  [applications: [..., :plug_session_redis]]
end

defp deps do
  [{:plug_session_redis, "~> 0.1" }]
end
```

## config.exs
```elixir
config :plug_session_redis, :config,
  name: :redis_sessions,    # Can be anything you want, should be the same as `:table` config below
  pool: [size: 2, max_overflow: 5],
  redis: [host: '127.0.0.1', port: 6379]
```

## endpoint.ex  
```elixir
plug Plug.Session,
  store: PlugSessionRedis.Store,
  key: "_my_app_key",           #
  table: :redis_sessions,       # Can be anything you want, should be same as `:name` config above
  signing_salt: "123456",       #
  encryption_salt: "654321",    #
  ttl: 360,                     # use redis EXPIRE secs
  serializer: CustomSerializer, # Optional, defaults to `PlugSessionRedis.BinaryEncoder`
  path: &MyPath.path/1          # Optional, defaults to passing the session ID through unmodified
```

## Custom Serializers

Change the above serializer to your own implementation that has an `encode/1`, `decode/1`, `encode!/1` and `decode!/1` functions.

An example serializer is shown in `lib/plug_session_redis/binary_encoder.ex`. For data serialized by Ruby, you can use [ex_marshal](https://github.com/gaynetdinov/ex_marshal).

## Storing data in another key

The `:path` option above when configuring the plug lets you define a function which will take in the session ID binary string and returns a new storage location. If you'd like, for example, to store all sessions under the key `"myapp:sessions:" <> id` then an example implementation of the above configured `MyPath.path/1` would look like this:

```elixir
defmodule MyPath do
  def path(sid) do
    "myapp:sessions:" <> sid
  end
end
```

*NOTE*: Plug does not allow passing in an anonymous function, it will have to be a named function as shown above.
