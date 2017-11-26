defmodule WaypointsDirect.Intersection do
    use WaypointsDirect.Web, :model

    schema "intersection" do
        field :lat, :float
        field :lng, :float

        timestamps()
    end
end