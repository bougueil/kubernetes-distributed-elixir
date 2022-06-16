defmodule Manip do
  @moduledoc """
  Shoutbox keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def size_redis(), do: Redix.Command.execute ["DBSIZE"]
  def flushdb(), do: Redix.Command.execute ["FLUSHDB"]

  def commands(n) do
    Enum.reduce(1..n, fn i,_ ->
      Redix.Command.execute ["SET", "item:#{i}", "100"]
      Redix.Command.execute ["INCR", "item:#{i}"]
      Redix.Command.execute ["APPEND", "item:#{i}", "xxx"]
      Redix.Command.execute ["GET", "item:#{i}"]
      IO.puts "#{DateTime.utc_now()} #{i}"
      Process.sleep(20)
    end)
  end

  def master_connection() do
    :poolboy.transaction :redis_pool,  fn conn -> conn end
    |> :sys.get_state()
  end
end
