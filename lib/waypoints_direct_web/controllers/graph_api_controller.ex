defmodule WaypointsDirectWeb.GraphApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Graph
    alias WaypointsDirect.DijkstraShortestPath
    alias WaypointsDirect.RouteEdge

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

        path_to_clean = Enum.map path_to, fn(%RouteEdge{:from_intersection_id => fromid}) -> fromid end

        IO.inspect path_to

        json conn, %{exist: path_exist, path_to: path_to_clean}
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