# API Reference and Shared Contracts

Location: `shared/` and `server/routes/`

This project uses shared TypeScript definitions and schema validators to keep client and server contracts in sync.

- Shared API types: `shared/api/*.ts`
- Request/response schemas: `shared/schemas/`
- Server routes: `server/src/routes/`

Route structure

All API endpoints follow a predictable pattern:

`/api/<resource>/<action>`

Where `<resource>` is the resource name (for example `accounts`, `forms`, `accounts`) and `<action>` is one of the standard actions: `delete`, `restore`, `create`, `update`, `get`, `list`.

Examples

- List submissions: `GET /api/accounts/list`
- Get a single submission: `GET /api/accounts/get?id=<id>` or `GET /api/accounts/get/<id>` depending on route implementation
- Create a submission: `POST /api/accounts/create`
- Update a submission: `PATCH /api/accounts/update`
- Soft-delete a submission: `POST /api/accounts/delete`
- Restore a soft-deleted submission: `POST /api/accounts/restore`

Notes

- Use HTTP verbs consistently where possible, but prefer the explicit action segment to make the API intent clear across the codebase.
- Ensure shared schemas in `shared/schemas/` reflect the request/response shapes for each action.

Usage

When adding a new endpoint, update the shared contract, implement the route on the server, and update the client to call the new API.

Authentication

Protected admin routes require authentication middleware located in `server/src/middleware/authMiddleware.ts`.
