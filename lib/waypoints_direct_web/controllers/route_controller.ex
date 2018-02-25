defmodule WaypointsDirectWeb.RouteController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Route

    plug :secure

    defp secure(conn, _params) do
      user = get_session(conn, :current_user)
      case user do
        nil ->
          conn |> redirect(to: "/auth/auth0") |> halt
        _ ->
          conn |> assign(:current_user, user)
      end
    end

    def index(conn, _params) do
        routes = Repo.all(Route)

        render conn, :index, routes: routes
    end

    def new(conn, _params) do
        changeset = Route.changeset(%Route{})

        render conn, :new, changeset: changeset
    end
end
