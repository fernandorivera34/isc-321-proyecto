# Deployment Guide

Overview

This document outlines common deployment strategies for the application.

Containers

- Build backend and frontend Docker images using `Dockerfile` and orchestrate with `compose.yaml` or Kubernetes.

Database

- Use managed Postgres in production. Run `npx prisma migrate deploy` during CI/CD to apply migrations.

CI/CD

- Build and test both client and server, generate artifacts, run migrations, then deploy containers.

Secrets

- Store `DATABASE_URL`, `JWT_SECRET`, and other secrets in a secure vault or environment variables provided by the host.
