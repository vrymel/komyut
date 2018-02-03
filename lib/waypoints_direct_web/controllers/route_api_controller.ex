defmodule WaypointsDirectWeb.RouteApiController do
    use WaypointsDirectWeb, :controller
    
    alias WaypointsDirect.Route
    alias WaypointsDirect.RouteEdge
    alias WaypointsDirect.RouteSegment
    alias WaypointsDirect.RouteWaypoint
    
    def show(conn, %{"id" => route_id}) do
        route = Repo.get(Route, route_id)
        |> Repo.preload(segments: from(s in RouteSegment, order_by: s.description))

        new_segments = Enum.map route.segments, 
        fn(segment) -> 
            Map.from_struct(segment) 
            |> Map.take([:description, :id])
        end
        
        payload = %{
            id: route.id,
            description: route.description,
            segments: new_segments
        }
        
        json conn, payload
    end

    def get_city_routes(conn, _params) do
        query = from r in Route, order_by: [desc: r.is_active, asc: r.description]
        routes = Repo.all(query)
        |> Enum.map(fn(route) ->
                Map.from_struct(route)
                |> Map.take([:description, :id, :is_active])
            end)

        json conn, routes
    end

    def get_segment_waypoints(conn, %{"segment_id" => segment_id}) do
        segment = Repo.get(RouteSegment, segment_id)
        |> Repo.preload(waypoints: from(w in RouteWaypoint, order_by: w.id))

        new_waypoints = Enum.map segment.waypoints, 
        fn(waypoint) -> 
            Map.from_struct(waypoint) 
            |> Map.take([:id, :lat, :lng])
        end

        json conn, new_waypoints
    end

    def create(conn, %{"route_name" => route_name, "raw_route_edges" => raw_route_edges}) do
      route_changeset = Route.changeset(%Route{}, %{description: route_name})
      success = false

      if route_changeset.valid? do
        case Repo.insert route_changeset do
          {:ok, route} -> 
            success = create_route_edges(route, raw_route_edges) == {:ok}
        end
      end

      json conn, %{"success" => success}
    end

    defp create_route_edges(route, raw_route_edges) do
      error = Enum.map(raw_route_edges, fn raw_re -> save_edge(route, raw_re) end)
      |> Enum.filter(
          fn(result) -> 
            case result do
              {:error, _} -> true
              _ -> false
            end
      end)

      if Enum.empty?(error) do
        {:ok}
      else
        {:error}
      end
    end

    defp save_edge(route, %{"start" => %{"id" => start_intersection_id}, "end" => %{"id" => end_intersection_id}}) do
      route_edge_map = %{from_intersection_id: start_intersection_id, to_intersection_id: end_intersection_id, weight: 1.0} # TODO: replace weight with something relevant to the actual edge, maybe distance between the points?
      route_edge_assoc = build_assoc(route, :route_edges, route_edge_map)

      Repo.insert route_edge_assoc
    end
end
