# Feature: Accounts

Location: `src/features/accounts/` (client), `server/src/controllers/accounts/`, `server/src/services/accounts/`

Overview

Account management covers user registration, profile updates, and administrative user listing.

Security

- Store passwords hashed (bcrypt/argon2).
- Use rate limiting on auth endpoints.

Roles and permissions

Account roles are defined under `shared/constants/permissions.ts` and enforced by middleware and utility helpers.
