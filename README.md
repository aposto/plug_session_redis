PlugSessionRedis
================

Poolboy + Redis for Plug.Session

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

## EndPoint
```elixir
plug Plug.Session,
  store: PlugSessionRedis.Store,
  key: "_my_app_key", # use a proper value 
  table: :redis_sessions, # <-- this on is hard coded into the plug
  signing_salt: "123456",   # use a proper value
  encryption_salt: "654321", # use a proper value
  ttl: 360                  # use redis EXPIRE secs
```
