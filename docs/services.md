# Server Services

Location: `server/src/services/`

Services encapsulate non-trivial business logic and data access. They are designed to be consumed by controllers and are where Prisma DB calls and integration with external systems live.

Known service areas (from repo structure)

- `logging.ts` — central logging utilities
- `sessions.ts` — session lifecycle (create, invalidate, refresh)
- `socket.ts` — real-time notifications and socket lifecycle
- `account-roles/`, `accounts/` — domain-specific services

Guidelines

- Services should be side-effect aware and return predictable results or throw well-defined errors.
- Keep controllers thin: they should map HTTP → service calls and handle status codes.
- Write unit tests for service logic; mock Prisma or use an in-memory DB for integration tests.
