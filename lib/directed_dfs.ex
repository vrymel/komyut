defmodule WaypointsDirect.DirectedDFS do

    alias WaypointsDirect.Graph
    
    def process_graph(graph, source) do
        %{:marked => init_marker(graph)}
    end

    defp init_marker(graph) do
        do_init_marker(0, graph.vertices_count - 1, %{})    
    end

    defp do_init_marker(current_count, count_limit, marker) do
        if current_count <= count_limit do
            do_init_marker(current_count + 1, count_limit, Map.put(marker, current_count, false))
        else
            marker
        end
    end

    defp dfs(graph, vertex, marker) do
    end
end