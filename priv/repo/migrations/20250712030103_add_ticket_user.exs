defmodule PhxTickets.Repo.Migrations.AddTicketUser do
  use Ecto.Migration

  def change do
    alter table(:tickets) do
      add :user_id, references(:users)
    end
  end
end
