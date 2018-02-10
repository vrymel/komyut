defmodule WaypointsDirectWeb.GraphApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Graph
    alias WaypointsDirect.DijkstraShortestPath
    alias WaypointsDirect.RouteEdge
    alias WaypointsDirect.Intersection

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

        path_to_clean = Enum.map path_to, fn(%RouteEdge{:from_intersection => from_intersection}) -> 
          from_intersection |> Map.take([:id, :lat, :lng])
        end

        json conn, %{exist: path_exist, path_to: path_to_clean}
      end
    end

    defp build() do
      query = from re in RouteEdge, 
        join: fi in assoc(re, :from_intersection),
        preload: [from_intersection: fi]
      route_edges = Repo.all query

      Enum.reduce route_edges, Graph.new, 
        fn(re, graph) -> 
          graph = Graph.add_edge graph, re 
        end
    end
end