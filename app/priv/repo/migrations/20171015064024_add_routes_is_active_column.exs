defmodule WaypointsDirect.Repo.Migrations.AddRoutesIsActiveColumn do
  use Ecto.Migration

  def change do
    alter table(:routes) do
      add :is_active, :boolean, default: false
    end
  end
end
