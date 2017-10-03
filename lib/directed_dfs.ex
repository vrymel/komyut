defmodule WaypointsDirect.DirectedDFS do

    alias WaypointsDirect.Graph
    
    def process_graph(graph, source) do
        marker = %{:marked => init_marker(graph)}

        dfs(graph, source, marker)
    end

    defp init_marker(graph) do
        do_init_marker(%{}, 0, graph.vertices_count - 1)    
    end

    defp do_init_marker(marker, current_count, count_limit) do
        if current_count <= count_limit do
            do_init_marker(Map.put(marker, current_count, false), current_count + 1, count_limit)
        else
            marker
        end
    end

    defp dfs(graph, vertex, %{:marked => marked} = marker) do
        marker = %{:marked => %{marked | vertex => true}}
        adjacent = Graph.adjacent(graph, vertex)
        [head | tail] = adjacent

        if !marked[head] do
            dfs(graph, head, marker)
        else
            do_dfs(graph, tail, marker)
        end
    end

    defp do_dfs(graph, adjacent, %{:marked => marked} = marker) do
        [head | tail] = adjacent

        if !marked[head] do
            dfs(graph, head, marker)
        end

        if Enum.empty? tail do
            marker
        end

        do_dfs(graph, tail, marker)
    end
end