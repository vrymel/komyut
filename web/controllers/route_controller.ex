defmodule HelloPhoenix.RouteController do
    use HelloPhoenix.Web, :controller

    alias HelloPhoenix.Route

    def index(conn, _params) do
        render conn, :index
    end

    def new(conn, _params) do
        changeset = Route.changeset(%Route{})

        render conn, :new, changeset: changeset
    end

    def create(conn, %{"route" => route_param}) do
        changeset = Route.changeset(%Route{}, route_param)

        case Repo.insert(changeset) do
            {:ok, route} ->
                conn 
                |> put_flash(:info, "New route created!")
                |> redirect(to: route_path(conn, :show, route.id))
            {:error, error_changeset} ->
                IO.inspect(error_changeset)
                conn 
                |> put_flash(:error, "Could not create route, please try again")
                |> render(:new, changeset: error_changeset)
        end
    end

    def show(conn, %{"id" => route_id}) do
        route = Repo.get!(Route, route_id)

        render conn, :show, route: route
    end
end