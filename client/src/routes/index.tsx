import { createFileRoute, useNavigate } from "@tanstack/react-router";

import { Layout, Button } from "antd";
const { Header, Footer } = Layout;

export const Route = createFileRoute("/")({
  component: Page,
});

function Page() {
  const navigate = useNavigate();

  navigate({
    to: "/admin",
  })
}
