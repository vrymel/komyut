defmodule WaypointsDirectWeb.RouteController do
    use WaypointsDirectWeb, :controller

    def index(conn, _params) do
        render conn, :index
    end
end
