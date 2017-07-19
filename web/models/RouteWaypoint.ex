defmodule HelloPhoenix.RouteWaypoint do
    use HelloPhoenix.Web, :model

    schema "route_waypoints" do
        field :lat, :float
        field :long, :float
        field :order_value, :integer
        belongs_to :route, HelloPhoenix.Route

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:lat, :long])
        |> validate_required([:lat, :long])
    end
end