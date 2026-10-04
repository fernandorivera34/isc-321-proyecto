import {
  Button,
  ConfigProvider,
  Layout,
  Space,
  Typography,
} from "antd";
import esES from "antd/locale/es_ES";
import { useNavigate } from "@tanstack/react-router";

interface LayoutProps {
  children: React.ReactNode;
}

export default function GeneralLayout({ children }: LayoutProps) {
  const navigate = useNavigate();
  const isDark = false;
  const { Header, Content, Footer } = Layout;
  const { Title, Text } = Typography;

  return (
    <ConfigProvider
      locale={esES}
    >
      <Layout
        style={{
          minHeight: "100vh",
        }}
        className={isDark ? "dark" : ""}
      >
        {/* Top Navbar */}
        <Header
          className={`px-4 flex items-center justify-between bg-white`}
          style={{ paddingInline: 16 }}
        >
          <Space align="center" className="" size={14}>
            <img
              src="/assets/img/icon.png"
              alt="Logo"
              style={{ width: 42, height: 42, objectFit: "contain" }}
            />
            <div className="text-white">
              <h1 style={{ margin: 0 }} className="text-white font-bold text-lg">
                Plantilla de Proyectos
              </h1>
            </div>
          </Space>
        </Header>

        <Content style={{ padding: 20, display: "flex", justifyContent: "center", alignItems: "center" }}>
          {children}
        </Content>

        <Footer style={{ textAlign: "center", borderTop: "1px solid #262a33", background: "transparent" }}>
          Hecho por <a href="https://asterki.xyz" target="_blank" className="underline">Fernando Rivera</a> | {new Date().getFullYear()}
        </Footer>
      </Layout>
    </ConfigProvider>
  );
}


