defmodule HelloPhoenix.Repo.Migrations.AddRoutesTable do
  use Ecto.Migration

  def change do
    create table(:routes) do 
      add :description, :string

      timestamps()
    end
  end
end
