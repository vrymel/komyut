defmodule WaypointsDirect.RouteSegment do
    use WaypointsDirect.Web, :model

    schema "route_segments" do
        field :description, :string
        belongs_to :route, WaypointsDirect.Route
        has_many :waypoints, WaypointsDirect.RouteWaypoint

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:description])
        |> validate_required([:description])
    end
end
