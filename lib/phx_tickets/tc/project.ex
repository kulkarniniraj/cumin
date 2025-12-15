defmodule PhxTickets.Tc.Project do
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :description, :string

    has_many :tickets, PhxTickets.Tc.Ticket

    timestamps()
  end

  @doc false
  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
