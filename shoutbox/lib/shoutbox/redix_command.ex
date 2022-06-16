defmodule Redix.Command do

  def init, do: []


  # Redix.Command.execute(["SET", "item:51", "100"])
  # Redix.Command.execute ["DBSIZE"]

  def execute(cmd) do
    redis_command(:redis_pool, cmd)
  end

  defp redis_command(redis_pool, redis_command) do
    :poolboy.transaction(redis_pool, fn conn ->
      do_redix_command(conn, redis_command)
    end)
  end

  defp do_redix_command(conn, command) do
    case Redix.command(conn, command) do
      ok = {:ok, _} ->
        ok
      err = {:error, _} ->
        IO.puts "[REDIS] Command #{inspect command} failed, reason #{inspect err}"
        err
    end
  end

end
