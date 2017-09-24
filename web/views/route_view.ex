defmodule WaypointsDirect.RouteView do
    use WaypointsDirect.Web, :view

    def googleMapApiKey do
        System.get_env("GOOGLE_MAP_API_KEY")
    end
end
