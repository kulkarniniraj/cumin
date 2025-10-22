defmodule PhxTicketsWeb.TicketLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.TC
  alias PhxTickets.TC.Ticket
  alias PhxTickets.Accounts

  @impl true
  def mount(_params, session, socket) do
    user = PhxTickets.Accounts.get_user_by_session_token(session["user_token"])
    users = PhxTickets.Accounts.list_users()
    {:ok,
      socket
      |> assign(:current_user, user)
      |> assign(:is_default_view, true)
      |> assign(:users, users)
      |> IO.inspect(label: "Current User")
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
    |> assign(:page_title, "Edit Ticket")
    |> assign(:ticket, TC.get_ticket!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ticket")
    |> assign(:ticket, %Ticket{})
  end

  defp apply_action(socket, :index, params) do
    is_default = is_default_filter_params?(params)
    socket
    |> assign(:page_title, "Listing Tickets")
    |> assign(:ticket, nil)
    # |> assign(:is_default_view, is_default)
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

  def handle_event("filter",
    %{
      "create_time" => create_time,
      "creator" => creator,
      "status" => status,
      "type" => type
    } = filter_params, socket) do
    IO.inspect(type, label: "Filter Type")

    is_default = is_default_filter_params?(filter_params)

    {:noreply,
      socket
      |> stream(:tickets, [], reset: true)
      |> stream(:tickets,
       TC.list_filtered_tickets(creator, type, status, create_time)
      )
      |> assign(:is_default_view, is_default)
    }
  end

  defp is_default_filter_params?(_), do: false
end
