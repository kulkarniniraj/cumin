defmodule PhxTickets.Repo.Migrations.AddTicketParent do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :parent_id, references(:tickets)
      add :type, :string
    end
  end
end
