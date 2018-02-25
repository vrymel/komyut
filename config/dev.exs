use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :waypoints_direct, WaypointsDirectWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]


# Watch static and templates for browser reloading.
config :waypoints_direct, WaypointsDirectWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/waypoints_direct_web/views/.*(ex)$},
      ~r{lib/waypoints_direct_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :waypoints_direct, WaypointsDirect.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "secretpassword",
  database: "waypoints_direct_dev",
  hostname: "0.0.0.0",
  pool_size: 10

config :sentry,
  dsn: "https://2a7117de9ab04e0faf325c15d760128b:f5d5aea8d8db447e962da878313e60ca@sentry.io/293948",
  environment_name: :dev,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!,
  tags: %{
    env: "development"
  },
  included_environments: [:dev]
