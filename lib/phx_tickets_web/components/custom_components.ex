defmodule PhxTicketsWeb.CustomComponents do
  use Phoenix.Component
  import PhxTicketsWeb.CoreComponents
  alias PhxTicketsWeb.CommonUtils
  alias PhxTickets.TC
  require Logger

  # alias Phoenix.LiveView.JS

  defp calculate_progress(ticket) do
    children = TC.list_active_children(ticket.id)
    total = children |> Enum.count()
    completed = children |> Enum.count(& &1.status == "closed")
    inprogress = children |> Enum.count(& &1.status == "in_progress")
    open = children |> Enum.count(& &1.status == "open")
    Logger.debug([data: {total, completed, inprogress, open}, label: "calculate_progress: Ticket progress counts"], [])
    {
      completed * 100 / total,
      inprogress * 100 / total,
      open * 100 / total
    }
  end
  @doc """
  Custome Progressbar for tickets
  """
  attr :ticket, :map, required: true

  def progressbar(assigns) do
    ticket = assigns[:ticket]
    {complete, inprogress, open} = calculate_progress(ticket)
    IO.inspect({complete, inprogress, open}, label: "progressbar: Progress percentages")

    ~H"""
    <div class="w-full  mx-auto mt-8">
      <!-- Progress Bar -->
      <div class="text-center mb-2">
        <span class="text-sm font-semibold">Ticket Progress</span>
      </div>
      <div class="flex h-6 w-full rounded overflow-hidden shadow bg-gray-200">
        <!-- Completed (Green) -->
        <div class="bg-green-500 h-full" style={"width: #{complete}%"}></div>
        <!-- In Progress (Blue) -->
        <div class="bg-blue-500 h-full" style={"width: #{inprogress}%"}></div>
        <!-- Open (Red) -->
        <div class="bg-red-500 h-full" style={"width: #{open}%"}></div>
      </div>
      <!-- Legend -->
      <div class="flex justify-between mt-2 text-sm">
        <div class="flex items-center space-x-1">
          <span class="inline-block w-3 h-3 bg-green-500 rounded"></span>
          <span>Completed</span>
        </div>
        <div class="flex items-center space-x-1">
          <span class="inline-block w-3 h-3 bg-blue-500 rounded"></span>
          <span>In Progress</span>
        </div>
        <div class="flex items-center space-x-1">
          <span class="inline-block w-3 h-3 bg-red-500 rounded"></span>
          <span>Open</span>
        </div>
      </div>
    </div>
    """
  end

  attr :comment, :any, required: true
  attr :user, :any, required: true
  def comment(assigns) do
    user_name = if assigns.comment.user_id == assigns.user do
      "You"
    else
      assigns.comment.user.name
    end

    ~H"""
    <div class="bg-gray-100 p-4 rounded">
      <div class="flex items-center mb-2">
        <span class="font-bold mr-2">{user_name}</span>
        <span class="text-xs text-gray-500">{CommonUtils.format_date(@comment.inserted_at, true)}</span>
      </div>
      <div class="markdown-body">{Phoenix.HTML.raw(Earmark.as_html!(@comment.body))}</div>
      <%= if @user == @comment.user.id do %>
        <div class="flex gap-4 mt-3">
          <a href="#" class="text-blue-600 hover:underline text-sm">Edit</a>
          <a href="#" class="text-red-600 hover:underline text-sm">Delete</a>
        </div>
      <% end %>
    </div>
    """
  end

  attr :comments, :list, default: []
  attr :form, :any, required: true
  attr :formid, :any, required: true
  attr :current_user, :any, required: true
  def comments(assigns) do
    reverse_comments = Enum.reverse(assigns.comments)
    ~H"""
    <div class="mt-8 mb-8">
      <h2 class="text-lg font-semibold mb-4">Comments</h2>

      <.form class="flex gap-2 mb-6" for={@form} phx-submit="add_comment" id={"form-#{@formid}"}>
        <!-- <input name="comment" type="text" placeholder="Add a comment..." class="flex-1 rounded border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"/> -->
        <textarea name="comment" type="text" placeholder="Add a comment..." rows="1" class="flex-1 rounded border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"/>
        <button type="submit" class="px-4 py-2 rounded bg-indigo-600 text-white hover:bg-indigo-700">Add</button>
      </.form>
      <div class="space-y-4">
        <%= for comment <- reverse_comments do %>
          <.comment
            comment={comment}
            user={@current_user.id}
            />
        <% end %>
      </div>
    </div>
    """
  end


  def child_ticket(assigns) do
    ~H"""
    <!-- Child Ticket -->
    <div id={@id} class="border border-gray-300 shadow-lg rounded-lg p-4 hover:bg-gray-50">
      <.link href={"/tickets/#{@ticket.id}"} class="text-indigo-600 hover:text-indigo-800 text-sm font-medium">
        <div class="flex items-center justify-between">
          <div class="flex-1">
            <h3 class="font-semibold text-gray-900">{@ticket.title}</h3>
            <div class="flex items-center gap-4 mt-1 text-sm text-gray-600">
              <span>Type: {@ticket.type}</span>
              <span class={["inline-block px-2 py-1 rounded text-xs font-semibold text-white", PhxTicketsWeb.TicketLive.Show.status_to_color(@ticket.status)]}>{@ticket.status}</span>

              <span>Created: {@ticket.inserted_at}</span>
            </div>
          </div>
        </div>
      </.link>
    </div>
    """
  end

  def child_tickets(assigns) do
    ~H"""
    <!-- Child Tickets Section -->
    <div class="mt-8" :if={@self_ticket.type != "Task"}>
        <h2 class="text-lg font-semibold mb-4">Child Tickets</h2>

        <!-- Add Child Ticket Button -->
        <div class="mt-2 mb-2">
          <.button phx-click="new_child_ticket" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            <span class="mr-2">+</span>
            Add Child Ticket
          </.button>
        </div>

        <div class="space-y-3">
          <%= for ticket <- @self_ticket.children, key={ticket.id} do %>
            <.child_ticket id={"cticket-#{ticket.id}"} ticket={ticket}/>
          <% end %>

        </div>



        <%!-- horizontal line --%>
        <div class="mt-4">
          <hr class="border-gray-200">
        </div>
      </div>
    """
  end
end

defmodule PhxTicketsWeb.CustomComponents.Comment do
  defstruct [:body, :user, :inserted_at]
end
