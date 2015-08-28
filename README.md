PlugSessionRedis
================

config.exs

config :your_app, PlugSessionRedis.Redis.Pool,
  name: :session_pool,
  pool: [size: 2, max_overflow: 5],
  redis: [host: '58.121.156.234', port: 6379]


plug Plug.Session,
  store: :redis,
  key: "_my_app_key", # use a proper value 
  table: :redis_sessions, # <-- this on is hard coded into the plug
  signing_salt: "123456",   # use a proper value
  encryption_salt: "654321", # use a proper value
  ttl: 360                  # use redis EXPIRE secs