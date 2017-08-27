defmodule HelloPhoenix.Repo.Migrations.RemoveRouteIdInRouteWaypoints do
  use Ecto.Migration

  def change do
    alter table(:route_waypoints) do
      remove :route_id
    end
  end
end
