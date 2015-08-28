PlugSessionRedis
================

Poolboy + Redis for Plug.Session

## Usage
```elixir
defp deps do
  [{:plug_session_redis, "~> 0.1" }]
end
```

## config.exs
```elixir
config :your_app, PlugSessionRedis.Redis.Pool,
  name: :session_pool,
  pool: [size: 2, max_overflow: 5],
  redis: [host: '127.0.0.1', port: 6379]
```

## EndPoint
```elixir
plug Plug.Session,
  store: :redis,
  key: "_my_app_key", # use a proper value 
  table: :redis_sessions, # <-- this on is hard coded into the plug
  signing_salt: "123456",   # use a proper value
  encryption_salt: "654321", # use a proper value
  ttl: 360                  # use redis EXPIRE secs
```
