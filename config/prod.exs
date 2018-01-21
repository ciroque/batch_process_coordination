use Mix.Config

config :batch_process_coordination, BatchProcessCoordinationWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :batch_process_coordination, BatchProcessCoordination.Web.Endpoint,
       secret_key_base: "uUlLlSnH+jY3RycnHM+MoH0KjyVwTNqsfeaVrzVnhtGYfidQoE9J5iSMNzy7eOjf"

config :batch_process_coordination, BatchProcessCoordination.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "postgres",
       password: "postgres",
       database: "batch_process_coordination_prod",
       pool_size: 15
