defmodule PhxTicketsWeb.AdminLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.Accounts
  alias PhxTickets.TC

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    tickets = TC.list_tickets()
    comments = TC.list_comments()

    socket =
      socket
      |> assign(:page_title, "Admin Portal")
      |> assign(:users, users)
      |> assign(:tickets, tickets)
      |> assign(:comments, comments)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Admin Portal")
  end
end
