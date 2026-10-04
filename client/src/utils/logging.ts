type LogLevel =
  | "trace"
  | "debug"
  | "info"
  | "warn"
  | "error"
  | "fatal"
  | "offline"
  | "cache";

const LEVEL_COLORS: Record<LogLevel, string> = {
  trace: "color: #95a5a6", // gray
  debug: "color: #2ecc71", // green
  info: "color: #3498db", // blue
  warn: "color: #f1c40f", // yellow
  error: "color: #e74c3c", // red
  fatal: "color: #8e44ad; font-weight: bold", // purple bold
  offline: "color: #d35400; font-weight: bold", // orange bold
  cache: "color: #16a085; font-weight: bold", // teal bold
};

// Helper to format messages
const formatMessage = (level: LogLevel, message: string, context?: string) => {
  const ctx = context ? `[${context}] ` : "";
  const timestamp = new Date().toISOString();
  return `%c${timestamp} ${level.toUpperCase()}: ${ctx}${message}`;
};

// Low-level logger function
const log = (
  level: LogLevel,
  message: string,
  context?: string,
  ...args: any[]
) => {
  const formatted = formatMessage(level, message, context);
  const color = LEVEL_COLORS[level];
  switch (level) {
    case "warn":
    case "offline":
      console.warn(formatted, color, ...args);
      break;
    case "error":
    case "fatal":
      console.error(formatted, color, ...args);
      break;
    case "debug":
      console.debug(formatted, color, ...args);
      break;
    default:
      console.log(formatted, color, ...args);
  }
};

// Exported object in Axios-style pattern
export default {
  trace: (message: string, context?: any, ...args: any[]) =>
    log("trace", message, context, ...args),
  debug: (message: string, context?: any, ...args: any[]) =>
    log("debug", message, context, ...args),
  info: (message: string, context?: any, ...args: any[]) =>
    log("info", message, context, ...args),
  warn: (message: string, context?: any, ...args: any[]) =>
    log("warn", message, context, ...args),
  error: (message: string, context?: any, ...args: any[]) =>
    log("error", message, context, ...args),
  fatal: (message: string, context?: any, ...args: any[]) =>
    log("fatal", message, context, ...args),
  offline: (message: string, context?: any, ...args: any[]) =>
    log("offline", message, context, ...args),
  cache: (message: string, context?: any, ...args: any[]) =>
    log("cache", message, context, ...args),
};
