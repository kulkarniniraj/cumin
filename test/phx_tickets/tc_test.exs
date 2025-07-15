defmodule PhxTickets.TCTest do
  use PhxTickets.DataCase

  alias PhxTickets.TC

  describe "tickets" do
    alias PhxTickets.TC.Ticket

    import PhxTickets.TCFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil}

    test "list_tickets/0 returns all tickets" do
      ticket = ticket_fixture()
      assert TC.list_tickets() == [ticket]
    end

    test "get_ticket!/1 returns the ticket with given id" do
      ticket = ticket_fixture()
      assert TC.get_ticket!(ticket.id) == ticket
    end

    test "create_ticket/1 with valid data creates a ticket" do
      valid_attrs = %{status: "some status", description: "some description", title: "some title"}

      assert {:ok, %Ticket{} = ticket} = TC.create_ticket(valid_attrs)
      assert ticket.status == "some status"
      assert ticket.description == "some description"
      assert ticket.title == "some title"
    end

    test "create_ticket/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TC.create_ticket(@invalid_attrs)
    end

    test "update_ticket/2 with valid data updates the ticket" do
      ticket = ticket_fixture()
      update_attrs = %{status: "some updated status", description: "some updated description", title: "some updated title"}

      assert {:ok, %Ticket{} = ticket} = TC.update_ticket(ticket, update_attrs)
      assert ticket.status == "some updated status"
      assert ticket.description == "some updated description"
      assert ticket.title == "some updated title"
    end

    test "update_ticket/2 with invalid data returns error changeset" do
      ticket = ticket_fixture()
      assert {:error, %Ecto.Changeset{}} = TC.update_ticket(ticket, @invalid_attrs)
      assert ticket == TC.get_ticket!(ticket.id)
    end

    test "delete_ticket/1 deletes the ticket" do
      ticket = ticket_fixture()
      assert {:ok, %Ticket{}} = TC.delete_ticket(ticket)
      assert_raise Ecto.NoResultsError, fn -> TC.get_ticket!(ticket.id) end
    end

    test "change_ticket/1 returns a ticket changeset" do
      ticket = ticket_fixture()
      assert %Ecto.Changeset{} = TC.change_ticket(ticket)
    end
  end

  describe "comments" do
    alias PhxTickets.TC.Comment

    import PhxTickets.TCFixtures

    @invalid_attrs %{body: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert TC.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert TC.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %Comment{} = comment} = TC.create_comment(valid_attrs)
      assert comment.body == "some body"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TC.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Comment{} = comment} = TC.update_comment(comment, update_attrs)
      assert comment.body == "some updated body"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = TC.update_comment(comment, @invalid_attrs)
      assert comment == TC.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = TC.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> TC.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = TC.change_comment(comment)
    end
  end
end
