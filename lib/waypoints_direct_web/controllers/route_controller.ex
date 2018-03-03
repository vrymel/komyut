defmodule WaypointsDirectWeb.RouteController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Route

    def index(conn, _params) do
        routes = Repo.all(Route)

        render conn, :index, routes: routes
    end
end
