# Server (Backend)

Location: `server/`

Overview

The server is a Node.js + TypeScript API that handles:

- Receiving and validating form submissions
- Authenticating administrative users
- Persisting submissions via Prisma
- Emitting real-time events (sockets) and generating reports

Local development

From the `server/` directory:

```bash
cd server
pnpm install    # or npm install
pnpm dev        # or npm run dev (nodemon)
```

Configuration

Environment and runtime options live under `server/src/config`. Ensure `DATABASE_URL` and other secrets are set before running.
