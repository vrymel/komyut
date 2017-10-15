defmodule WaypointsDirect.Route do
    use WaypointsDirect.Web, :model

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
