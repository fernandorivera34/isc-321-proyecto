# Middleware

Location: `server/src/middleware/`

Key middleware

- `authMiddleware.ts` — verifies JWT/session and attaches user to request.
- `sanitizeBody.ts` — cleans incoming payloads to avoid injection and remove unexpected fields.
- `traceId.ts` — attaches a request trace ID for logging and correlation.
- `validationMiddleware.ts` — runs shared schemas against incoming requests and returns 4xx errors on validation failures.

Middleware ordering

1. `traceId` — generate trace id early.
2. `sanitizeBody` — normalize request body.
3. `validationMiddleware` — validate shapes before handlers.
4. `authMiddleware` — protect routes that require authentication.

Custom middleware

Add lightweight middleware under `server/src/middleware/` and export from the main server setup in `server/src/setup.ts`.
