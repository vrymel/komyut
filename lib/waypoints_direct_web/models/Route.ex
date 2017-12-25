defmodule WaypointsDirect.Route do
    use WaypointsDirectWeb, :model

    schema "routes" do
        field :description, :string
        field :is_active, :boolean, default: false
        has_many :segments, WaypointsDirect.RouteSegment

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:description])
        |> validate_required([:description])
    end
end
