defmodule HelloPhoenix.User do
    use HelloPhoenix.Web, :model

    schema "users" do 
        field :email, :string
        field :password, :string
        field :display_name, :string

        timestamps()
    end

    def changeset(struct, params \\ %{}) do
        struct
        |> cast(params, [:email, :password, :display_name])
        |> validate_required([:email, :password, :display_name])
    end
end