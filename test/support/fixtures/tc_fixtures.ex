defmodule PhxTickets.TCFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxTickets.TC` context.
  """

  @doc """
  Generate a ticket.
  """
  def ticket_fixture(attrs \\ %{}) do
    {:ok, ticket} =
      attrs
      |> Enum.into(%{
        description: "some description",
        status: "some status",
        title: "some title"
      })
      |> PhxTickets.TC.create_ticket()

    ticket
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> PhxTickets.TC.create_comment()

    comment
  end
end
