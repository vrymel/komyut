defmodule WaypointsDirect.Repo.Migrations.AddIntersectionTable do
  use Ecto.Migration

  def change do
    create table(:intersection) do
      add :lat, :float
      add :lng, :float

      timestamps()
    end
  end
end
