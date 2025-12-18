defmodule PhxTicketsWeb.TicketLive.Index do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.TC
  alias PhxTickets.TC.Ticket
  alias PhxTickets.Accounts
  require Logger
  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    users = Accounts.list_users()
    projects = TC.list_projects()

    active_project_id =
      cond do
        user == nil ->
          nil
        user.active_project_id != nil ->
          IO.inspect(user.active_project_id, label: "User Active Project ID")
          user.active_project_id
        Enum.empty?(projects) ->
          nil
        true ->
          proj_id = hd(projects).id
          # Update user with this active project
          Accounts.update_user_active_project(user, proj_id)
          IO.inspect(proj_id, label: "Setting Active Project ID to")
          proj_id
      end

    # active_project_id = user.active_project_id || (if Enum.empty?(projects), do: nil, else: hd(projects).id)


    filter_params = %{assignee: "all", type: "default", status: "default", create_time: "all", project_id: active_project_id} # Initialize filter_params with atom keys

    all_tickets =
      if active_project_id do
        TC.list_filtered_tickets(active_project_id, filter_params.assignee, filter_params.type, filter_params.status, filter_params.create_time)
      else
        []
      end
    # log ticket title and assignee for each ticket
    Logger.debug([data: all_tickets |> Enum.map(fn ticket -> {ticket.title, ticket.assignee.name} end), label: "All Tickets"], [])
    {:ok,
      socket
      |> assign(current_user: user,
          users: users,
          projects: projects,
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
      project_id: socket.assigns.filter_params.project_id, # Retain existing project_id
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

  def handle_event("filter_by_project", %{"project_selection" => project_id}, socket) do
    current_user = socket.assigns.current_user

    project_id = if project_id == "all", do: nil, else: String.to_integer(project_id) # Convert to integer or nil

    case Accounts.update_user_active_project(current_user, project_id) do
      {:ok, updated_user} ->
        flash_message = if project_id, do: "Active project set successfully.", else: "Filter cleared."
        socket = put_flash(socket, :info, flash_message)
        socket = assign(socket, :current_user, updated_user) # Update the current_user assign
        # Continue with filtering using the potentially updated user (for consistency)
        filter_params = Map.put(socket.assigns.filter_params, :project_id, project_id)
        tickets = if project_id, do: TC.list_filtered_tickets(project_id), else: [] # Adjust based on project_id presence
        {:noreply,
          socket
          |> stream(:tickets, tickets, reset: true)
          |> assign(:filter_params, filter_params)
        }

      {:error, _changeset} ->
        socket = put_flash(socket, :error, "Failed to update active project.")
        # Still filter tickets based on the selected project_id for immediate UI update,
        # even if saving to user settings failed.
        filter_params = Map.put(socket.assigns.filter_params, :project_id, project_id)
        tickets = if project_id, do: TC.list_filtered_tickets(project_id), else: []
        {:noreply,
          socket
          |> stream(:tickets, tickets, reset: true)
          |> assign(:filter_params, filter_params)
        }
    end
  end

  def handle_event("filter", %{"assignee" => assignee, "type" => type, "status" => status, "create_time" => create_time}, socket) do # Pattern match for string keys
    filter_params = %{
      project_id: socket.assigns.filter_params.project_id, # Retain existing project_id
      assignee: assignee, type: type, status: status, create_time: create_time} # Convert to atom keys
    IO.inspect(filter_params.type, label: "Filter Type") # Use atom key

    {:noreply,
      socket
      |> stream(:tickets, [], reset: true)
      |> stream(:tickets,
       TC.list_filtered_tickets(filter_params.project_id, filter_params.assignee, filter_params.type, filter_params.status, filter_params.create_time) # Use atom keys
      )
      |> assign(:filter_params, filter_params) # Assign the new filter_params map with atom keys
    }
  end
end
