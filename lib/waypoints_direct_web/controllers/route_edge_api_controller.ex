defmodule WaypointsDirectWeb.RouteEdgeApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.RouteEdge

    def create(conn, %{"raw_route_edges" => raw_route_edges}) do
      error = Enum.map(raw_route_edges, &save_edge/1)
      |> Enum.filter(
          fn(result) -> 
            case result do
              {:error, _} -> true
              _ -> false
            end
      end)

      json conn, %{success: Enum.empty?(error)}
    end

    defp save_edge(%{"start" => %{"id" => start_intersection_id}, "end" => %{"id" => end_intersection_id}}) do
      # TODO: add route_id
      route_edge = %RouteEdge{from_intersection_id: start_intersection_id, to_intersection_id: end_intersection_id}

      Repo.insert route_edge
    end
end