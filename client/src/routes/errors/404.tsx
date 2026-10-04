import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { Result, Button } from "antd";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute("/errors/404")({
	component: RouteComponent,
});

function RouteComponent() {
	const { t } = useTranslation(["errors"]);
	const navigate = useNavigate();

	return (
		<div className="flex items-center justify-center min-h-screen px-4">
			<Result
				status="404"
				title={t("404.title")}
				subTitle={t("404.description")}
				extra={
					<Button type="primary" onClick={() => navigate({ to: "/" })}>
						{t("404.back")}
					</Button>
				}
			/>
		</div>
	);
}

export default RouteComponent;
