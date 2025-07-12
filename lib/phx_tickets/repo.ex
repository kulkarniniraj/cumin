defmodule PhxTickets.Repo do
  use Ecto.Repo,
    otp_app: :phx_tickets,
    adapter: Ecto.Adapters.SQLite3
end
