defmodule HelloPhoenix.Route do
    use HelloPhoenix.Web, :model

    schema "routes" do
        field :description, :string
        has_many :waypoints, HelloPhoenix.RouteWaypoint

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:description])
        |> validate_required([:description])
    end
end