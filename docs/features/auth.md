# Feature: Auth

Location: `src/features/auth/` (client), `server/src/controllers/auth/`, `server/src/middleware/`

Auth flows

- Login: issue JWT or session cookie.
- Logout: invalidate session and tokens.
- Refresh: token rotation or session keep-alive.

Implementation notes

- Prefer short-lived access tokens and refresh tokens stored securely.
- Protect sensitive endpoints with `authMiddleware` and role checks.
