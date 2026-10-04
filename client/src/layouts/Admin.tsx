import { useEffect, useMemo, useRef, useState } from "react";
import { Link, useNavigate } from "@tanstack/react-router";

import {
  FaBars,
  FaTerminal,
  FaUserShield,
  FaUsers,
  FaCompressArrowsAlt,
  FaChartArea,
  FaCog,
  FaRegArrowAltCircleLeft,
  FaInfo,
} from "react-icons/fa";

import {
  ConfigProvider,
  Drawer,
  Layout,
  Menu,
  MenuProps,
  Space,
  Spin,
  Typography
} from "antd";
const { Title } = Typography;
import esES from "antd/locale/es_ES";

import { useDispatch, useSelector } from "react-redux";

import { useTranslation } from "react-i18next";
import AuthFeature from "../features/auth/";

// import ConfigFeature from "../features/config/";
import type { RootState } from "../store";

import { hasPermissions } from "../utils/permissions";

const { Header, Sider } = Layout;

interface LayoutProps {
  children: React.ReactNode;
  selectedPage?: string;
  defaultCollapsed?: boolean;
  removePadding?: boolean;
}

export default function PageLayout({ children, selectedPage, removePadding, defaultCollapsed }: LayoutProps) {
  const navigate = useNavigate();
  const dispatch = useDispatch<typeof import("../store").store.dispatch>();

  const { t } = useTranslation(["layouts"], { keyPrefix: "admin" });

  const { account } = useSelector((state: RootState) => state.auth);
  // const { config } = useSelector((state: RootState) => state.config);

  const [collapsed, setCollapsed] = useState(defaultCollapsed || false);
  const [drawerVisible, setDrawerVisible] = useState(false);

  useEffect(() => {
    if (!account) {
      (async () => {
        const result = await dispatch(AuthFeature.actions.fetch());

        if (
          AuthFeature.actions.fetch.rejected.match(result) ||
          result.payload.status === "unauthenticated"
        ) {
          navigate({ to: "/auth/login" });
        } else {
          console.log("Account fetched successfully:", result.payload);
        }
      })();
    }
  }, [account]);

  // useEffect(() => {
  //   if (!config) dispatch(ConfigFeature.actions.fetchConfig());

  //   // if (!config?.masterServer.enabled) navigate({ to: '/nodes/register' })
  // }, [config]);

  const sidebarRef = useRef(null);

  type MenuItem = Required<MenuProps>["items"][number];
  const menuItems = useMemo<MenuItem[]>(() => {
    if (!account) return [];

    const userPermissions = account.data.role.permissions;

    return [
      // === Overview & Core ===
      {
        key: "dashboard",
        label: <Link to="/admin">{t("sidebar.dashboard")}</Link>,
        icon: <FaCompressArrowsAlt />, // Better for dashboards
      },

      {
        key: "reports-group",
        label: t("sidebar.reports-group.title"),
        icon: <FaChartArea />,
        children: [

        ],
      },

      {
        key: "management",
        label: t("sidebar.management.title"),
        icon: <FaCog />,
        children: [
          {
            key: "accounts",
            label: (
              <Link to="/admin/accounts">
                {t("sidebar.management.accounts")}
              </Link>
            ),
            style: {
              display: hasPermissions(userPermissions, ["accounts:read"])
                ? "block"
                : "none",
            },
            icon: <FaUsers />, // Better for dashboards
          },

          {
            key: "account-roles",
            label: (
              <Link to="/admin/accounts/roles">
                {t("sidebar.management.account-roles")}
              </Link>
            ),
            style: {
              display: hasPermissions(userPermissions, ["account-roles:read"])
                ? "block"
                : "none",
            },
            icon: <FaUserShield />,
          },

          {
            key: "config",
            label: (
              <Link to="/admin/config">{t("sidebar.management.config")}</Link>
            ),
            style: {
              display: hasPermissions(userPermissions, ["config:read"]) ? "block" : "none",
            },
            icon: <FaCog />,
          },

          {
            key: "logs",
            label: <Link to="/admin/logs">{t("sidebar.management.logs")}</Link>,
            style: {
              display: hasPermissions(userPermissions, ["logs:read"])
                ? "block"
                : "none",
            },
            icon: <FaTerminal />,
          },
        ],
      },
      {
        key: "logout",
        label: (
          <Link color="red" to="/auth/logout">
            {t("sidebar.logout")}
          </Link>
        ),
        danger: true,
        icon: <FaRegArrowAltCircleLeft className="text-red-300" />,
      },
    ];
  }, [account]);

  const isDark = false;

  return (
    <ConfigProvider
      locale={esES}
    >
      {/* Top Navbar */}
      <Header
        className={`px-4 flex items-center justify-between color-white`}
        style={{ paddingInline: 16 }}
      >
        <div className="md:hidden block">
          <button
            onClick={() => setDrawerVisible(true)}
            className="md:hidden text-xl block text-white"
          >
            <FaBars />
          </button>
        </div>
        <Space align="center" className="" size={14}>
          <img
            src="/assets/img/icon.png"
            alt="Icon"
            style={{ width: 42, height: 42, objectFit: "contain" }}
          />
          <div className="text-white">
            <h1 style={{ margin: 0 }} className="text-white font-bold text-lg">
              Sistema de Registro de la Universidad de Las Americas
            </h1>
          </div>
        </Space>
      </Header>

      <Layout hasSider>
        {/* Sidebar for desktop */}
        <Sider
          breakpoint="md"
          collapsible
          collapsed={collapsed}
          onCollapse={(value) => setCollapsed(value)}
          className="hidden md:block"
          theme={isDark ? "dark" : "light"}
          width={220}
          ref={sidebarRef}
        >
          <Menu
            mode="inline"
            defaultOpenKeys={[
              "reports-group",
              "management",
            ]}
            defaultSelectedKeys={[selectedPage || "dashboard"]}
            items={menuItems}
            className="h-full"
          />
        </Sider>

        {/* Sidebar Drawer for mobile */}
        <Drawer
          title="Menú"
          placement="left"
          onClose={() => setDrawerVisible(false)}
          open={drawerVisible}
        >
          <Menu
            mode="inline"
            defaultSelectedKeys={[selectedPage || "dashboard"]}
            defaultOpenKeys={[
              "reports-group",
              "management",
            ]}
            style={{
              color: "white",
            }}
            items={menuItems}
            onClick={() => setDrawerVisible(false)}
          />
        </Drawer>



        {/* Main Content */}
        <Layout
          style={{ background: "transparent" }}
          className={`min-h-screen ${isDark ? "dark" : ""} relative`}
        >
          <div className={`${removePadding ? "" : "p-4"} dark:text-white min-h-[calc(100vh-64px)] z-10`}>
            {account && children}
            {!account && (
              <div className="text-center text-lg text-gray-500">
                <Spin size="large" />
              </div>
            )}
          </div>
        </Layout>

      </Layout>
    </ConfigProvider>
  );
}
