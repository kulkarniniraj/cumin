defmodule PhxTicketsWeb.AdminLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.Accounts
  alias PhxTickets.TC

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()
    tickets = TC.list_tickets()
    comments = TC.list_comments()
    pending_users = Accounts.list_pending_users()

    socket =
      socket
      |> assign(:page_title, "Admin Portal")
      |> assign(:users, users)
      |> assign(:tickets, tickets)
      |> assign(:comments, comments)
      |> assign(:pending_users, pending_users)

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

  @impl true
  def handle_event("approve_user", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    {:ok, _} = Accounts.approve_user(user)

    {:noreply,
     socket
     |> put_flash(:info, "#{user.name} has been approved.")
     |> assign(:pending_users, Accounts.list_pending_users())}
  end

  @impl true
  def handle_event("reject_user", %{"id" => user_id}, socket) do
    user = Accounts.get_user!(user_id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply,
     socket
     |> put_flash(:info, "#{user.name} has been rejected and their account deleted.")
     |> assign(:pending_users, Accounts.list_pending_users())}
  end
end
