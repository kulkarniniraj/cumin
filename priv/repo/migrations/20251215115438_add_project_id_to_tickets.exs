defmodule PhxTickets.Repo.Migrations.AddProjectIdToTickets do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :description, :text
      timestamps()
    end

    alter table(:tickets) do
      add :project_id, references(:projects, on_delete: :nothing), null: true
    end
  end
end
