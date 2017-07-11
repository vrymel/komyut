defmodule HelloPhoenix.UserController do
    use HelloPhoenix.Web, :controller

    alias HelloPhoenix.User

    def index(conn, _params) do 
        render conn, :index
    end

    def new(conn, _params) do
        changeset = User.changeset(%User{})

        render conn, :new, changeset: changeset
    end

    def create(conn, %{"user" => param_user}) do
        changeset = User.changeset(%User{}, param_user)

        case Repo.insert(changeset) do
            {:ok, user} ->
                conn
                |> put_flash(:info, "User successfully created!")
                |> redirect(to: user_path(conn, :show, user.id))
        end

        render conn, :index
    end

    def show(conn, _params) do
        # TODO: catch id and display user details in template

        render conn, :show
    end
end