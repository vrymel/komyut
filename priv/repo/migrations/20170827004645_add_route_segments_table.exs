defmodule WaypointsDirect.Repo.Migrations.AddRouteSegmentsTable do
  use Ecto.Migration

  def change do
    create table(:route_segments) do
      add :route_id, references(:routes)
      add :description, :string

      timestamps()
    end
  end
end
