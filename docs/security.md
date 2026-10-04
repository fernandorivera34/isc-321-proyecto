# Security Considerations

- Validate and sanitize all inputs (see `sanitizeBody.ts`).
- Protect endpoints using `authMiddleware.ts`.
- Hash passwords and rotate secrets when required.
- Limit data retention and remove unnecessary PII.
- Use HTTPS in production and secure cookies (HttpOnly, Secure, SameSite).
