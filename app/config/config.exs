# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :waypoints_direct,
  ecto_repos: [WaypointsDirect.Repo]

# Configures the endpoint
config :waypoints_direct, WaypointsDirectWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "79y/sq7ZjDjlnbYicNmzdwcaSTPB0wZjS+tMDtyNp6U18d12Hnu/PB/L5SlJWsoE",
  render_errors: [view: WaypointsDirectWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WaypointsDirect.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    auth0: { Ueberauth.Strategy.Auth0, [] },
  ]

# Configures Ueberauth's Auth0 auth provider
config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: System.get_env("AUTH0_DOMAIN"),
  client_id: System.get_env("AUTH0_CLIENT_ID"),
  client_secret: System.get_env("AUTH0_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
