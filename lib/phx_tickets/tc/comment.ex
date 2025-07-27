defmodule PhxTickets.TC.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    field :ticket_id, :id
    belongs_to :user, PhxTickets.Accounts.User
    field :deleted, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :ticket_id, :user_id, :deleted])
    |> validate_required([:body, :ticket_id, :user_id])
    |> assoc_constraint(:user)
  end
end
