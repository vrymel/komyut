defmodule WaypointsDirectWeb.RouteManagementController do
    use WaypointsDirectWeb, :controller

    def new(conn, _params) do
        render conn, :new
    end
end