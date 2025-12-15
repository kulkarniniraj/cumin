defmodule PhxTickets.Repo.Migrations.AddActiveProjectIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :active_project_id, references(:projects, on_delete: :nothing), null: true
    end
  end
end
