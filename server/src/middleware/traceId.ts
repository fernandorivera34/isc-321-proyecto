import express from "express";
import { v4 as uuidv4 } from "uuid";

export function traceIdMiddleware(
  req: express.Request,
  res: express.Response,
  next: express.NextFunction,
) {
  const traceId = uuidv4();
  req.traceId = traceId;
  res.locals.traceId = traceId;
  res.setHeader("x-trace-id", traceId);
  next();
}
