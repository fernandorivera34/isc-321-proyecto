# Architecture Diagrams

High-level data flow

```mermaid
flowchart LR
  subgraph Client
    A[User Form] -->|POST /api/accounts| B[API Gateway]
  end
  subgraph Server
    B --> C[Validation Middleware]
    C --> D[Controllers]
    D --> E[Services]
    E --> F[(MariaDB via Prisma)]
    E --> G[WebSocket / Notifications]
  end
  G --> H[Admin Dashboard]
```

Component interactions

- The client speaks to server routes documented in `docs/routes.md`.
- Server services encapsulate DB and external integrations.
