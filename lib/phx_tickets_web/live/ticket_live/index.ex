defmodule PhxTicketsWeb.TicketLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.TC
  alias PhxTickets.TC.Ticket
  alias PhxTickets.Accounts

  @impl true
  def mount(_params, session, socket) do
    user = PhxTickets.Accounts.get_user_by_session_token(session["user_token"])
    users = PhxTickets.Accounts.list_users()
    filter_params = %{creator: "all", type: "all", status: "all", create_time: "all"} # Initialize filter_params with atom keys
    {:ok,
      socket
      |> assign(current_user: user,
          is_default_view: true,
          users: users,
          page_title: "",
          ticket: nil,
          filter_params: filter_params) # Assign filter_params
      # |> IO.inspect(label: "Current User")
      |> stream(:tickets, TC.list_filtered_tickets("default"))}
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
      creator: Map.get(params, "creator", "all"), # Default to "all"
      type: Map.get(params, "type", "all"),       # Default to "all"
      status: Map.get(params, "status", "all"),   # Default to "all"
      create_time: Map.get(params, "create_time", "all") # Default to "all"
    }
    is_default = is_default_filter_params?(filter_params)
    socket
    |> assign(page_title: "Listing Tickets",
        ticket: nil,
        filter_params: filter_params, # Assign filter_params
        is_default_view: is_default) # Ensure this is correctly assigned
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

  def handle_event("filter", %{"creator" => creator, "type" => type, "status" => status, "create_time" => create_time}, socket) do # Pattern match for string keys
    filter_params = %{creator: creator, type: type, status: status, create_time: create_time} # Convert to atom keys
    IO.inspect(filter_params.type, label: "Filter Type") # Use atom key

    is_default = is_default_filter_params?(filter_params)

    {:noreply,
      socket
      |> stream(:tickets, [], reset: true)
      |> stream(:tickets,
       TC.list_filtered_tickets(filter_params.creator, filter_params.type, filter_params.status, filter_params.create_time) # Use atom keys
      )
      |> assign(:is_default_view, is_default)
      |> assign(:filter_params, filter_params) # Assign the new filter_params map with atom keys
    }
  end

  defp is_default_filter_params?(%{ # Updated to accept map with atom keys
         create_time: "all",
         creator: "all",
         status: "all",
         type: "all"
       }),
       do: true
  defp is_default_filter_params?(_), do: false
end
