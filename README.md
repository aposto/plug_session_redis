PlugSessionRedis
================
[![hex.pm version](https://img.shields.io/hexpm/v/plug_session_redis.svg)](https://hex.pm/packages/plug_session_redis)

The Redis Plug.Session adapter for the Phoenix framework.
Poolboy + Redis.

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
  name: :redis_sessions,
  pool: [size: 2, max_overflow: 5],
  redis: [host: '127.0.0.1', port: 6379]
```

## endpoint.ex  
```elixir
plug Plug.Session,
  store: PlugSessionRedis.Store,
  key: "_my_app_key",       #
  table: :redis_sessions,   #  
  signing_salt: "123456",   #
  encryption_salt: "654321",#
  ttl: 360                  # use redis EXPIRE secs
```
