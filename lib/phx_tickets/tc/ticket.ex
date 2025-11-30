defmodule PhxTickets.TC.Ticket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tickets" do
    field :status, :string
    field :description, :string
    field :title, :string
    field :type, :string
    belongs_to :user, PhxTickets.Accounts.User
    belongs_to :parent, __MODULE__, foreign_key: :parent_id, type: :id
    belongs_to :assignee, PhxTickets.Accounts.User, foreign_key: :assignee_id
    has_many :children, __MODULE__, foreign_key: :parent_id
    field :deleted, :boolean, default: false
    has_many :comments, PhxTickets.TC.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ticket, attrs) do
    IO.inspect(attrs, label: "Ticket Changeset Attributes")
    ticket
    |> cast(attrs, [:title, :description, :status, :deleted, :user_id, :parent_id, :type, :assignee_id])
    |> validate_required([:title, :status, :user_id, :type])
    |> assoc_constraint(:user)
    |> assoc_constraint(:parent)
    |> assoc_constraint(:assignee)
    |> put_change(:status, Map.get(attrs, "status", "open"))
  end

end
