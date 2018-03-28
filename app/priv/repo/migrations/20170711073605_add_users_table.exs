defmodule WaypointsDirect.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do 
      add :email, :string
      add :password, :string
      add :display_name, :string

      timestamps()
    end
  end
end
