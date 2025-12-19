defmodule PhxTicketsWeb.UserPendingApprovalLive do
  use PhxTicketsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm text-center py-12">
      <.header>
        Account Awaiting Approval
        <:subtitle>
          Your account has been created and is now awaiting approval from an administrator.
          You will receive an email once your account has been approved and activated.
        </:subtitle>
      </.header>

      <.link href={~p"/"} class="mt-8 text-sm font-semibold text-brand hover:underline">
        Return to Home Page
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
