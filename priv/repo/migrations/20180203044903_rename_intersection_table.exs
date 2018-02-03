defmodule WaypointsDirect.Repo.Migrations.RenameIntersectionTable do
  use Ecto.Migration

  def change do
    rename table(:intersection), to: table(:intersections)
  end
end
