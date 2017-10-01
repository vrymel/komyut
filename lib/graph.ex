defmodule WaypointsDirect.Graph do

    def new(vertices) do
        bags = init_bag(vertices)

        %{:vertices_count => vertices, :edges_count => 0, :bags => bags}
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

    def add_edge(%{:bags => bags, :edges_count => edges_count} = graph, v, w) do
        %{^v => v_bag, ^w => w_bag} = bags
        bags = bags |> put_in([v], [w | v_bag]) |> put_in([w], [v | w_bag])

        %{graph | :bags => bags, :edges_count => edges_count + 1}
    end

    def adjacent(%{:bags => bags}, vertex) do
        bags[vertex]
    end

end