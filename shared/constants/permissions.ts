import type { Permission } from "../types/permissions.js";

const permissions: Permission[] = [
  "*",
  "*:*",

  // Reports
  "reports:read",
  "reports:export",
  "reports:print",

  // Accounts
  "accounts:create",
  "accounts:read",
  "accounts:update",
  "accounts:delete",
  "accounts:restore",
  "accounts:change-password",
  "accounts:update-status",

  // Account Roles
  "account-roles:create",
  "account-roles:read",
  "account-roles:update",
  "account-roles:delete",
  "account-roles:restore",

  // config
  "config:update",
  "config:read",
  "config:export",
  "config:import",

  // Profile
  "profile:update",


  // Logs
  "logs:read",
  "logs:export",
];

export default permissions;
