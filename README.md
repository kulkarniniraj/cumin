<div align="center">
  <img src="./assets/images/cumin-logo/vector/default-monochrome.svg" alt="Cumin Logo" width="120" height="120">
  <p><strong>An opinionated project management system for small orgs</strong></p>
</div>

---

## How to Run 

### 1. Using Docker, published image (Recommended)
- **Requirements:**
  - Docker
  - Docker Compose
- **Setup:**
  - Get docker-compose.yml from this repo
    - Either clone the entire Repo
    - Or download docker-compose.yml from this repo [https://github.com/kulkarniniraj/phx_tickets/blob/main/docker-compose.yml](docker-compose.yml) and save it as `docker-compose.yml` in the same directory
  - Run `docker-compose up -d`
    
### 2. Build your own image
- **Requirements:**
  - Docker
  - Docker Compose
  - Git
  - Elixir 1.18
  - Erlang/OTP 28
  - Dependencies as specified in `mix.exs`
- **Setup:**
  - Clone the entire Repo
  - Run `mix deps.get`
  - Run `docker build -t <your-image-name> .`
  - Run `docker run -d -p 4000:4000 -v <your-project-folder>:/mnt <your-image-name>`
  - The app runs at [http://localhost:4000](http://localhost:4000)

### 3. Run from source, for development 

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