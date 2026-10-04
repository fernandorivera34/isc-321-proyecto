import { Form, Input, Modal, Select } from "antd";
import { useTranslation } from "react-i18next";
import { FaPlus } from "react-icons/fa";

import type { CreateAccountModalState } from "../hooks/useCreateModal";

type CreateAccountFormProps = {
  roles: { id: string; name: string; level: number }[];
  state: CreateAccountModalState;
  setState: React.Dispatch<React.SetStateAction<CreateAccountModalState>>;
  onClose: () => void;
  onCreate: () => void;
};

export function CreateAccountModal({
  state,
  roles,
  setState,
  onClose,
  onCreate,
}: CreateAccountFormProps) {
  const { t } = useTranslation(["features"], {
    keyPrefix: "accounts.components.createModal",
  });
  const { t: tCommon } = useTranslation(["common"]);

  return (
    <Modal
      title={t("title")}
      open={state.isOpen}
      onCancel={onClose}
      cancelText={tCommon("cancel")}
      onOk={onCreate}
      okButtonProps={{
        loading: state.loading,
        icon: <FaPlus />,
        disabled: state.loading,
      }}
      okText={t("title")}
    >
      <Form layout="vertical">
        <Form.Item label={t("fields.name")} required >
          <Input
            maxLength={100}
            showCount
            value={state.name}
            placeholder={t("fields.namePlaceholder")}
            onChange={(e) =>
              setState((prev) => ({ ...prev, name: e.target.value }))
            }
          />
        </Form.Item>

        <Form.Item label={t("fields.email")} required>
          <Input
            value={state.email}
            placeholder={t("fields.emailPlaceholder")}
            onChange={(e) =>
              setState((prev) => ({ ...prev, email: e.target.value }))
            }
          />
        </Form.Item>

        <Form.Item label={t("fields.password")} required>
          <Input.Password
            maxLength={256}
            value={state.password}
            showCount
            placeholder={t("fields.passwordPlaceholder")}
            onChange={(e) =>
              setState((prev) => ({ ...prev, password: e.target.value }))
            }
          />
        </Form.Item>

        <Form.Item label={t("fields.role")} required>
          <Select
            placeholder={t("fields.selectRole")}
            value={state.roleId}
            options={roles.map((role) => ({
              value: role.id,
              label: `${role.name} (${role.level})`,
            }))}
            onChange={(value) =>
              setState((prev) => ({ ...prev, roleId: value }))
            }
          />
        </Form.Item>
      </Form>
    </Modal>
  );
}
