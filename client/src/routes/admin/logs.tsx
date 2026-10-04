import { createFileRoute } from "@tanstack/react-router";
// import { useEffect, useState } from "react";

import { useTranslation } from "react-i18next";

import { useSelector } from "react-redux";
import type { RootState } from "../../store";

import { Card, Typography, Button, Space } from "antd";
import { AiOutlineMail } from "react-icons/ai";
const { Paragraph, Title } = Typography;

import AdminPageLayout from "../../layouts/Admin";
export const Route = createFileRoute("/admin/logs")({
  component: RouteComponent,
});

function RouteComponent() {
  // const navigate = useNavigate();
  // const dispatch = useDispatch<typeof import("../../store").store.dispatch>();
  const { account } = useSelector((state: RootState) => state.auth);

  const { t: tCommon } = useTranslation(["common"]);
  const { t: tPage } = useTranslation(["pages"], {
    keyPrefix: "admin.documents.index",
  });

  return (
    <AdminPageLayout selectedPage="logs">
      <div className="mb-2">
        {tCommon("loggedInAs", {
          name: account?.profile.name,
          email: account?.email.value,
        })}
      </div>
      <div className="flex items-center justify-center px-6 mt-4 w-full">
        <Card>
          {/* Derecha */}
          <Space
            direction="vertical"
            size="small"
            className="flex-1 text-white p-6"
            style={{ minWidth: 240 }}
          >
            <Title
              level={3}
              className="mb-2"
              style={{ color: "black", marginBottom: 8 }}
            >
              Página en progreso
            </Title>
            <Paragraph className="mb-6">
              Estamos construyendo esta sección. Si quieres ver el progreso,
              probar betas o colaborar, contacta al desarrollador.
            </Paragraph>

            <Space wrap>
              <a href="mailto:asterki.dev@proton.me" target="_blank">
                <Button type="primary" icon={<AiOutlineMail />}>
                  Contactar desarrollador
                </Button>
              </a>
            </Space>
          </Space>
        </Card>
      </div>{" "}
    </AdminPageLayout>
  );
}
