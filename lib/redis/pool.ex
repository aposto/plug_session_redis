
defmodule PlugSessionRedis.Redis.Pool do

  def pool_name() do
    conf[:name]
  end

  def pool_spec() do
    worker_args = {:redo, conf[:redis]}
    child_spec(conf[:name], conf[:pool], worker_args)
  end

  defp conf do
    Application.get_env(:game_phoenix, __MODULE__)
  end

  defp child_spec(pool_name, pool_args, redis_args) do
    strategy = Keyword.get(pool_args, :strategy, :fifo)
    pool_args = [strategy: strategy, name: {:local, pool_name}, worker_module: PlugSessionRedis.Redis.Worker] ++ pool_args

    :poolboy.child_spec(pool_name, pool_args, redis_args)
  end


end
