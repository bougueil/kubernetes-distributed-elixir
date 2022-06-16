defmodule Redis.Connection do

  @type redis_params :: Keyword.t()

  @spec pool_name() :: :redis_pool
  def pool_name, do: :redis_pool

  @doc "Returns the specification for starting the connection pool under a Supervisor."
  @spec child_spec(any()) :: :supervisor.child_spec()
  def child_spec(_) do
    :poolboy.child_spec(
      pool_name(),
      [
        name: {:local, pool_name()},
        worker_module: Redix,
        size: 50 # 6 # 50
      ],
      sentinel_options()
    )
  end

  defp sentinel_options() do
    [
      # --- dev env specific params
      backoff_max: 1000,
      backoff_initial: 30,
      # --- dev env specific params

      sync_connect: true,
      sentinel: [
        group: "mymaster",
        sentinels: sentinels(),
      ]
    ]
  end

  defp sentinels() do
    ["redis://redis-redis-ha-announce-0.default.svc.cluster.local:26379",
     "redis://redis-redis-ha-announce-1.default.svc.cluster.local:26379",
     "redis://redis-redis-ha-announce-2.default.svc.cluster.local:26379"
    ]
  end


end
