defmodule WaypointsDirect.Graph do

    def new(vertices) do
        bags = init_bag(vertices)

        %{vertices_count: 0, edges_count: 0, bags: bags}
    end

    defp init_bag(vertices) do
        do_init_bag(0, vertices - 1, %{})
    end

    defp do_init_bag(current_vertex, vertex_limit, bag) do
        if current_vertex <= vertex_limit do
            do_init_bag(current_vertex + 1, vertex_limit, Map.put(bag, current_vertex, [])) 
        else
            bag
        end
    end

    def adjacent do
        
    end

    def add_edge do
        
    end

end