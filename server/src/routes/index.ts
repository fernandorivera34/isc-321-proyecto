import type { Express } from "express";

// Import routers
import AuthRouter from "./auth.js";
import AccountsRouter from "./accounts.js";
import AccountRolesRouter from "./account-roles.js";

export function registerRoutes(app: Express): void {
  app.use("/api/auth", AuthRouter);
  app.use("/api/accounts", AccountsRouter);
  app.use("/api/account-roles", AccountRolesRouter);
}
