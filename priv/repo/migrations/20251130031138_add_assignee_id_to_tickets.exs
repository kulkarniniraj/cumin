defmodule PhxTickets.Repo.Migrations.AddAssigneeIdToTickets do
  use Ecto.Migration

  def up do
    alter table(:tickets) do
      add :assignee_id, references(:users, on_delete: :nothing)
    end

    execute("UPDATE tickets SET assignee_id = user_id")
  end

  def down do
    alter table(:tickets) do
      remove :assignee_id
    end
  end
end
