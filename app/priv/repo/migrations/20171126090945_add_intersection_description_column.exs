defmodule WaypointsDirect.Repo.Migrations.AddIntersectionDescriptionColumn do
  use Ecto.Migration

  def change do
    alter table(:intersection) do
      add :description, :string
    end
  end
end
