import { Outlet, createRootRoute } from "@tanstack/react-router";
import { App } from "antd";

export const Route = createRootRoute({
  component: () => (
    <App>
      <Outlet />
    </App>
  ),
});
