defmodule WaypointsDirectWeb.LandingController do
    use WaypointsDirectWeb, :controller

    def index(conn, _params) do
        render conn, :index
    end
end