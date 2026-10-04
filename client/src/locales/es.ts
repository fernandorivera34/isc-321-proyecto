const translation = {
  "error-messages": {
    "internal-error":
      "Se produjo un error interno, por favor intente nuevamente más tarde",
    "network-error":
      "No se ha podido conectar al servidor, las funciones que requieren conexión no estarán disponibles hasta que se restablezca la conexión",
    "invalid-parameters":
      "Por favor, asegúrese de haber proporcionado toda la información requerida en el formato requerido. No es común que ocurra, pero si lo hace, contacte soporte técnico.",
    unauthorized:
      "Su sesión ha expirado o no tiene permiso para acceder a esta página. Por favor, inicie sesión nuevamente.",
    forbidden:
      "No tienes permiso para acceder a esta página o realizar esta acción.",
    "not-found": "El recurso solicitado no fue encontrado.",
    "invoice-number-range-exceeded":
      "El rango de números de factura ha sido excedido. Por favor, actualice el rango en la configuración del sistema.",
    "invoice-range-expired":
      "El rango de facturas ha expirado. Por favor, actualice el rango en la configuración del sistema.",
    "invalid-terminal":
      "Terminal no autorizado, si es un error, por favor contacte al administrador del sistema.",
    "query-too-long":
      "La consulta proporcionada es demasiado larga. Por favor, reduzca la longitud de la consulta.",
  },

  common: {
    loggedInAs: "Conectado como {{name}} ({{email}})",
    search: "Buscar",
    cancel: "Cancelar",
    yes: "Sí",
    no: "No",
    save: "Guardar",
    undo: "Deshacer",
    redo: "Rehacer",
    update: "Actualizar",
    exit: "Salir",
    close: "Cerrar",
    delete: "Eliminar",
    back: "Regresar",
    create: "Crear",
    actions: "Acciones",
    confirm: "Confirmar",
    loading: "Cargando...",
    days: {
      mon: "Lunes",
      tue: "Martes",
      wed: "Miércoles",
      thu: "Jueves",
      fri: "Viernes",
      sat: "Sábado",
      sun: "Domingo",
    },
  },
  permissions: {
    // Reports
    reports: "Reportes",
    "reports.read": "Leer reportes",
    "reports.export": "Exportar reportes",
    "reports.print": "Imprimir reportes",

    // Accounts
    accounts: "Cuentas",
    "accounts.create": "Crear cuentas",
    "accounts.read": "Leer cuentas",
    "accounts.update": "Actualizar cuentas",
    "accounts.delete": "Eliminar cuentas",
    "accounts.restore": "Restaurar cuentas",
    "accounts.change-password": "Cambiar contraseña de cuentas",
    "accounts.update-status": "Actualizar estado de cuentas",

    // Account Roles
    "account-roles": "Roles de Cuenta",
    "account-roles.create": "Crear roles de cuenta",
    "account-roles.read": "Leer roles de cuenta",
    "account-roles.update": "Actualizar roles de cuenta",
    "account-roles.delete": "Eliminar roles de cuenta",
    "account-roles.restore": "Restaurar roles de cuenta",

    // Config
    config: "Configuración del Sistema",
    "config.update": "Actualizar configuración del sistema",
    "config.read": "Leer configuración del sistema",
    "config.export": "Exportar configuración del sistema",
    "config.import": "Importar configuración del sistema",

    // Profile
    profile: "Perfil de Usuario",
    "profile.update": "Actualizar perfil de usuario",

    // Logs
    logs: "Registros Técnicos",
    "logs.read": "Leer registros técnicos",
    "logs.export": "Exportar registros técnicos",
  },

  features: {
    accounts: {
      components: {
        table: {
          name: "Nombre",
          email: "Correo Electrónico",
          role: "Rol",
          status: "Estado",
          active: "Activo",
          inactive: "Inactivo",
          campus: "Campus",
          deleted: "Eliminado",
          actions: "Acciones",

          total: "Mostrando {{range}} de {{total}} cuentas",
          filterCampusPlaceholder: "Filtrar por campus",
          filterStatusPlaceholder: "Filtrar por estado",
          filterRolePlaceholder: "Filtrar por rol",

          actionButtons: {
            trigger: "Acciones",
            update: "Actualizar",
            changePassword: "Cambiar Contraseña",
            delete: "Eliminar",
            restore: "Restaurar",
            updateStatus: "Actualizar Estado",
          },
        },

        createModal: {
          title: "Crear Nueva Cuenta",
          fields: {
            name: "Nombre",
            namePlaceholder: "Ingrese el nombre completo",
            email: "Correo Electrónico",
            emailPlaceholder: "Ingrese la dirección de correo electrónico",
            password: "Contraseña",
            passwordPlaceholder: "Ingrese una contraseña segura",
            role: "Rol",
            selectRole: "Seleccione un rol",
            campus: "Campus",
            campusPlaceholder: "Seleccione un campus",
          },
        },

        updateModal: {
          title: "Actualizar Cuenta",
          fields: {
            name: "Nombre",
            namePlaceholder: "Ingrese el nombre completo",
            email: "Correo Institucional",
            emailPlaceholder: "Ingrese la dirección de correo electrónico",
            role: "Rol",
            selectRole: "Seleccione un rol",
            campus: "Campus",
            campusPlaceholder: "Seleccione un campus",
          },
        },

        updateStatusModal: {
          title: "Actualizar Estado de la Cuenta",
          fields: {
            status: "Nuevo Estado",
            statuses: {
              active: "Activo",
              inactive: "Inactivo",
            },
          },
        },

        updatePasswordModal: {
          title: "Cambiar Contraseña",
          fields: {
            password: "Nueva Contraseña",
            passwordPlaceholder: "Ingrese una nueva contraseña segura",
          },
        },
      },

      hooks: {
        useCreateModal: {
          messages: {
            // Validation
            "invalid-email": "El formato del correo electrónico es inválido.",
            "name-too-short": "El nombre debe tener al menos 3 caracteres.",
            "invalid-role-id": "El rol seleccionado es inválido.",
            "invalid-campus": "El campus seleccionado es inválido.",
            "password-too-short":
              "La contraseña debe tener al menos 8 caracteres.",

            // API
            "email-in-use":
              "La dirección de correo electrónico ya está en uso por otra cuenta.",
            "role-not-found": "El rol seleccionado no fue encontrado.",
            "role-cannot-be-assigned":
              "El rol seleccionado no puede ser asignado a esta cuenta.",

            success: "Cuenta creada exitosamente.",
          },
        },

        useUpdateStatusModal: {
          messages: {
            success: "Estado de la cuenta actualizado exitosamente.",
            "account-not-found":
              "La cuenta que intentas actualizar no fue encontrada.",
          },
        },

        useUpdateModal: {
          messages: {
            success: "Cuenta actualizada exitosamente.",
            "account-not-found":
              "La cuenta que intentas actualizar no fue encontrada.",
            "email-in-use":
              "La dirección de correo electrónico ya está en uso por otra cuenta.",
            "role-not-found": "El rol seleccionado no fue encontrado.",
            "role-cannot-be-assigned":
              "No puedes asignar este rol a la cuenta porque tu rol tiene un nivel de permiso más bajo.",
            "name-too-short": "El nombre debe tener al menos 3 caracteres.",
            "invalid-email": "El formato del correo electrónico es inválido.",
            "invalid-role-id": "El rol seleccionado es inválido.",
            "invalid-campus": "El campus seleccionado es inválido.",
          },
        },

        useUpdatePasswordModal: {
          messages: {
            success: "Contraseña actualizada exitosamente.",
            "account-not-found":
              "La cuenta que intentas actualizar no fue encontrada.",
            "cannot-change-own-password":
              "No puedes cambiar tu propia contraseña desde esta sección. Por favor, utiliza la sección de perfil para cambiar tu contraseña.",
            "password-too-short":
              "La nueva contraseña debe tener al menos 8 caracteres.",
            "cannot-change-password-due-to-role-level":
              "No se puede cambiar la contraseña de una cuenta con un rol de nivel igual o superior al de la cuenta que realiza la acción.",
          },
        },
      },
    },
    "account-roles": {
      components: {
        table: {
          name: "Nombre del Rol",
          description: "Descripción",
          actions: "Acciones",
          level: "Nivel de Permiso",
          totalPermissions: "Total de Permisos",
          createdAt: "Creado El",

          total: "Mostrando {{range}} de {{total}} roles de cuenta",
          deleted: "Este rol ha sido eliminado",

          actionButtons: {
            trigger: "Acciones",
            update: "Actualizar",
            delete: "Eliminar",
            restore: "Restaurar",
          },
        },

        createModal: {
          title: "Crear Nuevo Rol de Cuenta",
          fields: {
            name: "Nombre del Rol",
            namePlaceholder: "Ingrese el nombre del rol",
            description: "Descripción",
            descriptionPlaceholder: "Ingrese una descripción para el rol",
            level: "Nivel de Permiso",
            levelPlaceholder: "Ingrese el nivel de permiso (número)",
          },
        },

        deleteModal: {
          title: "Eliminar Rol de Cuenta",
          description:
            "¿Está seguro de que desea eliminar este rol de cuenta? Esta acción se puede revertir más tarde.",
        },

        updateModal: {
          title: "Actualizar Rol de Cuenta",
          fields: {
            name: "Nombre del Rol",
            namePlaceholder: "Ingrese el nombre del rol",
            description: "Descripción",
            descriptionPlaceholder: "Ingrese una descripción para el rol",
            level: "Nivel de Permiso",
            levelPlaceholder: "Ingrese el nivel de permiso (número)",
            permissions: "Permisos",
          },
        },
      },

      hooks: {
        useCreateModal: {
          messages: {
            success: "Rol de cuenta creado exitosamente.",
            "name-too-short":
              "El nombre del rol debe tener al menos 3 caracteres.",
            "level-in-use":
              "El nivel de permiso especificado ya está en uso por otro rol. Por favor, elija un nivel diferente.",
            "level-too-high":
              "El nivel de permiso es superior al nivel de tu rol actual. No puedes crear un rol con un nivel de permiso superior al tuyo.",
            error:
              "Error al crear el rol de cuenta. Por favor, intente nuevamente.",
          },
        },

        useDeleteModal: {
          messages: {
            success: "Rol de cuenta eliminado exitosamente.",
            error:
              "Error al eliminar el rol de cuenta. Por favor, intente nuevamente.",
          },
        },

        useUpdateDrawer: {
          messages: {
            success: "Rol de cuenta actualizado exitosamente.",
            "name-too-short":
              "El nombre del rol debe tener al menos 3 caracteres.",
            "invalid-level":
              "El nivel de permiso debe ser un número entre 0 y 1000.",
            "level-in-use":
              "El nivel de permiso especificado ya está en uso por otro rol. Por favor, elija un nivel diferente.",
            "level-too-high":
              "El nivel de permiso es superior al nivel de tu rol actual. No puedes actualizar un rol a un nivel de permiso superior al tuyo.",
            error:
              "Error al actualizar el rol de cuenta. Por favor, intente nuevamente.",
          },
        },
      },
    },
  },

  layouts: {
    admin: {
      sidebar: {
        title: "Cosos rando",
        dashboard: "Panel de Control",
        "reports-group": {
          title: "Reportes",
        },
        management: {
          title: "Gestión del Sistema",
          logs: "Registros Técnicos",
          accounts: "Cuentas de Usuario",
          config: "Ajustes del sistema",
          "account-roles": "Roles de Cuenta",
        },
        about: "Acerca del Proyecto",
        logout: "Cerrar Sesión",
      },
    },
  },

  pages: {
    auth: {
      login: {
        title: "Iniciar Sesión",
        description: "Por favor, ingrese sus credenciales para iniciar sesión.",
        fields: {
          email: "Correo Electrónico",
          emailPlaceholder: "Ingrese su correo electrónico",
          password: "Contraseña",
          passwordPlaceholder: "Ingrese su contraseña",
          tfaCode: "Código de Autenticación de Dos Factores",
          tfaCodePlaceholder: "Ingrese su código TFA",
        },
        submit: "Iniciar Sesión",
        back: "Regresar al Inicio",

        messages: {
          success: "Inicio de sesión exitoso. Redirigiendo...",
          "invalid-credentials":
            "Credenciales inválidas. Por favor, verifique su correo electrónico y contraseña.",
          "tfa-required":
            "Se requiere autenticación de dos factores. Por favor, ingrese su código TFA.",
          "invalid-email": "El formato del correo electrónico es inválido.",
          "password-too-short":
            "La contraseña debe tener al menos 8 caracteres.",
        },
      },
      logout: {
        title: "Cerrar Sesión",
        description: "¿Está seguro de que desea cerrar sesión en su cuenta?",
        button: "Cerrar Sesión",
        cancel: "Cancelar",
      },
    },
    admin: {
      index: {
        greetings: {
          morning: "Buenos días",
          afternoon: "Buenas tardes",
          evening: "Buenas noches",
        },
        description:
          "Bienvenido al sistema administrativo de Sistema Random.",

        items: {
          index: "Panel De Control",
          title: "Panel de Control",

          accounts: {
            title: "Gestión de Cuentas",
            description:
              "Administra las cuentas de usuario dentro del sistema.",
          },
          "account-roles": {
            title: "Gestión de Roles de Cuenta",
            description:
              "Administra los roles y permisos de las cuentas de usuario.",
          },
        },
      },
      accounts: {
        title: "Gestión de Cuentas",
        description: "Administra las cuentas de usuario dentro del sistema.",
        createAccount: "Crear Nueva Cuenta",
        searchPlaceholder: "Buscar por nombre o correo electrónico",
        showDeleted: "Mostrar Cuentas Eliminadas",

        modals: {
          restore: {
            title: "Restaurar Cuenta",
            content:
              "¿Está seguro de que desea restaurar la cuenta de {{name}}?",
          },
          delete: {
            title: "Eliminar Cuenta",
            content:
              "¿Está seguro de que desea eliminar la cuenta de {{name}}? El correo electrónico será cambiado para liberar el correo original, pero el nombre permanecerá igual.",
          },
        },

        messages: {
          delete: {
            success: "Cuenta eliminada exitosamente.",
            "cannot-delete-due-to-role-level":
              "No se puede eliminar una cuenta con un rol de nivel igual o superior al de la cuenta que realiza la acción.",
          },
          restore: {
            success: "Cuenta restaurada exitosamente.",
          },
        },
      },
      "account-roles": {
        title: "Gestión de Roles de Cuenta",
        description:
          "Administra los roles y permisos de las cuentas de usuario.",
        createRole: "Crear Nuevo Rol de Cuenta",
        searchPlaceholder: "Buscar por nombre o descripción",
        showDeleted: "Mostrar Roles Eliminados",

        modals: {
          restore: {
            title: "Restaurar Rol de Cuenta",
            content:
              "¿Está seguro de que desea restaurar el rol de cuenta {{name}}?",
          },
          delete: {
            title: "Eliminar Rol de Cuenta",
            content:
              "¿Está seguro de que desea eliminar el rol de cuenta {{name}}?",
          },
        },

        messages: {
          delete: {
            success: "Rol de cuenta eliminado exitosamente.",
            "cannot-delete-due-to-assigned-accounts":
              "No se puede eliminar un rol de cuenta que tiene cuentas asignadas. Por favor, reasigne o elimine las cuentas asociadas antes de eliminar este rol.",
          },
          restore: {
            success: "Rol de cuenta restaurado exitosamente.",
          },
        },
      },
    },
  },
};

export default translation;
