defmodule PhxTicketsWeb.TicketLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.TC
  alias PhxTickets.TC.Ticket

  @impl true
  def mount(_params, session, socket) do
    user = PhxTickets.Accounts.get_user_by_session_token(session["user_token"])
    {:ok,
      socket
      |> assign(:current_user, user)
      |> IO.inspect(label: "Current User")
      |> stream(:tickets, TC.list_tickets())}
  end

  @impl true
  @spec handle_params(any(), any(), map()) :: {:noreply, map()}
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ticket")
    |> assign(:ticket, TC.get_ticket!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ticket")
    |> assign(:ticket, %Ticket{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tickets")
    |> assign(:ticket, nil)
  end

  @impl true
  def handle_info({PhxTicketsWeb.TicketLive.FormComponent, {:saved, ticket}}, socket) do
    {:noreply, stream_insert(socket, :tickets, ticket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ticket = TC.get_ticket!(id)
    {:ok, _} = TC.delete_ticket(ticket)

    {:noreply, stream_delete(socket, :tickets, ticket)}
  end
end
