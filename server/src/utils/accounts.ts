import bcrypt from "bcrypt";
import { ISessionAccount } from "@shared/types/sessions.js";

import { AccountWithRole } from "../types/index.js";

import { Permission } from "@shared/types/permissions.js";

const verifyPassword = (passwordHash: string, password: string): boolean => {
  return bcrypt.compareSync(password, passwordHash);
};

const createSessionAccount = async (
  account: AccountWithRole,
): Promise<ISessionAccount> => {
  const role = account.role!;

  return {
    _id: account.id.toString(),
    profile: {
      name: account.name,
    },
    email: {
      value: account.email,
    },
    data: {
      campus: account.campus,
      role: {
        ...role,
        permissions:
          role.permissions?.split(",").map((perm) => perm.trim()) ||
          ([] as unknown as Permission[]),
      },
      status: account.status,
    },
  };
};

export default {
  verifyPassword,
  createSessionAccount,
};
