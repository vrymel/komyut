defmodule WaypointsDirectWeb.GraphApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Graph
    alias WaypointsDirect.GraphUtils
    alias WaypointsDirect.GeoPoint
    alias WaypointsDirect.DijkstraShortestPath
    alias WaypointsDirect.RouteEdge
    alias WaypointsDirect.Intersection

    def search_path_near(conn, _params) do
      # TODO: 
      # get source intersection and destination intersection
      source = GeoPoint.from_degrees(%GeoPoint{lat: 80.485273, lng: 124.646718})
      result = get_nearest_intersection(source, (0.137/6371))

      # TODO:
      # after we have the source and destination intersection 
      # use search_path to get the path

      json conn, %{success: true}
    end

    defp get_nearest_intersection(%GeoPoint{:lat => lat, :lng => lng}, radius) do
      distance_formula = "acos(sin($1::float) * sin(lat_radian) + cos($1::float) * cos(lat_radian) * cos(lng_radian - ($2::float)))"
 
      query_result = Repo.query("
        SELECT 
        id, 
        #{distance_formula} AS relative_distance 
        FROM intersections 
        WHERE #{distance_formula} <= $3::float", [lat, lng, radius])

      case query_result do
        {:ok, result} ->
          %{:rows => rows } = Map.take(result, [:rows])

          unless rows == [] do
            Enum.reduce rows, fn([r_id, r_distance] = row, [acc_id, acc_distance] = acc) ->
              if r_distance < acc_distance, do: row, else: acc
            end
          end
        _ -> 
          nil
      end
    end

    def search_path(conn, %{"from_intersection_id" => from_intersection_id, "to_intersection_id" => to_intersection_id}) do
      {source, _} = Integer.parse(from_intersection_id)
      {destination, _} = Integer.parse(to_intersection_id)

      if source == :error or destination == :error do
        json conn, %{success: false, error: "Invalid intersection source and destination"}
      else
        graph = build()

        tree = DijkstraShortestPath.init_tree source
        tree = DijkstraShortestPath.build_tree graph, tree

        path_exist = DijkstraShortestPath.path_exist? tree, destination
        path_to = DijkstraShortestPath.path_to tree, destination

        # path_to is a list of route_edges, we need to translate it to
        # an intersection list so we end up with a complete path from
        # source to destination
        intersection_list = GraphUtils.route_edges_to_intersection_list path_to

        path_to_clean = Enum.map intersection_list, fn(from_intersection) -> 
          from_intersection |> Map.take([:id, :lat, :lng])
        end

        json conn, %{exist: path_exist, path: path_to_clean}
      end
    end

    defp build() do
      query = from re in RouteEdge, 
        join: fi in assoc(re, :from_intersection),
        join: ti in assoc(re, :to_intersection),
        preload: [from_intersection: fi, to_intersection: ti]
      route_edges = Repo.all query

      Enum.reduce route_edges, Graph.new, 
        fn(re, graph) -> 
          graph = Graph.add_edge graph, re 
        end
    end
end