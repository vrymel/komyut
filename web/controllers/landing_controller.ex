defmodule WaypointsDirect.LandingController do
    use WaypointsDirect.Web, :controller

    def index(conn, _params) do
        render conn, :index
    end
end