# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :batch_process_coordination,
  ecto_repos: [BatchProcessCoordination.Repo]

# Configures the endpoint
config :batch_process_coordination, BatchProcessCoordinationWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "IbAAeXEPTHBdSnobCk4Grxb+nd3QJG9R8gNo+48GFC1uUGoZdJtX124f+lL9sAhF",
  render_errors: [view: BatchProcessCoordinationWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BatchProcessCoordination.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
