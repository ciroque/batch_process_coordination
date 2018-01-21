use Mix.Config

config :batch_process_coordination, BatchProcessCoordinationWeb.Endpoint,
  on_init: {Exertrax.Web.Endpoint, :load_from_system_env, []},
  http: [port: {:system, "BPC_PORT"}, ip: {0,0,0,0}]

config :logger, level: :info

config :batch_process_coordination, BatchProcessCoordination.Web.Endpoint,
       secret_key_base: "uUlLlSnH+jY3RycnHM+MoH0KjyVwTNqsfeaVrzVnhtGYfidQoE9J5iSMNzy7eOjf"

config :batch_process_coordination, BatchProcessCoordination.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "postgres",
       password: "postgres",
       database: "batch_process_coordination",
       hostname: "database-host",
       pool_size: 15
