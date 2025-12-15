defmodule PhxTicketsWeb.ProjectLive.Form do
  use PhxTicketsWeb, :live_view

  def mount(_params, _session, socket) do
    initial_data = %{"name" => "default project", "description" => "placeholder description"}
    form = to_form(initial_data, as: :project_params)
    socket = assign(socket, form: form)
    IO.inspect(socket, label: "Socket in Project Form Mount")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-8">
      <h1 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Create New Project</h1>

      <.form :let={f} for={@form} phx-change="validate" phx-submit="save">
        <div class="mt-6 space-y-6">
          <div>
            <.input field={f[:name]} type="text" label="Project Name" placeholder="e.g. Website Redesign" />
          </div>
          <div>
            <.input field={f[:description]} type="textarea" label="Description" placeholder="e.g. Redesign the company website to improve user experience." />
          </div>
        </div>

        <div class="mt-8 flex">
          <.button phx-disable-with="Creating..." class="flex-1">Create Project</.button>
          <.link href={~p"/admin"} class="flex-1 text-center ml-4">Cancel</.link>
        </div>
      </.form>
    </div>
    """
  end

  # def handle_event("validate", %{"project_params" => project_params}, socket) do
  def handle_event("validate", params, socket) do
    IO.inspect(params, label: "Params in validate event")
    # socket = assign(socket, :project_params, project_params)
    {:noreply, socket}
  end

  def handle_event("save", %{"project_params" =>
        %{"name" => name, "description" => description}}, socket) do
    # IO.inspect(project_params, label: "Project Params in save event")
    if String.contains?(name, " ") do
      socket = put_flash(socket, :error, "Project name cannot contain spaces.")
      {:noreply, socket}
    else
      socket = put_flash(socket, :info, "Save event")
      {:noreply, push_redirect(socket, to: ~p"/")}
    end
    # if name && String.trim(name) != "" do
    #   Phoenix.LiveView.put_flash(socket, :info, "Project '#{name}' created successfully!")
    #   {:noreply, push_redirect(socket, to: ~p"/")}
    # else
    #   socket =
    #     socket
    #     |> Phoenix.LiveView.put_flash(:error, "Project name cannot be blank.")
    #     |> assign(:project_params, project_params)
    #   {:noreply, socket}
    # end

  end
end
