defmodule PhxTicketsWeb.TicketLive.Show do
  use PhxTicketsWeb, :live_view


  alias PhxTicketsWeb.CustomComponents
  alias PhxTickets.TC
  alias PhxTickets.TC.Ticket # Added this alias
  import PhxTicketsWeb.CustomComponents, only:
    [progressbar: 1, comment: 1, comments: 1, child_tickets: 1]

  @impl true
  def mount(_params, session, socket) do
    user = PhxTickets.Accounts.get_user_by_session_token(session["user_token"])
    {:ok,
      socket
      |> assign(:current_user, user)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    comments = [
      %CustomComponents.Comment{body: "Great work on this ticket! Looking forward to the update.", user: "Alice", inserted_at: "2024-07-12 10:15"},
      %CustomComponents.Comment{body: "Can we clarify the requirements for the next phase?", user: "Bob", inserted_at: "2024-07-12 11:00"},
      %CustomComponents.Comment{body: "I have pushed a fix for the reported bug.", user: "Charlie", inserted_at: "2024-07-12 12:30"}
    ]
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:ticket, TC.get_ticket!(id))
     |> assign(:comments, comments)
     |> assign(:form,
        to_form(TC.change_comment(%TC.Comment{})))
      |> assign(:formid, :rand.uniform())
    }
  end

  @impl true
  def handle_event("add_comment", params, socket) do
    IO.inspect(params, label: "Params")
    IO.inspect(socket.assigns.ticket.id, label: "Ticket")
    # IO.inspect(socket.assigns.current_user, label: "Current User")
    TC.create_comment(%{
      body: params["comment"],
      ticket_id: socket.assigns.ticket.id,
      user_id: socket.assigns.current_user.id
    })

    # assign form with random id to force refresh
    {
      :noreply,
      socket
      |> assign(:form, to_form(
        TC.change_comment(%TC.Comment{})))
      |> assign(:formid, :rand.uniform())
      |> assign(:ticket, TC.get_ticket!(socket.assigns.ticket.id))
    }
  end

  @impl true
  def handle_event("new_child_ticket", _params, socket) do
    parent_ticket = socket.assigns.ticket
    child_type = case parent_ticket.type do
      "Epic" -> "Story"
      "Story" -> "Task"
      _ -> "Task" # Fallback, though button should prevent this for "Task" parent
    end

    new_child_ticket = %PhxTickets.TC.Ticket{parent_id: parent_ticket.id, type: child_type} # Use full module name here

    {:noreply,
      socket
      |> assign(:live_action, :new)
      |> assign(:page_title, "New Child Ticket")
      |> assign(:new_child_ticket, new_child_ticket) # Assign the new child ticket struct for the form

    }
  end

  defp page_title(:show), do: "Show Ticket"
  defp page_title(:edit), do: "Edit Ticket"

  def status_to_color(status) do
    case status do
      "open" -> "bg-red-500"
      "in_progress" -> "bg-blue-500"
      "closed" -> "bg-green-500"
    end
  end

  @impl true
  def handle_info({PhxTicketsWeb.TicketLive.FormComponent, {:saved, child_ticket}}, socket) do
    current_ticket = socket.assigns.ticket
    # Check if the saved ticket is a child of the current ticket
    if child_ticket.parent_id == current_ticket.id do
      {:noreply,
        socket
        |> put_flash(:info, "Child ticket created successfully!")
        |> assign(:live_action, :show) # Close the modal
        |> assign(:ticket, TC.get_ticket!(current_ticket.id)) # Re-fetch parent to update children
      }
    else
      # If it's not a child, it might be an edit of the current ticket itself
      # or some other scenario. For now, just close the modal.
      {:noreply,
        socket
        |> put_flash(:info, "Ticket saved successfully!")
        |> assign(:live_action, :show) # Close the modal
      }
    end
  end

end
