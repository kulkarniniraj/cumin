defmodule PhxTicketsWeb.TicketLive.Show do
  use PhxTicketsWeb, :live_view


  alias PhxTicketsWeb.CustomComponents
  alias PhxTickets.TC
  import PhxTicketsWeb.CustomComponents, only: [progressbar: 1, comment: 1, comments: 1]

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
      %CustomComponents.Comment{comment: "Great work on this ticket! Looking forward to the update.", user: "Alice", date: "2024-07-12 10:15"},
      %CustomComponents.Comment{comment: "Can we clarify the requirements for the next phase?", user: "Bob", date: "2024-07-12 11:00"},
      %CustomComponents.Comment{comment: "I have pushed a fix for the reported bug.", user: "Charlie", date: "2024-07-12 12:30"}
    ]
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:ticket, TC.get_ticket!(id))
     |> assign(:comments, comments)}
  end

  defp page_title(:show), do: "Show Ticket"
  defp page_title(:edit), do: "Edit Ticket"

  defp status_to_color(status) do
    case status do
      "open" -> "bg-red-500"
      "in_progress" -> "bg-blue-500"
      "done" -> "bg-green-500"
    end
  end
end
