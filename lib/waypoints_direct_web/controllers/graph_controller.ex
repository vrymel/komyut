defmodule WaypointsDirectWeb.GraphController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Graph
    alias WaypointsDirect.DirectedDFS
    alias WaypointsDirect.RouteEdge

    def search_possible_route(conn, %{"from_intersection_id" => from_intersection_id, "to_intersection_id" => to_intersection_id}) do
      {source, _} = Integer.parse(from_intersection_id)
      {destination, _} = Integer.parse(to_intersection_id)

      if source == :error or destination == :error do
        json conn, %{success: false, error: "Invalid intersection source and destination"}
      else
        graph = build()
        dfs = DirectedDFS.process_graph(graph, source)

        has_path = Map.get(dfs.marked, destination)

        json conn, %{has_path: has_path, marked: dfs, graph: graph} 
      end
    end

    defp build() do
      route_edges = Repo.all RouteEdge 

      Enum.reduce route_edges, Graph.new, 
        fn(re, graph) -> 
          graph = Graph.add_edge graph, re 
        end
    end
end