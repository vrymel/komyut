defmodule WaypointsDirect.Intersection do
    use WaypointsDirect.Web, :model

    schema "intersection" do
        field :lat, :float
        field :lng, :float

        timestamps()
    end

    def changeset(intersection, params \\ %{}) do
        intersection
        |> cast(params, [:lat, :lng])
        # |> validate_required([:lat, :lng]) # temporarily disable validation for testing
    end
end