defmodule PhxTickets.Repo.Migrations.AddFieldsToComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :deleted, :boolean, default: false, null: false
    end

    create index(:comments, [:user_id])
  end
end
