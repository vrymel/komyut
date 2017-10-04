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

        case adjacent do
            [] -> 
                marker
            _ -> 
                # TODO: find out why pattern matching is not working here. instead of calling arity [head | tail], this call itself.
                do_dfs(graph, adjacent, marker)
        end
    end

    defp do_dfs(graph, [head | tail], %{:marked => _} = marker) do
        marker = dfs(graph, head, marker)

        case tail do
            [] ->
                marker
            _ ->
                do_dfs(graph, tail, marker)
        end
    end
end