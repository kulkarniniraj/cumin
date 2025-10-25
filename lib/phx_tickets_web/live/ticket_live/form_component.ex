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
        <.input :if={@show_parent} field={@form[:parent_id]} type="select" label="Parent"
        options={@tickets} value={@ticket.parent_id || ""} prompt="Select parent ticket" />
        <.input field={@form[:status]} type="select" label="Status"
        options={@status_options} value={@ticket.status} />

        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp tickets_to_options(tickets) do
    Enum.map(tickets, fn t ->
      {t.title, t.id}
    end)
  end

  @impl true
  def update(%{ticket: ticket} = assigns, socket) do
    # Determine if parent selection should be shown based on ticket type
    show_parent = if ticket.type == "Epic", do: false, else: true

    # List parent tickets if applicable
    ticket_options = if show_parent do
      # If ticket.type is already set (e.g., prefilled for child ticket), use it
      # Otherwise, default to "Story" or "Task" for listing parents
      type_for_parent_list = if ticket.type in ["Story", "Task"], do: ticket.type, else: "Story"
      type_for_parent_list |> TC.list_parent_tickets() |> tickets_to_options()
    else
      []
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:status_options, ["open", "in_progress", "closed"])
     |> assign(:type_options, ["Epic", "Story", "Task"])
     |> assign(:show_parent, show_parent) # Set show_parent based on ticket.type
     |> assign_new(:form, fn ->
       # TC.change_ticket will use the prefilled ticket struct
       to_form(TC.change_ticket(ticket))
     end)
     |> assign(:tickets, ticket_options)
     # |> IO.inspect(label: "Socket in new ticket") # Keep or remove inspect as needed
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
      |> assign(:tickets,
            type |> TC.list_parent_tickets() |> tickets_to_options())
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
