defmodule WaypointsDirect.DirectedDFS do

    alias WaypointsDirect.Graph
    
    def process_graph(graph, source) do
        dfs(graph, source, %{:marked => %{}})
    end

    defp dfs(graph, vertex, %{:marked => marked} = marker) do
        marked = unless Map.get(marked, vertex), do: Map.put(marked, vertex, false), else: marked

        unless marked[vertex] do
            marker = %{:marked => %{marked | vertex => true}}
            adjacent = Graph.adjacent(graph, vertex)

            case adjacent do
                [] -> 
                    marker
                nil ->
                    marker
                _ -> 
                    # TODO: find out why pattern matching is not working here. instead of calling arity [head | tail], this call itself.
                    do_dfs(graph, adjacent, marker)
            end
        else
            marker
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