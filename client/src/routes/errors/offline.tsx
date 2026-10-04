import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";

import { Result, Button, App } from "antd";
import { useTranslation } from "react-i18next";
import { useDispatch } from "react-redux";
import { unwrapResult } from "@reduxjs/toolkit";

import AuthFeature from "../../features/auth/";

export const Route = createFileRoute("/errors/offline")({
	component: OfflinePage,
});

function OfflinePage() {
	const { t } = useTranslation(["main"]);
	const dispatch = useDispatch<typeof import("../../store").store.dispatch>();
	const { message } = App.useApp();
	const navigate = useNavigate();

	const handleRetry = async () => {
		const result = await dispatch(AuthFeature.actions.fetch());
		const data = unwrapResult(result);

		if (data.status !== "network-error") {
			// If fetch succeeded, just navigate
			navigate({ to: "/admin" });
		} else {
			// If fetch failed, show error message
			message.error(t("error-messages:network-error"));
		}
	};

	useEffect(() => {
		setTimeout(() => {
			handleRetry();
		}, 5000);
	}, []);

	return (
		<div className="flex items-center justify-center min-h-screen px-4">
			<Result
				status="500"
				title="Offline"
				subTitle={t("errors:offline.subtitle")}
				extra={
					<Button type="primary" onClick={handleRetry}>
						{t("errors:offline.retry")}
					</Button>
				}
			/>
		</div>
	);
}
