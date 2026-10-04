# Schemas and Validation

Location: `shared/schemas/`

This project centralises request and response validation in `shared/schemas/` so both the client and server share a single source of truth.

Common schema categories

- `accounts.ts` — user creation, update, credentials
- `auth.ts` — login payloads and token shapes
- `files.ts` — file upload metadata and validation

Validation library

Schemas are intended to be used with runtime validators (e.g., Zod or Joi). Keep the TypeScript types derived from the same schema where possible to avoid drift.

Best practices

- Keep input validation strict for public endpoints.
- Reuse small schema building blocks (address, geo coordinates, pagination).
- Export both runtime validators and TypeScript interfaces from each schema file.
