# Architecture

This project follows a modular monorepo layout with three primary areas:

- `client/`: Web frontend built with Vite and React/TypeScript. Responsible for rendering forms and reports.
- `server/`: Node/TypeScript backend exposing a JSON API, handling validation, authentication, and data persistence.
- `shared/`: Type definitions, API contracts and shared schemas used by both client and server.

Supporting files and folders:

- `prisma/`: Prisma schema and migration files that define the database model and migrations.
- `docs/`: Project documentation (this site).
- `compose.yaml` and `Dockerfile`: Container and orchestration helpers for local or production deployments.

Design goals

- Clear separation between UI, API, and shared contracts.
- Strong typing across boundaries using TypeScript and shared definitions.
- Migrations managed through Prisma for schema evolution.
