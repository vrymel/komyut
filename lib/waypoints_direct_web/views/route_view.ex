defmodule WaypointsDirectWeb.RouteView do
    use WaypointsDirectWeb, :view

    def googleMapApiKey do
        System.get_env("GOOGLE_MAP_API_KEY")
    end
end
