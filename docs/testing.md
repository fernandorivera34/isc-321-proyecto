# Testing Strategy

Unit tests

- Test services and utilities in isolation. Mock Prisma or DB layers.

Integration tests

- Run integration tests against a disposable Postgres instance (Docker) to validate Prisma migrations and queries.

End-to-end

- Optionally use Playwright or Cypress to test the full UI submission and admin reporting flows.

Running tests

Check `package.json` in `server/` and `client/` for test scripts. Typical commands:

```bash
# server
cd server
npm test

# client
cd client
npm test
```
