defmodule WaypointsDirectWeb.GraphApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Graph
    alias WaypointsDirect.GeoPoint
    alias WaypointsDirect.DijkstraShortestPath
    alias WaypointsDirect.Route
    alias WaypointsDirect.RouteEdge
    alias WaypointsDirect.Intersection
    alias WaypointsDirect.GraphUtils

    @within_radius 0.200 # within 200 meters radius
    @earth_radius 6371 # approximate radius of the Earth in km

    @allowed_direct_path_length 100 # allowed hops for direct path search, this is an arbitrary value

    def search_path(conn, %{"from" => from_coordinates, "to" => to_coordinates}) do
      %{"lat" => from_lat, "lng" => from_lng} = Poison.decode! from_coordinates
      %{"lat" => to_lat, "lng" => to_lng} = Poison.decode! to_coordinates

      distance_limit = @within_radius * 3
      from_geopoint = GeoPoint.from_degrees(%GeoPoint{lat: from_lat, lng: from_lng})
      to_geopoint = GeoPoint.from_degrees(%GeoPoint{lat: to_lat, lng: to_lng})

      nearest_of_from = search_nearest_intersection(from_geopoint, @within_radius, distance_limit, @within_radius)
      nearest_of_to = search_nearest_intersection(to_geopoint, @within_radius, distance_limit, @within_radius)

      do_search_path(conn, nearest_of_from, nearest_of_to)
    end

    defp do_search_path(conn, %Intersection{:id => from_intersection_id}, %Intersection{:id => to_intersection_id}) do
        direct_path = search_direct_path(from_intersection_id, to_intersection_id)

        case direct_path do 
          :empty ->
            graph_path = search_graph_path(from_intersection_id, to_intersection_id)

            json conn, %{:exist => graph_path != :empty, path: graph_path}
          _ ->
            graph_path = search_graph_path(from_intersection_id, to_intersection_id)
            shortest_path = get_shortest_path(direct_path, graph_path)
                        
            json conn, %{:exist => shortest_path != :empty, path: shortest_path} 
        end
    end

    # this is the response where one or both of the from and to locations has no
    # intersection near to it
    defp do_search_path(conn, :empty, :empty) do
        json conn, %{exist: false, path: [], nearest_none: true}
    end
    defp do_search_path(conn, _, _) do
        json conn, %{exist: false, path: [], nearest_none: true}
    end

    defp get_shortest_path(direct_path, graph_path) do
      direct_path_length = Enum.count(direct_path)

      if direct_path_length < @allowed_direct_path_length do
        direct_path
      else
        graph_path
      end
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
  
    defp get_closest_direct_route(direct_routes) when is_list(direct_routes) do
      # Get the route that has the lowest intersections, this is our naive approach to finding the 
      # closest route to the destination. If we have proper route edge weight values, we should use that 
      # instead of just counting the number of intersections to find the closest route.
      Enum.reduce(direct_routes, nil, fn(route_segment_path, current_lowest_route_segment) -> 
        {:ok, _, direct_path} = route_segment_path

        path_length = Enum.count(direct_path)
        lowest_path_count = case current_lowest_route_segment do
          {:ok, _, lowest_direct_path} -> Enum.count(lowest_direct_path)
          _ -> nil
        end

        if path_length < lowest_path_count do
          route_segment_path
        else
          current_lowest_route_segment
        end
      end)
    end

    defp get_closest_direct_route(_), do: :empty

    defp search_direct_path(source, destination) do
      closest_route = do_search_direct_path(source, destination) |> get_closest_direct_route()

      case closest_route do
        {:ok, %Route{:id => route_id}, direct_path} ->
          Enum.map(direct_path, 
            fn(%Intersection{:id => id, :lat => lat, :lng => lng}) -> 
                %{intersection_id: id, lat: lat, lng: lng, route_id: route_id} 
            end
          )
        _ ->
        :empty
      end
    end

    defp do_search_direct_path(source, destination) do
      query_result = Repo.query("
        SELECT r.id FROM route_edges re
          JOIN routes r ON r.id = re.route_id
        WHERE re.route_id IN (SELECT route_id FROM route_edges WHERE from_intersection_id = $1::int)
          AND to_intersection_id = $2::int
      ", [source, destination])

      case query_result do
        {:ok, %{num_rows: 0}} -> :empty
        {:ok, %{rows: rows}} -> 
          Enum.map(rows, fn([route_id]) -> 
            prepare_route_segment(route_id, source, destination)
          end)
        _ -> :empty
      end
    end

    defp prepare_route_segment(route_id, source, destination) do
      query = from r in Route, 
        where: r.id == ^route_id,
        join: re in assoc(r, :route_edges), 
        join: fi in assoc(re, :from_intersection),
        join: ti in assoc(re, :to_intersection),
        order_by: re.id,
        preload: [route_edges: {re, from_intersection: fi, to_intersection: ti}]

      route = Repo.one query

      intersection_list = 
        route 
        |> Map.get(:route_edges) 
        |> GraphUtils.route_edges_to_intersection_list
        |> segment_route_from_search_intersections(source, destination)
      
      {:ok, route, intersection_list}
    end


    defp segment_route_from_search_intersections(intersection_list, start_segment, end_segment, segment_list \\ [], ignored_intersections \\ [])

    defp segment_route_from_search_intersections([%Intersection{:id => intersection_id} = head | next_intersections], start_segment, end_segment, segment_list, ignored_intersections) do
      segment_started = !Enum.empty?(segment_list)

      is_start_segment = start_segment == intersection_id
      is_end_segment = end_segment == intersection_id

      # if the segment is already started but we incountered another start_segment
      duplicate_start_segment = is_start_segment and segment_started

      cond do
        is_end_segment and segment_started ->
          Enum.reverse([head | segment_list])
        duplicate_start_segment ->
          # If there is a duplicate start_segment, recreate the segment_list again with the current head (the duplicate segment start)
          # and ignore the existing segment list by joining it to the ignored intersections list.
          # We do this since the duplicate start_segment is the closest to the destination intersection.
          segment_route_from_search_intersections(next_intersections, start_segment, end_segment, [head], Enum.concat(segment_list, ignored_intersections))
        is_start_segment or segment_started ->
          segment_route_from_search_intersections(next_intersections, start_segment, end_segment, [head | segment_list], ignored_intersections)
        true ->
          segment_route_from_search_intersections(next_intersections, start_segment, end_segment, segment_list, [head | ignored_intersections])
      end
    end

    # This clause will be meet if we exhausted the intersection_list, so we cycle back to the beginning of the intersection_list
    # using the ignored_intersections list (the intersections that we ignored and not part of the segment_list. The intersection_list 
    # will be exhausted if the end_segment intersection appeared before the start_segment end_segment.
    defp segment_route_from_search_intersections([], start_segment, end_segment, segment_list, ignored_intersections) do
      ignored_intersections |> Enum.reverse() |> segment_route_from_search_intersections(start_segment, end_segment, segment_list, [])
    end

    def search_graph_path(source, destination) do
      %{:path_exist => path_exist, :path => path} = do_search_graph_path(build_graph(), source, destination)

      # if path_exist do
        # path is a list of route_edges, we need to translate it to
        # an intersection list so we end up with a complete path from
        # source to destination
        # route_edge_path_to_intersection_sequence(path, build_route_edge_lookup_table())
      # else
        # :empty
      # end
    end
    
    defp do_search_graph_path(graph, source, destination) do
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

    def build_route_edge_lookup_table do
      get_route_edges() |> Enum.reduce(%{}, fn(%RouteEdge{:route_id => route_id} = re, table) -> 
          intersection_pair = intersection_pair(re)
          bag = Map.get(table, intersection_pair)

          bag = if bag, do: MapSet.put(bag, route_id), else: MapSet.new() |> MapSet.put(route_id) 

          Map.put(table, intersection_pair, bag)
      end)
    end

    defp intersection_pair(%RouteEdge{:from_intersection_id => fid, :to_intersection_id => tid}), do: {fid, tid}

    # iex> GraphApiController.route_segment_tagging(path, lookup)
    def segment_tagging(route_edge_path, lookup) do
      intersection_list = 
        route_edge_path
        |> Enum.map(fn(route_edge) -> prepare_route_edge_tag(route_edge, lookup) end)
        # |> IO.inspect(charlists: :as_lists)
        |> do_segment_tagging()
    end

    defp route_accessible_match(%{:route_accessible => first_route_accessible}, %{:route_accessible => second_route_accessible}) do
      intersection = MapSet.intersection(first_route_accessible, second_route_accessible)
      intersection_size = MapSet.size(intersection)

      {intersection, intersection_size}
    end

    def do_segment_tagging(route_edge_list, tagged \\ [], pending \\ [])

    # last two remaining
    def do_segment_tagging([first | [second | []]], tagged, pending) do
      {intersection, size} = route_accessible_match(first, second)

      case size do
        # 1 ->
          # route_id = intersection |> MapSet.to_list() |> List.first()
          # first = first |> Map.put(:route_id, route_id) |> Map.put(:route_accessible, intersection)
          # second = second |> Map.put(:route_id, route_id) |> Map.put(:route_accessible, intersection)

          # [second, first | tagged]
        _ -> 
          route_id = intersection |> MapSet.to_list() |> List.first()
          first = first |> Map.put(:route_id, route_id) |> Map.put(:route_accessible, intersection)
          second = second |> Map.put(:route_id, route_id) |> Map.put(:route_accessible, intersection)

          [second, first | tagged]
      end
    end

    def do_segment_tagging([first | [second | others]], tagged, pending) do
      {intersection, size} = route_accessible_match(first, second)

      case size do
        0 ->
          route_id = first |> Map.get(:route_accessible) |> MapSet.to_list() |> List.first()
          n_route_accessible = MapSet.new() |> MapSet.put(route_id)
          first = first |> Map.put(:route_id, route_id) |> Map.put(:route_accessible, n_route_accessible)

          if pending != [] do
            pending = do_segment_tagging([first | pending]) |> Enum.reverse()

            do_segment_tagging([second | others], Enum.concat(pending, tagged))
          else
            do_segment_tagging([second | others], [first | tagged], pending)
          end
        1 -> 
          route_id = intersection |> MapSet.to_list() |> List.first()
          first = first |> Map.put(:route_id, route_id) |> Map.put(:route_accessible, intersection)
          second = Map.put(second, :route_accessible, intersection)

          if pending != [] do
            pending = do_segment_tagging([first | pending])

            do_segment_tagging([second | others], Enum.concat(pending, tagged))
          else
            do_segment_tagging([second | others], [first | tagged], pending)
          end

        _ ->
          first = Map.put(first, :route_accessible, intersection)
          second = Map.put(second, :route_accessible, intersection)

          do_segment_tagging([second | others], tagged, [first | pending])
      end
    end

    defp tag_route_edge(route_id, route_edge) when is_integer(route_id)  do
      route_edge = Map.put(route_edge, :route_id, route_id)

      # this route_edge is now complete, so clear route_accessible
      tag_route_edge(MapSet.new(), route_edge)
    end

    defp tag_route_edge(intersection, route_edge) when is_map(intersection) do
      Map.put(route_edge, :route_accessible, intersection)
    end

    defp tag_route_edge() do
      # multiple intersection

      # set intersection to first and second 
      # then assign to first to pending
    end

    defp prepare_route_edge_tag(route_edge, lookup) do
      pair_key = intersection_pair(route_edge)
      route_accessible = Map.get(lookup, pair_key)

      route_edge
      |> Map.take([:from_intersection, :to_intersection, :from_intersection_id, :to_intersection_id, :id])
      |> Map.put(:route_accessible, route_accessible)
    end

    defp route_edge_path_to_intersection_sequence(route_edge_path, lookup) do
      accumulator = %{previous_intersect: MapSet.new(), intersections: []}

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