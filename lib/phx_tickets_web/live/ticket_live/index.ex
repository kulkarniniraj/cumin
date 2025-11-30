defmodule PhxTicketsWeb.TicketLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.TC
  alias PhxTickets.TC.Ticket
  alias PhxTickets.Accounts
  require Logger
  @impl true
  def mount(_params, session, socket) do
    user = PhxTickets.Accounts.get_user_by_session_token(session["user_token"])
    users = PhxTickets.Accounts.list_users()
    filter_params = %{assignee: "all", type: "default", status: "default", create_time: "all"} # Initialize filter_params with atom keys
    all_tickets = TC.list_filtered_tickets("all", "default", "default", "all")
    # log ticket title and assignee for each ticket
    Logger.debug([data: all_tickets |> Enum.map(fn ticket -> {ticket.title, ticket.assignee.name} end), label: "All Tickets"], [])
    {:ok,
      socket
      |> assign(current_user: user,
          users: users,
          page_title: "",
          ticket: nil,
          filter_params: filter_params) # Assign filter_params
      # |> IO.inspect(label: "Current User")
      |> stream(:tickets,
          all_tickets)
    }
  end

  @impl true
  @spec handle_params(any(), any(), map()) :: {:noreply, map()}
  def handle_params(params, _url, socket) do
    socket = apply_action(socket, socket.assigns.live_action, params)
    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(page_title: "Edit Ticket",
        ticket: TC.get_ticket!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(page_title: "New Ticket",
        ticket: %Ticket{})
  end

  defp apply_action(socket, :index, params) do
    filter_params = %{ # Create filter_params from URL params with atom keys
      assignee: Map.get(params, "assignee", "all"), # Default to "all"
      type: Map.get(params, "type", "default"),       # Default to "all"
      status: Map.get(params, "status", "default"),   # Default to "all"
      create_time: Map.get(params, "create_time", "all") # Default to "all"
    }
    IO.inspect(filter_params, label: "Filter Params in apply_action") # Debugging line
    socket
    |> assign(page_title: "Listing Tickets",
        ticket: nil,
        filter_params: filter_params)# Assign filter_params
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

  def handle_event("filter", %{"assignee" => assignee, "type" => type, "status" => status, "create_time" => create_time}, socket) do # Pattern match for string keys
    filter_params = %{assignee: assignee, type: type, status: status, create_time: create_time} # Convert to atom keys
    IO.inspect(filter_params.type, label: "Filter Type") # Use atom key

    {:noreply,
      socket
      |> stream(:tickets, [], reset: true)
      |> stream(:tickets,
       TC.list_filtered_tickets(filter_params.assignee, filter_params.type, filter_params.status, filter_params.create_time) # Use atom keys
      )
      |> assign(:filter_params, filter_params) # Assign the new filter_params map with atom keys
    }
  end
end
