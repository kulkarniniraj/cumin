defmodule PhxTicketsWeb.TicketLive.FormComponent do
  use PhxTicketsWeb, :live_component

  alias PhxTickets.TC

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage ticket records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ticket-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:type]} type="select" label="Type"
        options={@type_options} prompt="Select ticket type" />
        <.input field={@form[:status]} type="select" label="Status"
        options={@status_options} value={@ticket.status} />
        <.input :if={@show_parent} field={@form[:parent_id]} type="select" label="Parent"
        options={@tickets} value={@ticket.parent_id || ""} prompt="Select parent ticket" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ticket: ticket} = assigns, socket) do
    tickets = TC.get_user_tickets(assigns.current_user.id, ticket)
    tickets |> Enum.map(fn t -> t.id end) |>
    IO.inspect(label: "User Tickets IDs")

    # IO.inspect(tickets, label: "Tickets for user")
    ticket_options =
      Enum.map(tickets, fn t ->
        {t.title, t.id}
      end)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:status_options, ["open", "in_progress", "closed"])
     |> assign(:type_options, ["Epic", "Story", "Task"])
     |> assign(:show_parent, true)
     |> assign_new(:form, fn ->
       to_form(TC.change_ticket(ticket))
     end)
     |> assign(:tickets, ticket_options)
    }

  end

  # Handle ticket type change
  @impl true
  def handle_event("validate", %{
    "_target" => ["ticket", "type"],
    "ticket" => %{"type" => type} = ticket_params}, socket) do
    # IO.inspect(type, label: "Ticket Type in validate")
    changeset = TC.change_ticket(socket.assigns.ticket, ticket_params)

    show_parent = if type == "Epic", do: false, else: true
    {:noreply,
      socket
      |> assign(:show_parent, show_parent)
      |> assign(:form, to_form(changeset, action: :validate))
    }
  end

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
    IO.inspect(ticket_params, label: "Ticket Params in validate")
    changeset = TC.change_ticket(socket.assigns.ticket, ticket_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ticket" => ticket_params}, socket) do
    user = socket.assigns.current_user
    ticket_params = Map.put(ticket_params, "user_id", user.id)
    save_ticket(socket, socket.assigns.action, ticket_params)
  end

  defp save_ticket(socket, :edit, ticket_params) do
    case TC.update_ticket(socket.assigns.ticket, ticket_params) do
      {:ok, ticket} ->
        notify_parent({:saved, ticket})

        {:noreply,
         socket
         |> put_flash(:info, "Ticket updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ticket(socket, :new, ticket_params) do
    case TC.create_ticket(ticket_params) do
      {:ok, ticket} ->
        notify_parent({:saved, ticket})

        {:noreply,
         socket
         |> put_flash(:info, "Ticket created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
