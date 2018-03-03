defmodule WaypointsDirectWeb.BaseViewHelper do
    def googleMapApiKey do
        System.get_env("GOOGLE_MAP_API_KEY")
    end

    def sentryFrontendDsn do
        System.get_env("SENTRY_FRONTEND_DSN")
    end
end
