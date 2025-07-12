defmodule PhxTickets.Repo.Migrations.CreateTickets do
  use Ecto.Migration

  def change do
    create table(:tickets) do
      add :title, :string
      add :description, :string
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
