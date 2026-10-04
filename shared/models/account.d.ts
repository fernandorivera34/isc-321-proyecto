import { IAccountRole } from "./account-role";
import { IMetadata } from "./metadata";
import { IMetadataUpdateHistory } from "./metadata-update-history";

export type IAccount = {
  id: number;

  // Data object fields
  lastLogin: Date | null;
  roleId: number | null;
  role: IAccountRole | null;
  status: "active" | "locked";
  campus:
    | "comayagua"
    | "tegucigalpa"
    | "sula"
    | "olancho"
    | "choluteca"
    | "yoro"
    | "atlantida"
    | "paraiso"
    | "copan";

  // Email object fields
  emailValue: string;

  // Profile object fields
  profileName: string;
  avatarUrl: string | null;

  // Preferences -> security
  password: string;

  // Metadata
  metadataId: number | null;
  metadata: IMetadata | null;
  metadataUpdateHistories: IMetadataUpdateHistory[];
};
