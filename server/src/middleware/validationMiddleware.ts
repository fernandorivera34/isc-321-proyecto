import { Request, Response, NextFunction } from "express";
import { ZodSchema } from "zod";

const validateRequestBody =
  (schema: ZodSchema<any>) =>
  (req: Request, res: Response, next: NextFunction) => {
    let rawData: unknown;

    try {
      // Handle multipart/form-data with embedded JSON string in `req.body.data`
      if (req.is("multipart/form-data") && typeof req.body?.data === "string") {
        rawData = JSON.parse(req.body.data);
      } else {
        rawData = req.body;
      }
    } catch (err) {
      res.status(400).send({
        status: "invalid-json",
        message: "Could not parse JSON from form-data field `data`.",
      });
      return;
    }

    const parsedBody = schema.safeParse(rawData);
    if (!parsedBody.success) {
      res.status(400).send({
        status: "invalid-parameters",
        errors: parsedBody.error.issues,
      });
    } else {
      req.parsedBody = parsedBody.data; // Store parsed body for further use
      next();
    }
  };

const validateRequestQuery =
  (schema: ZodSchema<any>) =>
  (req: Request, res: Response, next: NextFunction) => {
    const parsedQuery = schema.safeParse(req.query);
    if (!parsedQuery.success) {
      res.status(400).send({
        status: "invalid-parameters",
        errors: parsedQuery.error.issues,
      });
    } else {
      next();
    }
  };

export { validateRequestBody, validateRequestQuery };
