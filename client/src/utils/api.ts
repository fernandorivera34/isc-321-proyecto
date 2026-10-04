import { isAxiosError } from "axios";

const handleAxiosError = (error: any): any => {
  if (isAxiosError(error)) {
    if (error.message == "Network Error") {
      return {
        status: "network-error",
      };
    }

    if (error.response!.data.status) {
      return error.response?.data;
    } else {
      return {
        status: "internal-error",
      };
    }
  } else {
    return {
      status: "internal-error",
    };
  }
};

function isAPIError(err: unknown): err is { status: string } {
  return (
    typeof err === "object" &&
    err !== null &&
    "status" in err &&
    typeof (err as { status: unknown }).status === "string"
  );
}

export default {
  handleAxiosError,
  isAPIError,
};
