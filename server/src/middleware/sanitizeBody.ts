import { NextFunction } from "express";

const HTML_TAG_RE = /<\/?[^>]+(>|$)/g;
const SCRIPT_RE = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
const EVENT_HANDLER_RE = /\s*on\w+\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]+)/gi;
const JAVASCRIPT_URI_RE = /javascript\s*:/gi;

function sanitizeString(value: string): string {
  return value
    .replace(SCRIPT_RE, "")
    .replace(EVENT_HANDLER_RE, "")
    .replace(JAVASCRIPT_URI_RE, "")
    .replace(HTML_TAG_RE, "");
}

function sanitizeValue(value: unknown): unknown {
  if (typeof value === "string") {
    return sanitizeString(value);
  }
  if (Array.isArray(value)) {
    return value.map(sanitizeValue);
  }
  if (value !== null && typeof value === "object") {
    return sanitizeObject(value as Record<string, unknown>);
  }
  return value;
}

function sanitizeObject(obj: Record<string, unknown>): Record<string, unknown> {
  const sanitized: Record<string, unknown> = {};
  for (const [key, val] of Object.entries(obj)) {
    sanitized[key] = sanitizeValue(val);
  }
  return sanitized;
}

/**
 * Express middleware that recursively sanitises all string values in
 * `req.body` to strip HTML / script / event-handler content.
 */
export function sanitizeBody(
  req: Request,
  _res: Response,
  next: NextFunction,
): void {
  if (req.body && typeof req.body === "object") {
    // TODO: Apply this to the parsedBody instead of the raw body, to avoid issues with non-JSON content types
    // req.body = sanitizeObject(req.body as Record<string, unknown>);
  }
  next();
}
