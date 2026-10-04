export class APIError<T> extends Error {
  httpStatus: number;
  status: T;

  constructor(status: T, httpStatus: number) {
    super(status as string);
    this.name = "APIError";
    this.status = status as T;
    this.httpStatus = httpStatus;
  }
}
