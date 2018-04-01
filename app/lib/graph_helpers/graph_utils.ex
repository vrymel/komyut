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
      %{:to_intersection => final_intersection, :from_intersection => leading_intersection } = last_edge

      intersection_list = [leading_intersection, final_intersection]
      intersection_list = Enum.reduce preceding_edges, intersection_list, fn(%{:from_intersection => fe}, acc) -> [fe | acc] end
    end
end