defmodule WaypointsDirect.Repo.Migrations.AddRouteEdgeWeight do
  use Ecto.Migration

  def change do
    alter table(:route_edges) do
      add :weight, :float
    end
  end
end
