defmodule WaypointsDirectWeb.RouteView do
    use WaypointsDirectWeb, :view

    def googleMapApiKey do
        System.get_env("GOOGLE_MAP_API_KEY")
    end

    def sentryClientDsn do
        System.get_env("SENTRY_CLIENT_DSN")
    end
end
