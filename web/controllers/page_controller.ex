defmodule WaypointsDirect.PageController do
  use WaypointsDirect.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
