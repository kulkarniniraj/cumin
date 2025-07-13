defmodule PhxTicketsWeb.CustomComponents do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

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

end
