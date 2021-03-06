use Mix.Config

config :batch_process_coordination, BatchProcessCoordinationWeb.Endpoint,
  http: [port: 4001],
  server: false

config :batch_process_coordination,
  process__impl: BatchProcessCoordination.ProcessMock,
  batch_key__impl: BatchProcessCoordination.BatchKeyMock

config :logger, level: :warn

config :batch_process_coordination, BatchProcessCoordination.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "batch_process_coordination_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
