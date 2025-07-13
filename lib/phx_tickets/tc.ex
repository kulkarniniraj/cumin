defmodule PhxTickets.TC do
  @moduledoc """
  The TC context.
  """

  import Ecto.Query, warn: false
  alias PhxTickets.Repo

  alias PhxTickets.TC.Ticket

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets()
      [%Ticket{}, ...]

  """
  def list_tickets do
    Repo.all(Ticket)
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(123)
      %Ticket{}

      iex> get_ticket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(id) do
    Repo.get!(Ticket, id)
    |> Repo.preload(:user)
    |> IO.inspect(label: "Loaded Ticket")
  end

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(attrs \\ %{}) do
    %Ticket{}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%Ticket{} = ticket, attrs) do
    ticket
    |> Ticket.changeset(attrs)
    |> IO.inspect(label: "Updating Ticket Changeset")
    |> Repo.update()
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%Ticket{} = ticket) do
    Repo.delete(ticket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    Ticket.changeset(ticket, attrs)
  end

  def get_user_tickets(user_id, cur_ticket) do
    ttype = cur_ticket.type
    IO.inspect(ttype, label: "Current Ticket Type")
    case ttype do
      "Epic" ->
        []
      "Story" ->
        from(t in Ticket,
          where: t.user_id == ^user_id and t.type == ^"Epic",
          order_by: [desc: t.inserted_at]
        )
        |> Repo.all()

      "Task" ->
        from(t in Ticket,
          where: t.user_id == ^user_id and t.type == ^"Story",
          order_by: [desc: t.inserted_at]
        )
        |> Repo.all()

      _ ->
        from(t in Ticket,
          where: t.user_id == ^user_id and t.type != "Epic",
          order_by: [desc: t.inserted_at]
        )
        |> Repo.all()
    end
  end
end
