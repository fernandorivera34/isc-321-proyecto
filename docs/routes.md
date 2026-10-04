# Server Routes Reference

Location: `server/src/routes/`

The server exposes modular route files. Each route file groups related endpoints and uses shared schemas and middleware.

Route files and responsibilities

- `account-roles.ts`: endpoints for listing and managing account roles (create, update, delete, assign).
- `accounts.ts`: account management endpoints (create user, get user, update profile, list users).
- `auth.ts`: authentication endpoints (login, logout, refresh token, session info).
- `index.ts`: aggregates and mounts the route modules on the API path.

Typical endpoint patterns

- GET `/api/<resource>` — list resources
- GET `/api/<resource>/:id` — fetch single resource
- POST `/api/<resource>` — create resource (usually validated)
- PATCH `/api/<resource>/:id` — partial update
- DELETE `/api/<resource>/:id` — remove resource

Authentication and authorization

Admin endpoints are protected by the authentication middleware in `server/src/middleware/authMiddleware.ts`. Role checks use utilities from `shared/constants/permissions.ts` and `server/src/utils/permissions.ts`.

Extending routes

When adding a route:

1. Add or update shared request/response schemas in `shared/schemas/`.
2. Implement the route handler in `server/src/controllers/` and expose it in `server/src/routes/`.
3. If the route needs DB access, add service logic under `server/src/services/`.
4. Update client API calls in `client/src/features/*` and shared API types in `shared/api/`.
