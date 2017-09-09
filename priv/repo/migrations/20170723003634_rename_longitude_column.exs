defmodule WaypointsDirect.Repo.Migrations.RenameLongitudeColumn do
  use Ecto.Migration

  def change do
    rename table(:route_waypoints), :long, to: :lng
  end
end
