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
        options={@type_options} />
        <.input field={@form[:status]} type="select" label="Status"
        options={@status_options} />

        <:actions>
          <.button phx-disable-with="Saving...">Save Ticket</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ticket: ticket} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:status_options, ["open", "in_progress", "closed"])
     |> assign(:type_options, ["Epic", "Story", "Task"])
     |> assign_new(:form, fn ->
       to_form(TC.change_ticket(ticket))
     end)}

  end

  @impl true
  def handle_event("validate", %{"ticket" => ticket_params}, socket) do
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
