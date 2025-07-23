defmodule PhxTickets.Repo.Migrations.AddDeletedField do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :deleted, :boolean, default: false
    end
  end
end
