use Mix.Config

config :batch_process_coordination, BatchProcessCoordination.Repo,
       adapter: Ecto.Adapters.Postgres,
       username: "postgres",
       password: "postgres",
       database: "batch_process_coordination",
       hostname: "soyoka.wagner-x.net",
       pool_size: 10
