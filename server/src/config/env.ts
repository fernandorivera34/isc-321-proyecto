import dotenv from "dotenv";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function loadEnv() {
  const envPath = path.resolve(
    __dirname,
    process.env.NODE_ENV === "production" ? "../.env.prod" : "../.env.dev",
  );

  dotenv.config({ path: envPath });

  const requiredEnv = [
    "DATABASE_URL",
    "ALLOWED_ORIGINS",
    "SESSION_SECRET",
    "PORT",
  ];

  const missing = requiredEnv.filter((key) => !process.env[key]);

  if (missing.length > 0) {
    console.error(
      "[ENV ERROR] Missing required variables:",
      missing.join(", "),
    );
    process.exit(1);
  }
}
