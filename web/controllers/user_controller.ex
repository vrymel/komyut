defmodule HelloPhoenix.UserController do
    use HelloPhoenix.Web, :controller

    def index(conn, _params) do 
        render conn, :index
    end
end