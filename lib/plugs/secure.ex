defmodule WaypointsDirect.Plug.Secure do
    import Plug.Conn
    import Phoenix.Controller

    def init(default), do: default

    def call(conn, _default) do
      user = get_session(conn, :current_user)
      case user do
        nil ->
          conn |> redirect(to: "/auth/auth0") |> halt
        _ ->
          conn |> assign(:current_user, user)
      end
    end
end