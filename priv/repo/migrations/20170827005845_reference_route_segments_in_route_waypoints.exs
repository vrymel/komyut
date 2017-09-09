defmodule WaypointsDirect.Repo.Migrations.ReferenceRouteSegmentsInRouteWaypoints do
  use Ecto.Migration

  def change do
    alter table(:route_waypoints) do
      add :route_segment_id, references :route_segments
    end
  end
end
