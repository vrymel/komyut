defmodule WaypointsDirect.GraphUtils do
    alias WaypointsDirect.RouteEdge

    def route_edges_to_intersection_list(route_edges) do
      # we reverse the route_edges so when we append the intersections
      # into a list using [new | old_list], it will be in order 
      # also reverse is needed so we can easily get the last edge of the route edges of the route
      [last_edge | preceding_edges] = Enum.reverse route_edges

      # we get to_intersection and from_intersection of the last edge
      # and pre-populate the intersection list with them
      # not doing so, will make it tricky to get the last intersection of the path
      # since we are only appending the from_intersection of the other edges to the intersections list
      # %{:to_intersection => final_intersection, :from_intersection => leading_intersection } = last_edge

      leading_intersection = get_clean_edge_intersection(last_edge, :from_intersection)
      final_intersection = get_clean_edge_intersection(last_edge, :to_intersection)

      intersection_list = [leading_intersection, final_intersection]
      intersection_list = 
      preceding_edges 
      |> Enum.reduce(intersection_list, 
        fn(edge, acc) -> 
          clean = get_clean_edge_intersection(edge, :from_intersection)

          [clean | acc] 
        end)
    end

    defp get_clean_edge_intersection(%{:route_id => route_id} = edge, source_key) do
      intersection = Map.get(edge, source_key) 
      intersection_id = Map.get(intersection, :id)

      intersection
      |> Map.from_struct()
      |> Map.take([:lat, :lng]) 
      |> Map.put(:route_id, route_id) 
      |> Map.put(:intersection_id, intersection_id)
    end
end