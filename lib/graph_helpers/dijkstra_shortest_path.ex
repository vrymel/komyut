defmodule WaypointsDirect.DijkstraShortestPath do
  alias WaypointsDirect.IndexMinPQ
  alias WaypointsDirect.Graph
  alias WaypointsDirect.RouteEdge

  def init_tree(source) do
    pq = IndexMinPQ.new |> IndexMinPQ.insert(%{key: source, value: 0.0})

    %{edge_to: %{}, dist_to: %{}, pq: pq}
  end

  def path_to(%{:edge_to => edge_to} = tree, vertex, path \\ []) do
    route_edge = Map.get(edge_to, vertex)

    if route_edge do
      path_to tree, Map.get(route_edge, :from_intersection_id), [route_edge | path]
    else
      path
    end
  end

  def path_exist?(%{:edge_to => edge_to}, vertex) do
    if Map.get(edge_to, vertex), do: true, else: false
  end

  def build_tree(graph, %{:pq => pq} = tree) do
    lowest_weight = IndexMinPQ.get_min(pq)
    pq = IndexMinPQ.remove(pq, lowest_weight)
    tree = Map.put(tree, :pq, pq)

    adjacent = Graph.adjacent(graph, Map.get(lowest_weight, :key))

    if adjacent do
      tree = Enum.reduce adjacent, tree, fn(route_edge, acc) ->
        relax(acc, route_edge)
      end
    end

    pq = Map.get(tree, :pq)

    # don't stop until pq is empty
    if IndexMinPQ.empty?(pq), do: tree, else: build_tree(graph, tree)
  end

  defp relax(%{:edge_to => edge_to, :dist_to => dist_to, :pq => pq} = tree, %RouteEdge{:from_intersection_id => v, :to_intersection_id => w, :weight => edge_weight} = route_edge) do
    v_weight = Map.get(dist_to, v)
    w_weight = Map.get(dist_to, w)

    # if w_weight is null
    unless w_weight do
      w_weight_new = unless v_weight, do: edge_weight, else: edge_weight + v_weight

      # assign to tree
      dist_to = Map.put(dist_to, w, w_weight_new)
      edge_to = Map.put(edge_to, w, route_edge)
      pq = assign_pq pq, %{key: w, value: w_weight_new}
    else
      if w_weight > (v_weight + edge_weight) do
        # assign to tree
        dist_to = Map.put(dist_to, w, (v_weight + edge_weight) )
        edge_to = Map.put(edge_to, w, route_edge) 
        pq = assign_pq pq, %{key: w, value: (v_weight + edge_weight)}
      end
    end

    tree |> Map.put(:dist_to, dist_to) |> Map.put(:edge_to, edge_to) |> Map.put(:pq, pq)
  end

  defp assign_pq(pq, %{:key => key, :value => _} = key_value) do
    find = IndexMinPQ.find_by_key pq, key

    if find do
      pq = IndexMinPQ.remove pq, find
    end

    IndexMinPQ.insert pq, key_value
  end

end