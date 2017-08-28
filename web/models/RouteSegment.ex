defmodule HelloPhoenix.RouteSegment do
    use HelloPhoenix.Web, :model

    schema "route_segments" do
        field :description, :string
        belongs_to :route, HelloPhoenix.Route
        has_many :waypoints, HelloPhoenix.RouteWaypoint

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:description])
        |> validate_required([:description])
    end
end