# Usage and Deployment

This section explains how to run the system locally and suggestions for deployment.

Quick local run (development)

1. Start the database (Postgres recommended) and set `DATABASE_URL`.
2. In `server/`: install dependencies and run the dev server.
3. In `client/`: install dependencies and run the dev server.

Docker / Compose

There are `Dockerfile` and `compose.yaml` files at the repository root to help containerize the services. Use them to run the stack locally or in cloud environments.

Production notes

- Use environment variables for configuration (secrets and DB URL).
- Apply Prisma migrations during deploy.
- Serve the built frontend from a static host or the backend as appropriate.
