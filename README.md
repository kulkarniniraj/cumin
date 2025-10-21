<div align="center">
  <img src="./assets/images/cumin-logo/vector/default-monochrome.svg" alt="Cumin Logo" width="120" height="120">
  <p><strong>An opinionated project management system for small orgs</strong></p>
</div>

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
  3. The app runs at [http://localhost:4000](http://localhost:4000)

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

Logo created with [Namecheap](https://www.namecheap.com)