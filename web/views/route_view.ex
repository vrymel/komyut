defmodule HelloPhoenix.RouteView do
    use HelloPhoenix.Web, :view

    def page_title("new.html", _assigns) do
	  	"Create new jeepney route"
	end

	def page_title("index.html", _assigns) do
		"Jeepney Routes"
	end

	def page_title("show.html", %{conn: %Plug.Conn{assigns: %{route: route}}}) do
		route.description
	end
end