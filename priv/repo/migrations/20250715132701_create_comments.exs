defmodule PhxTickets.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :string
      add :ticket_id, references(:tickets, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:ticket_id])
  end
end
