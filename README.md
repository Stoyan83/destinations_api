# Destinations API

This project provides a Rails API for managing trips, including endpoints for listing, showing, and creating trips. The API includes full OpenAPI/Swagger documentation, request logging, and background processing with Sidekiq.

---

## 🚀 Getting Started

These commands will start the project and initialize the database.

### 1️⃣ Build and start the containers

```bash
docker compose up --build -d
```

### 2️⃣ Create, migrate, and seed the database

```bash
docker compose run --rm api bin/rails db:create db:migrate db:seed
```
### Open your browser and go to:
http://localhost:3000/api-docs/index.html

- Swagger automatically documents all endpoints (index, show, create, etc.).
- You can test requests directly from the Swagger UI.

###  Run specs.

```bash
docker compose run --rm api bundle exec rsp
```

### Post Request Logging System wih Sidekiq

Every POST PUT DELETE request is logged with:

- **Client IP address**
- **Timestamp**
- **Request parameters**


### 🔧 Potential Improvements

- Add **authentication & authorization** for API endpoints.  
- Implement **rate limiting** to prevent abuse.  
- Add **idempotent keys** for POST requests to prevent duplicate submissions.