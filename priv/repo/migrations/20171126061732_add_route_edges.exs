defmodule WaypointsDirect.Repo.Migrations.AddRouteEdges do
  use Ecto.Migration

  def change do
    create table(:route_edges) do
      add :from_intersection_id, references(:intersection) 
      add :to_intersection_id, references(:intersection)
      add :route_id, references(:routes)

      timestamps()
    end
  end
end
