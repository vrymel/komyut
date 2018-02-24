defmodule WaypointsDirect.Repo.Migrations.RemoveWaypointsAndSegmentsTable do
  use Ecto.Migration

  def change do
    drop table(:route_waypoints)
    drop table(:route_segments)
  end
end
