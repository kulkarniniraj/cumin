defmodule PhxTicketsWeb.ProjectLive.Form do
  use PhxTicketsWeb, :live_view

  alias PhxTickets.TC
  alias PhxTickets.Tc.Project

  def mount(_params, _session, socket) do
    form = to_form(TC.change_project(%Project{}))
    {:ok, assign(socket, form: form)}
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

  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset = TC.change_project(%Project{}, project_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    case TC.create_project(project_params) do
      {:ok, project} ->
        Phoenix.LiveView.put_flash(socket, :info, "Project '#{project.name}' created successfully!")
        {:noreply, push_redirect(socket, to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
