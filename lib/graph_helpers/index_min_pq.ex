defmodule WaypointsDirect.IndexMinPQ do
    def new() do [] end

    def insert(pq, %{:key => _, :value => _} = key_value) do
      [key_value | pq]
    end

    def get_min(pq) do
      Enum.min_by pq, fn(%{:value => value}) -> value end 
    end

    def remove(pq, del_key_value) do
      Enum.filter pq, fn(key_value) -> key_value !== del_key_value end
    end

    def is_empty(pq) do Enum.empty?(pq) end
end