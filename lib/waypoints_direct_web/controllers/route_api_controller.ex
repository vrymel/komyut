defmodule WaypointsDirectWeb.RouteApiController do
    use WaypointsDirectWeb, :controller
    
    alias WaypointsDirect.Route
    alias WaypointsDirect.RouteEdge
    alias WaypointsDirect.Intersection
    alias WaypointsDirect.RouteWaypoint
    alias WaypointsDirect.GraphUtils

    def index(conn, _params) do
        query = from r in Route, order_by: [desc: r.is_active, asc: r.description]
        routes = Repo.all(query)
        |> Enum.map(fn(route) ->
                Map.from_struct(route)
                |> Map.take([:description, :id, :is_active])
            end)

        json conn, routes
    end
    
    def show(conn, %{"id" => route_id}) do
        query = from r in Route, 
            where: r.id == ^route_id,
            join: re in assoc(r, :route_edges), 
            join: fi in assoc(re, :from_intersection),
            join: ti in assoc(re, :to_intersection),
            order_by: re.id,
            preload: [route_edges: {re, from_intersection: fi, to_intersection: ti}]

        route = Repo.one query

        intersection_list = GraphUtils.route_edges_to_intersection_list(Map.get(route, :route_edges))
        intersection_list_encode_safe = Enum.map intersection_list, 
            fn(%Intersection{:id => id, :lat => lat, :lng => lng}) -> 
                %{id: id, lat: lat, lng: lng} 
            end

        json conn, %{success: true, intersections: intersection_list_encode_safe}
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
