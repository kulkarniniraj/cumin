# Cumin
## An opinionated project management system for small orgs

---

## How to Run (Development)

- **Requirements:**
  - Elixir 1.18
  - Erlang/OTP 28
  - Dependencies as specified in `mix.exs`

- **Setup:**
  1. Install dependencies:
     ```sh
     mix deps.get
     ```
  2. Start the development server:
     ```sh
     mix phx.server
     ```
  3. The app runs at [http://localhost:4002](http://localhost:4002)

- **Database:**
  - Uses SQLite
  - The database file is created in the local project folder automatically

---

## Features

- 🏷️ **Opinionated ticketing system**
- 🪜 **3-tier ticketing:** Epic → Story → Task
- 🔒 **Basic authentication**
- 🔍 **Basic filters**

---

## Screenshots

**Ticket List**

![Ticket List](./assets/images/list.png)

**Ticket Show**

![Ticket Show](./assets/images/details.png)
