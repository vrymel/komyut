defmodule WaypointsDirectWeb.GraphApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Graph
    alias WaypointsDirect.GeoPoint
    alias WaypointsDirect.DijkstraShortestPath
    alias WaypointsDirect.RouteEdge
    alias WaypointsDirect.Intersection

    @within_radius 0.200 # within 200 meters radius
    @earth_radius 6371 # approximate radius of the Earth in km

    def search_path(conn, %{"from" => from_coordinates, "to" => to_coordinates}) do
      %{"lat" => from_lat, "lng" => from_lng} = Poison.decode! from_coordinates
      %{"lat" => to_lat, "lng" => to_lng} = Poison.decode! to_coordinates

      distance_limit = @within_radius * 3
      from_geopoint = GeoPoint.from_degrees(%GeoPoint{lat: from_lat, lng: from_lng})
      to_geopoint = GeoPoint.from_degrees(%GeoPoint{lat: to_lat, lng: to_lng})

      nearest_of_from = search_nearest_intersection(from_geopoint, @within_radius, distance_limit, @within_radius)
      nearest_of_to = search_nearest_intersection(to_geopoint, @within_radius, distance_limit, @within_radius)

      response_search_path(conn, nearest_of_from, nearest_of_to)
    end

    defp response_search_path(conn, %Intersection{:id => from_intersection_id}, %Intersection{:id => to_intersection_id}) do
        %{:path_exist => path_exist, :path => path} = do_search_path(build_graph(), from_intersection_id, to_intersection_id)

        if path_exist do
          # path is a list of route_edges, we need to translate it to
          # an intersection list so we end up with a complete path from
          # source to destination
          intersection_sequence = route_edge_path_to_intersection_sequence(path, build_route_edge_lookup_table())

          json conn, %{exist: path_exist, path: intersection_sequence}
        else
          json conn, %{exist: path_exist, path: []}
        end
    end

    # this is the response where one or both of the from and to locations has no
    # intersection near to it
    defp response_search_path(conn, :empty, :empty) do
        json conn, %{exist: false, path: [], nearest_none: true}
    end
    defp response_search_path(conn, _, _) do
        json conn, %{exist: false, path: [], nearest_none: true}
    end

    def search_nearest_intersection(geopoint, distance_increment, distance_limit, distance \\ 0) do
      within = distance / @earth_radius
      next_distance = distance + distance_increment
      result = get_nearest_intersection(geopoint, within)

      is_empty = result == :empty
      within_distance_limit = next_distance <= distance_limit
      proceed_greedy_search = is_empty and within_distance_limit

      if proceed_greedy_search do
        search_nearest_intersection(geopoint, distance_increment, distance_limit, next_distance)
      else
        result
      end
    end

    def get_nearest_intersection(%GeoPoint{:lat => lat, :lng => lng}, within_radius) do
      distance_formula = "acos(sin($1::float) * sin(lat_radian) + cos($1::float) * cos(lat_radian) * cos(lng_radian - ($2::float)))"
 
      query_result = Repo.query("
        SELECT 
        id, 
        #{distance_formula} AS relative_distance 
        FROM intersections 
        WHERE #{distance_formula} <= $3::float", [lat, lng, within_radius])

      case query_result do
        {:ok, %{num_rows: 0}} -> :empty
        {:ok, result} ->
          %{:rows => rows} = Map.take(result, [:rows])

          unless rows == [] do
            [nearest_id, _] = Enum.reduce rows, fn([_r_id, r_distance] = row, [_acc_id, acc_distance] = acc) ->
              if r_distance < acc_distance, do: row, else: acc
            end

            Repo.get(Intersection, nearest_id)
          end
        _ -> :empty
      end
    end

    defp do_search_path(graph, source, destination) do
      tree = DijkstraShortestPath.init_tree source
      tree = DijkstraShortestPath.build_tree graph, tree

      path_exist = DijkstraShortestPath.path_exist? tree, destination
      path_to = DijkstraShortestPath.path_to tree, destination
      
      %{path_exist: path_exist, path: path_to}
    end

    defp get_route_edges do
      query = from re in RouteEdge, 
        join: r in assoc(re, :route),
        join: fi in assoc(re, :from_intersection),
        join: ti in assoc(re, :to_intersection),
        where: r.is_active == true,
        preload: [from_intersection: fi, to_intersection: ti]

      Repo.all(query)
    end

    defp build_graph do
      get_route_edges() |> Enum.reduce(
          Graph.new(), 
          fn(re, graph) -> Graph.add_edge(graph, re) end
        )
    end

    defp build_route_edge_lookup_table do
      get_route_edges() |> Enum.reduce(%{}, fn(%RouteEdge{:route_id => route_id} = re, table) -> 
          intersection_pair = intersection_pair(re)
          bag = Map.get(table, intersection_pair)

          bag = if bag, do: MapSet.put(bag, route_id), else: MapSet.new() |> MapSet.put(route_id) 

          Map.put(table, intersection_pair, bag)
      end)
    end

    defp intersection_pair(%RouteEdge{:from_intersection_id => fid, :to_intersection_id => tid}), do: {fid, tid}

    defp route_edge_path_to_intersection_sequence(route_edge_path, lookup) do
      accumulator = %{previous_intersect: MapSet.new(), intersections: [] }

      # this intersections list only containers every :from_intersections of the route_edge list
      %{intersections: intersections} = Enum.reduce(
        route_edge_path, 
        accumulator, 
        fn(re, %{:previous_intersect => previous_intersect, :intersections => intersections}) -> 
          intersection_map = to_intersection_map(re, :from_intersection)
          route_ids = Map.get(lookup, intersection_pair(re))

          intersecting_route_ids = MapSet.intersection(previous_intersect, route_ids)

          case MapSet.size(intersecting_route_ids) do
            0 -> 
              [first_route_id | _] = MapSet.to_list(route_ids)
              intersection_map = Map.put(intersection_map, :route_id, first_route_id)

              %{previous_intersect: route_ids, intersections: [intersection_map | intersections]}
            _ -> 
              [first_route_id | _] = MapSet.to_list(intersecting_route_ids)
              intersection_map = Map.put(intersection_map, :route_id, first_route_id)

              %{previous_intersect: intersecting_route_ids, intersections: [intersection_map | intersections]}
          end
        end
      )

      # finally we add the destination intersection to the intersections list
      [ %{route_id: last_intersection_route_id} | _] = intersections
      [last_route_edge | _] = Enum.reverse(route_edge_path)
      last_intersection_map = to_intersection_map(last_route_edge, :to_intersection) |> Map.put(:route_id, last_intersection_route_id)

      Enum.reverse([last_intersection_map | intersections])
    end

    defp to_intersection_map(route_edge, target_intersection_key) do
      %{:lat => lat, :lng => lng, :id => id} = Map.get(route_edge, target_intersection_key)
    
      %{ intersection_id: id, lat: lat, lng: lng }
    end
end