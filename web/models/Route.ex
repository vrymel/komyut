defmodule HelloPhoenix.Route do
    use HelloPhoenix.Web, :model

    schema "routes" do
        field :description, :string

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:description])
        |> validate_required([:description])
    end
end