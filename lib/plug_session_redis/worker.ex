defmodule PlugSessionRedis.Worker do

  @spec start_link({module, Keyword.t}) :: {:ok, pid}
  def start_link({module, params}) do
    module.start_link(:undefined, params)
  end
end
