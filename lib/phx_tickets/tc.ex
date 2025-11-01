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

  def list_filtered_tickets("default") do
    Ticket
    |> where([t], t.status in ["open", "in_progress"])
    |> where([t], t.type != "Epic")
    |> where([t], t.deleted == false)
    |> Repo.all()
  end

  def list_filtered_tickets(_user, type, status, _create_time) do
    query = from t in Ticket,
      where: t.deleted == false

    query = case type do
      "default" ->
        where(query, [t], t.type != "Epic")
      "all" ->
        query
      _ ->
        where(query, [t], t.type == ^type)
    end

    query = case status do
      "default" ->
        where(query, [t], t.status in ["open", "in_progress"])
      "all" ->
        query
      _ ->
        where(query, [t], t.status == ^status)
    end

    Repo.all(query)
    |> Repo.preload([:user])
  end

  @doc """
  Returns the list of parent tickets.
  For Story, Epic tickets are returned
  For Task, Story tickets are returned

  Only tickets which are not deleted and open or in_progress are returned

  ## Examples

      iex> list_parent_tickets("Story")
      [%Ticket{}, ...]

  """
  def list_parent_tickets(ticket_type) do
    parent_type = if ticket_type == "Story", do: "Epic", else: "Story"
    Ticket
    |> where([t], t.type == ^parent_type)
    |> where([t], t.deleted == false)
    |> where([t], t.status in ["open", "in_progress"])
    |> Repo.all()
  end

  @doc """
  Returns the list of non deleted child tickets for a given parent ticket ID.
  """
  def list_active_children(parent_id) do
    Ticket
    |> where([t], t.parent_id == ^parent_id)
    |> where([t], t.deleted == false)
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
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
    |> Repo.preload([:user, :parent, :children, comments: [:user]])
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
    ticket
    |> Ticket.changeset(%{deleted: true})
    |> Repo.update()
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

  alias PhxTickets.TC.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id) |> Repo.preload([:user])

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
