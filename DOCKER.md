# Running Mercur with Docker Compose

This guide explains how to run the Mercur marketplace platform using Docker Compose.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+

## Quick Start

1. **Build and start all services:**
   ```bash
   sudo docker compose up --build
   ```

2. **Run in detached mode (background):**
   ```bash
   sudo docker compose up --build -d
   ```

3. **View logs:**
   ```bash
   sudo docker compose logs -f backend
   ```

4. **Stop all services:**
   ```bash
   sudo docker compose down
   ```

5. **Stop and remove volumes (clean slate):**
   ```bash
   sudo docker compose down -v
   ```

## Services

The docker-compose setup includes:

- **postgres**: PostgreSQL 14 database
  - Port: `5432`
  - Database: `medusa`
  - User: `medusa`
  - Password: `medusa`

- **redis**: Redis 7 cache
  - Port: `6379`

- **backend**: Mercur backend API
  - Port: `9000`
  - Admin Panel: Available at `http://localhost:9000`

## Environment Variables

You can customize the environment by creating a `.env` file in the root directory or by setting environment variables. The docker-compose.yml uses these defaults:

- `JWT_SECRET`: `supersecret` (change in production!)
- `COOKIE_SECRET`: `supersecret` (change in production!)
- `STRIPE_SECRET_API_KEY`: `supersecret` (set your real key)
- `ALGOLIA_APP_ID` and `ALGOLIA_API_KEY`: Set your Algolia credentials
- `RESEND_API_KEY`: Set your Resend API key for emails

## Database Migrations

Migrations run automatically when the backend container starts. The entrypoint script:
1. Waits for the database to be ready
2. Runs migrations
3. Starts the server

## Creating an Admin User

After the services are running, create an admin user:

```bash
sudo docker compose exec backend npx medusa user --email admin@example.com --password admin123
```

## Seeding the Database

To seed the database with initial data:

```bash
sudo docker compose exec backend yarn seed
```

## Troubleshooting

### Database connection issues

If you see database connection errors:
1. Check that the postgres container is running: `sudo docker compose ps`
2. Check postgres logs: `sudo docker compose logs postgres`
3. Verify the database was created: `sudo docker compose exec postgres psql -U medusa -d medusa -c "\dt"`

### Rebuild after code changes

To rebuild after making code changes:
```bash
sudo docker compose up --build
```

### Reset everything

To start fresh (removes all data):
```bash
sudo docker compose down -v
sudo docker compose up --build
```

## Production Considerations

For production deployment:
1. Change all default secrets in environment variables
2. Use proper secrets management
3. Set up SSL/TLS
4. Configure proper CORS settings
5. Use managed database services
6. Set up proper backup strategies
7. Configure resource limits in docker-compose.yml

