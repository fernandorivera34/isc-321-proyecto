import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useTranslation } from "react-i18next";

import { Card, Col, Typography } from "antd";
const { Title, Paragraph } = Typography;

import { FaUser, FaUserShield, FaFile, FaBus, FaUsers } from "react-icons/fa";

import type { RootState } from "../../store";

import AuthFeature from "../../features/auth/";
import AdminLayout from "../../layouts/Admin";
import type { AccountRole } from "../../features/roles";

import type { Permission } from "../../../../shared/types/permissions";
import { FaDiamondTurnRight } from "react-icons/fa6";

export const Route = createFileRoute("/admin/")({
  component: RouteComponent,
});

function RouteComponent() {
  const navigate = useNavigate();
  const dispatch = useDispatch<typeof import("../../store").store.dispatch>();
  const { account } = useSelector((state: RootState) => state.auth);

  const { t: tPage } = useTranslation(["pages"], {
    keyPrefix: "admin.index",
  });

  useEffect(() => {
    if (!account) {
      (async () => {
        const result = await dispatch(AuthFeature.actions.fetch());
        if (AuthFeature.actions.fetch.rejected.match(result)) {
          navigate({ to: "/auth/login" });
        }
      })();
    }
  }, [account, dispatch, navigate]);

  const hasPermission = (permission: Permission): boolean => {
    if (account) {
      if (
        (account.data.role! as AccountRole)!.permissions.includes(permission) ||
        (account.data.role! as AccountRole)!.permissions.includes("*")
      )
        return true;
      return false;
    }
    return false;
  };

  const menuItems: Array<{
    key: string;
    link: string;
    label: string;
    description?: string;
    style?: React.CSSProperties;
    icon: React.ReactNode;
  }> = [
      {
        key: "accounts",
        link: "/admin/accounts",
        label: tPage("items.accounts.title"),
        description: tPage("items.accounts.description"),
        style: {
          display: hasPermission("accounts:read") ? "block" : "none",
        },
        icon: <FaUser className="text-6xl" />, // Better for dashboards
      },

      {
        key: "account-roles",
        link: "/admin/accounts/roles",
        label: tPage("items.account-roles.title"),
        description: tPage("items.account-roles.description"),
        style: {
          display: hasPermission("account-roles:read") ? "block" : "none",
        },
        icon: <FaUserShield className="text-6xl" />, // Better for dashboards
      },
    ];

  const greeting =
    new Date().getHours() < 12
      ? tPage("greetings.morning")
      : new Date().getHours() < 18
        ? tPage("greetings.afternoon")
        : tPage("greetings.evening");

  return (
    <AdminLayout>
      <div className="">
        <Title level={2} style={{ marginBottom: 24 }}>
          {greeting}, {account?.profile.name}
        </Title>
        <Paragraph>{tPage("description")}</Paragraph>

        <div className="flex gap-2 flex-wrap mt-8 items-stretch justify-center">
          {menuItems.map((item) => (
            <Card
              hoverable
              className="w-1/4"
              key={item.key}
              onClick={() => {
                navigate({ to: item.link as any });
              }}
            >
              <div className="flex items-center flex-1 justify-center gap-4 h-full">
                <Col className="text-primary">{item.icon}</Col>
                <Col>
                  <p className="text-2xl font-bold text-primary">
                    {item.label}
                  </p>
                  {item.description && (
                    <Paragraph type="secondary" style={{ margin: 0 }}>
                      {item.description}
                    </Paragraph>
                  )}
                </Col>
              </div>
            </Card>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
