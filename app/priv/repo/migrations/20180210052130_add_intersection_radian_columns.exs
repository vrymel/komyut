defmodule WaypointsDirect.Repo.Migrations.AddIntersectionRadianColumns do
  use Ecto.Migration

  def change do
    alter table(:intersections) do
      add :lat_radian, :float
      add :lng_radian, :float
    end
  end
end
