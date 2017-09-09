defmodule WaypointsDirect.RouteWaypoint do
    use WaypointsDirect.Web, :model

    schema "route_waypoints" do
        field :lat, :float
        field :lng, :float
        field :order_value, :integer
        belongs_to :route_segment, WaypointsDirect.Route

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:lat, :lng])
        |> validate_required([:lat, :lng])
    end
end
