# Database and Prisma

Location: `prisma/`

The project uses Prisma as an ORM for schema definition and migrations. Migrations are stored under `prisma/migrations`.

Common commands

```bash
# Install Prisma CLI (project root)
pnpm add -D prisma @prisma/client

# Generate client after schema changes
pnpm prisma generate

# Run migrations in development
pnpm prisma migrate dev
```

Notes

- Keep `schema.prisma` as the single source of truth for the database model.
- Review migration SQL files before applying to production.
