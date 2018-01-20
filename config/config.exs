use Mix.Config

config :batch_process_coordination,
  ecto_repos: [BatchProcessCoordination.Repo]

config :batch_process_coordination,
  process_maintenance_impl: BatchProcessCoordination.ProcessMaintenance

config :batch_process_coordination, BatchProcessCoordinationWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IbAAeXEPTHBdSnobCk4Grxb+nd3QJG9R8gNo+48GFC1uUGoZdJtX124f+lL9sAhF",
  render_errors: [view: BatchProcessCoordinationWeb.ErrorView, format: "json", accepts: ~w(json)],
  pubsub: [name: BatchProcessCoordination.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env}.exs"
