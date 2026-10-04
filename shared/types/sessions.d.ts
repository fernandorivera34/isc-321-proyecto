import { IAccountRole } from "../models/account-role";

export type ISessionAccount = {
  _id: string;
  profile: {
    name: string;
  };
  email: {
    value: string;
  };
  data: {
    role: Omit<IAccountRole, "metadata">; // Exclude metadata from role in session for performance and security reasons, as it's not needed in the session
    status: "active" | "inactive";
  };
};
