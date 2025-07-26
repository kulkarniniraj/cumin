defmodule PhxTicketsWeb.CustomComponents do
  use Phoenix.Component
  import PhxTicketsWeb.CoreComponents

  # alias Phoenix.LiveView.JS

  @doc """
  Custome Progressbar for tickets
  """
  attr :complete, :float, default: 0.0
  attr :inprogress, :float, default: 0.0
  attr :open, :float, default: 100.0

  def progressbar(assigns) do
    complete = assigns[:complete] || 0.0
    inprogress = assigns[:inprogress] || 0.0
    open = assigns[:open] || 100.0

    total = complete + inprogress + open
    assigns
    |> assign(:complete, complete / total * 100.0)
    |> assign(:inprogress, inprogress / total * 100.0)
    |> assign(:open, open / total * 100.0)

    ~H"""
    <div class="w-full  mx-auto mt-8">
      <!-- Progress Bar -->
      <div class="text-center mb-2">
        <span class="text-sm font-semibold">Ticket Progress</span>
      </div>
      <div class="flex h-6 w-full rounded overflow-hidden shadow bg-gray-200">
        <!-- Completed (Green) -->
        <div class="bg-green-500 h-full" style={"width: #{@complete}%"}></div>
        <!-- In Progress (Blue) -->
        <div class="bg-blue-500 h-full" style={"width: #{@inprogress}%"}></div>
        <!-- Open (Red) -->
        <div class="bg-red-500 h-full" style={"width: #{@open}"}></div>
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

  attr :comment, :string, required: true
  attr :user, :string, required: true
  attr :date, :string, required: true
  def comment(assigns) do
    ~H"""
    <div class="bg-gray-100 p-4 rounded">
      <div class="flex items-center mb-2">
        <span class="font-bold mr-2">{@user}</span>
        <span class="text-xs text-gray-500">{@date}</span>
      </div>
      <div>{@comment}</div>
      <%= if @user == "Alice" do %>
        <div class="flex gap-4 mt-3">
          <a href="#" class="text-blue-600 hover:underline text-sm">Edit</a>
          <a href="#" class="text-red-600 hover:underline text-sm">Delete</a>
        </div>
      <% end %>
    </div>
    """
  end

  attr :comments, :list, default: []
  def comments(assigns) do
    ~H"""
    <div class="mt-8 mb-8">
      <h2 class="text-lg font-semibold mb-4">Comments</h2>

      <.form class="flex gap-2 mb-6" for={@form} phx-submit="add_comment" id={"form-#{@formid}"}>
        <input name="comment" type="text" placeholder="Add a comment..." class="flex-1 rounded border border-gray-300 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-indigo-500"/>
        <button type="submit" class="px-4 py-2 rounded bg-indigo-600 text-white hover:bg-indigo-700">Add</button>
      </.form>
      <div class="space-y-4">
        <%= for comment <- @comments do %>
          <.comment comment={comment.comment} user={comment.user} date={comment.date}/>
        <% end %>
      </div>
    </div>
    """
  end

end

defmodule PhxTicketsWeb.CustomComponents.Comment do
  defstruct [:comment, :user, :date]
end
