defmodule WaypointsDirect.Repo.Migrations.AddRouteWaypointsTable do
  use Ecto.Migration

  def change do
    create table(:route_waypoints) do
      add :route_id, references(:routes)
      add :lat, :float
      add :long, :float
      add :order_value, :integer

      timestamps()
    end
  end
end
