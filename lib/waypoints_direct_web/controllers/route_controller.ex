defmodule WaypointsDirectWeb.RouteController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Route

    def index(conn, _params) do
        routes = Repo.all(Route)

        render conn, :index, routes: routes
    end

    def new(conn, _params) do
        changeset = Route.changeset(%Route{})

        render conn, :new, changeset: changeset
    end
end
