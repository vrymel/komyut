defmodule WaypointsDirect.Route do
    use WaypointsDirectWeb, :model

    schema "routes" do
        field :description, :string
        field :is_active, :boolean, default: false
        has_many :route_edges, WaypointsDirect.RouteEdge

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:description])
        |> validate_required([:description])
    end
end
