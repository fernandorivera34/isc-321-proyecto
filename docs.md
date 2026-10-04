# Documentación del Proyecto: Template CRUD + MariaDB + RBAC

## ¿Qué es este proyecto?

Este proyecto es una **plantilla** o **template** para construir aplicaciones web completas que necesiten:

- **CRUD** (Crear, Leer, Actualizar, Eliminar) sobre una base de datos MariaDB.
- **RBAC** (Control de Acceso Basado en Roles) — es decir, un sistema de permisos donde cada usuario tiene un rol, y cada rol tiene permisos específicos sobre qué puede hacer en el sistema.
- **Panel de administración** con inicio de sesión, gestión de cuentas de usuario, roles y permisos.

Está construido como un **monorepositorio** — todo el proyecto vive en una sola carpeta, pero está dividido en tres áreas principales que se comunican entre sí: el **cliente** (frontend), el **servidor** (backend), y el **código compartido** (shared).

---

## Estructura General del Proyecto

```
template-crud-mariadb-rbac/
├── client/              ← Aplicación frontend (lo que ve el usuario en el navegador)
├── server/              ← Backend API (la lógica del servidor)
├── shared/              ← Código compartido entre cliente y servidor
├── prisma/              ← Definición de la base de datos y migraciones
├── docs/                ← Documentación del proyecto (formato MkDocs)
├── docs/es/             ← Documentación en español
│
├── compose.yaml         ← Configuración Docker Compose (MariaDB + Redis + servidor)
├── Dockerfile           ← Instrucciones para construir la imagen Docker
├── prisma.config.ts     ← Configuración de Prisma ORM
├── mkdocs.yml           ← Configuración del sitio de documentación
├── package.json         ← Configuración raíz del monorepositorio (npm workspaces)
├── package-lock.json    ← Versiones exactas de dependencias instaladas
└── docs.md              ← ESTE ARCHIVO — visión general del proyecto
```

---

## Carpetas Principales, Explicadas una por una

### `client/` — El Frontend (lo que ve el usuario)

Esta carpeta contiene todo el código de la interfaz de usuario. Está construida con:

- **React 19** — biblioteca para construir interfaces de usuario.
- **TypeScript** — JavaScript con tipos, para evitar errores.
- **Vite** — herramienta rápida para compilar y servir el frontend.
- **TanStack Router** — maneja las rutas/páginas de la aplicación (login, panel de control, cuentas, etc.).
- **Ant Design (antd)** — biblioteca de componentes de interfaz (tablas, botones, modales, formularios).
- **Tailwind CSS** — utilidades de estilos rápidas.
- **Redux Toolkit** — maneja el estado global de la aplicación (ej: datos del usuario autenticado).
- **i18next** — sistema de traducciones / internacionalización.

#### Archivos y carpetas dentro de `client/`:

| Archivo / Carpeta | ¿Qué es? |
|---|---|
| `client/src/main.tsx` | Punto de entrada de la aplicación. Renderiza el componente `<App />`. |
| `client/src/App.tsx` | Componente raíz. Configura Redux, el Router, y provee el contexto global. |
| `client/src/index.css` | Estilos globales (Tailwind CSS + estilos personalizados). |
| `client/src/i18n.ts` | Configuración del sistema de traducciones (i18next). |
| `client/src/store.ts` | Configuración del almacén de Redux (guarda el estado de la app). |
| `client/src/Context.tsx` | Contexto global simple de React. |
| `client/src/routeTree.gen.ts` | Árbol de rutas generado automáticamente por TanStack Router. |
| `client/src/reportWebVitals.ts` | Utilidad para medir rendimiento de la web. |
| `client/src/vite-env.d.ts` | Declaraciones de tipos para Vite. |
| `client/src/logo.svg` | Logo SVG de la aplicación. |
| `client/src/index.html` | Archivo HTML principal donde se monta React. |
| | |
| **`client/src/routes/`** | **Definición de páginas/rutas de la aplicación.** |
| `routes/__root.tsx` | Layout raíz — envuelve toda la app con el componente `<App />` de Ant Design. |
| `routes/index.tsx` | Página de inicio. Redirige automáticamente a `/admin`. |
| `routes/auth/login.tsx` | Página de inicio de sesión. |
| `routes/auth/logout.tsx` | Página de cierre de sesión. |
| `routes/admin/index.tsx` | Panel de control principal (dashboard) con tarjetas de acceso rápido. |
| `routes/admin/accounts/index.tsx` | Página de gestión de cuentas de usuario (listado, crear, editar, eliminar). |
| `routes/admin/accounts/roles.tsx` | Página de gestión de roles (listado, crear, editar, eliminar roles). |
| `routes/admin/config.tsx` | Página de configuración del sistema. |
| `routes/admin/logs.tsx` | Página de registros técnicos (logs). |
| `routes/errors/404.tsx` | Página de error 404 (página no encontrada). |
| `routes/errors/offline.tsx` | Página mostrada cuando no hay conexión. |
| | |
| **`client/src/layouts/`** | **Estructuras de página (layouts).** |
| `layouts/Admin.tsx` | Layout del panel de administración (sidebar con menú + contenido principal). |
| `layouts/General.tsx` | Layout general para páginas públicas (header + contenido + footer). |
| | |
| **`client/src/features/`** | **Módulos funcionales.** Cada feature agrupa su lógica, hooks, API y componentes. |
| `features/auth/` | Feature de autenticación (inicio/cierre de sesión, slice de Redux, API). |
| `features/accounts/` | Feature de cuentas (hooks, componentes y API para CRUD de cuentas). |
| `features/roles/` | Feature de roles (hooks, componentes y API para CRUD de roles). |
| | |
| **`client/src/features/accounts/components/`** | | |
| `AccountsTable.tsx` | Tabla que lista las cuentas de usuario. |
| `CreateAccountModal.tsx` | Modal para crear una nueva cuenta. |
| `UpdateModal.tsx` | Modal para actualizar una cuenta existente. |
| `ChangePasswordModal.tsx` | Modal para cambiar la contraseña de una cuenta. |
| `UpdateStatusModal.tsx` | Modal para activar/desactivar una cuenta. |
| | |
| **`client/src/features/accounts/hooks/`** | | |
| `useAccountsList.ts` | Hook para obtener y manejar la lista de cuentas. |
| `useAccountSearch.ts` | Hook para buscar cuentas por nombre o correo. |
| `useCreateModal.ts` | Hook que maneja la lógica del modal de creación. |
| `useUpdateModal.ts` | Hook que maneja la lógica del modal de actualización. |
| `useUpdatePassword.ts` | Hook para cambiar la contraseña. |
| `useUpdateStatus.ts` | Hook para cambiar el estado (activo/inactivo). |
| `useCreateAccountForm.ts` | Hook para el formulario de creación de cuenta. |
| | |
| **`client/src/features/roles/components/`** | | |
| `AccountRolesTable.tsx` | Tabla que lista los roles del sistema. |
| `CreateModal.tsx` | Modal para crear un nuevo rol. |
| `UpdateModal.tsx` | Modal/panel lateral para actualizar un rol y sus permisos. |
| | |
| **`client/src/features/roles/hooks/`** | | |
| `useList.ts` | Hook para obtener la lista de roles. |
| `useCreateModal.ts` | Hook que maneja la lógica del modal de creación de roles. |
| `useUpdateDrawer.ts` | Hook que maneja la lógica del panel de actualización de roles. |
| | |
| **`client/src/features/auth/`** | | |
| `api.ts` | Funciones para llamar a la API de autenticación. |
| `slice.ts` | Slice de Redux que guarda el estado de autenticación (sesión del usuario). |
| | |
| **`client/src/utils/`** | **Utilidades generales.** |
| `api.ts` | Utilidad para manejar errores de Axios (llamadas HTTP). |
| `permissions.ts` | Función `hasPermissions` para verificar permisos del usuario. |
| `logging.ts` | Utilidad de registro (logging) para el frontend. |
| | |
| **`client/src/locales/`** | | |
| `es.ts` | Traducciones al español de toda la interfaz del sistema. |
| | |
| **`client/src/components/`** | | |
| `Header.tsx` | Componente de encabezado (barra superior con navegación). |
| | |
| **`client/public/`** | Archivos estáticos (íconos, favicon, manifest, robots.txt). |
| **`client/.vscode/`** | Configuración de Visual Studio Code para el proyecto. |

---

### `server/` — El Backend (la API)

Esta carpeta contiene el servidor que procesa las peticiones del frontend, se conecta a la base de datos, maneja autenticación, y ejecuta la lógica de negocio. Usa:

- **Node.js + TypeScript** — JavaScript del lado del servidor con tipos.
- **Express 5** — framework para crear APIs HTTP.
- **Prisma** — ORM para conectarse a MariaDB y manejar la base de datos.
- **Passport.js** — middleware de autenticación (inicio de sesión local).
- **Socket.io** — comunicación en tiempo real (websockets).
- **Redis** — almacenamiento de sesiones en memoria rápida.
- **Zod** — validación de datos (schemas).
- **Nodemailer** — envío de correos electrónicos.
- **Bcrypt** — encriptación de contraseñas.
- **Nodemon** — herramienta que reinicia el servidor automáticamente al hacer cambios en desarrollo.

#### Archivos y carpetas dentro de `server/`:

| Archivo / Carpeta | ¿Qué es? |
|---|---|
| `server/src/index.ts` | Punto de entrada del servidor. Configura Express, middlewares, rutas, sesiones, y WebSockets. |
| `server/src/setup.ts` | Script de arranque inicial. Si el sistema está vacío, crea un rol Admin y un usuario administrador por defecto (admin@local.test / admin123). |
| `server/package.json` | Dependencias del servidor (no incluye las del root, solo las específicas del server). |
| `server/tsconfig.json` | Configuración de TypeScript. |
| `server/nodemon.json` | Configuración de Nodemon (qué archivos observar y cómo ejecutar). |
| `server/.gitignore` | Archivos ignorados por Git (node_modules, .env, etc.). |
| | |
| **`server/src/config/`** | **Configuraciones del servidor.** |
| `config/env.ts` | Carga variables de entorno (.env.dev o .env.prod) y valida que existan las requeridas. |
| `config/prisma.ts` | Inicializa y exporta el cliente de Prisma para consultar la base de datos. |
| `config/redis.ts` | Configuración de conexión a Redis. |
| | |
| **`server/src/routes/`** | **Definición de rutas de la API.** |
| `routes/index.ts` | Agrupa todas las rutas y las monta en Express (ej: `/api/auth`, `/api/accounts`, `/api/account-roles`). |
| `routes/auth.ts` | Rutas de autenticación: login, logout, obtener sesión actual. |
| `routes/accounts.ts` | Rutas de gestión de cuentas: crear, leer, listar, actualizar, eliminar, restaurar, cambiar estado, cambiar contraseña. |
| `routes/account-roles.ts` | Rutas de gestión de roles: crear, leer, listar, actualizar, eliminar, restaurar. |
| | |
| **`server/src/controllers/`** | **Controladores — manejan las peticiones HTTP.** |
| `controllers/auth/login.ts` | Controlador que procesa el inicio de sesión (usa Passport). |
| `controllers/auth/logout.ts` | Controlador que cierra la sesión. |
| `controllers/auth/fetch.ts` | Controlador que obtiene los datos del usuario autenticado. |
| `controllers/accounts/create.ts` | Crea una nueva cuenta de usuario. |
| `controllers/accounts/list.ts` | Lista todas las cuentas. |
| `controllers/accounts/get.ts` | Obtiene una cuenta específica por su ID. |
| `controllers/accounts/update.ts` | Actualiza los datos de una cuenta. |
| `controllers/accounts/delete.ts` | Elimina (soft-delete) una cuenta. |
| `controllers/accounts/restore.ts` | Restaura una cuenta eliminada. |
| `controllers/accounts/update-status.ts` | Activa o desactiva una cuenta. |
| `controllers/accounts/update-password.ts` | Cambia la contraseña de una cuenta. |
| `controllers/account-roles/create.ts` | Crea un nuevo rol. |
| `controllers/account-roles/list.ts` | Lista todos los roles. |
| `controllers/account-roles/get.ts` | Obtiene un rol específico por su ID. |
| `controllers/account-roles/update.ts` | Actualiza un rol. |
| `controllers/account-roles/delete.ts` | Elimina (soft-delete) un rol. |
| `controllers/account-roles/restore.ts` | Restaura un rol eliminado. |
| | |
| **`server/src/services/`** | **Servicios — lógica de negocio y acceso a datos.** |
| `services/logging.ts` | Servicio centralizado de registro (logs técnicos del sistema). |
| `services/sessions.ts` | Manejo del ciclo de vida de sesiones (crear, invalidar, refrescar). |
| `services/socket.ts` | Servicio de WebSockets para notificaciones en tiempo real. |
| `services/accounts/create.ts` | Lógica de creación de cuentas (con reintentos). |
| `services/accounts/update.ts` | Lógica de actualización de cuentas. |
| `services/accounts/delete.ts` | Lógica de eliminación de cuentas. |
| `services/accounts/restore.ts` | Lógica de restauración de cuentas. |
| `services/account-roles/create.ts` | Lógica de creación de roles. |
| `services/account-roles/update.ts` | Lógica de actualización de roles. |
| `services/account-roles/delete.ts` | Lógica de eliminación de roles. |
| `services/account-roles/restore.ts` | Lógica de restauración de roles. |
| | |
| **`server/src/utils/`** | **Utilidades del servidor.** |
| `utils/prisma.ts` | Cliente de Prisma compartido. |
| `utils/accounts.ts` | Funciones para verificar contraseñas (bcrypt) y crear objetos de sesión. |
| `utils/permissions.ts` | Función `hasPermissions` para verificar si un usuario tiene ciertos permisos. |
| | |
| **`server/src/middleware/`** | **Middlewares — funciones que se ejecutan antes de llegar a los controladores.** |
| `middleware/traceId.ts` | Asigna un ID único a cada petición para seguimiento en logs. |
| `middleware/sanitizeBody.ts` | Limpia los datos de entrada para evitar inyección de campos no esperados. |
| `middleware/validationMiddleware.ts` | Valida los datos de entrada usando Zod (schemas). |
| `middleware/authMiddleware.ts` | Verifica que el usuario esté autenticado antes de acceder a rutas protegidas. |
| | |
| **`server/src/errors/`** | | |
| `errors/api.ts` | Definición de errores personalizados de la API. |
| | |
| **`server/src/types/`** | | |
| `types/index.ts` | Tipos de TypeScript específicos del servidor. |

---

### `shared/` — Código Compartido

Esta carpeta contiene código que se usa **tanto en el cliente como en el servidor**, para mantener la consistencia y evitar repetir definiciones. No tiene lógica de negocio, solo definiciones.

| Archivo / Carpeta | ¿Qué es? |
|---|---|
| **`shared/api/`** | **Contratos de la API.** Define los tipos de las peticiones y respuestas de cada endpoint. |
| `api/index.ts` | Define los estados de respuesta posibles: success, error, no autorizado, etc. |
| `api/auth.ts` | Tipos para las peticiones/respuestas de autenticación. |
| `api/accounts.ts` | Tipos para las peticiones/respuestas de cuentas. |
| `api/account-roles.ts` | Tipos para las peticiones/respuestas de roles. |
| | |
| **`shared/schemas/`** | **Validación de datos con Zod.** Define las reglas que los datos deben cumplir. |
| `schemas/index.ts` | Utilidades compartidas de Zod (validar IDs, fechas, campos opcionales, etc.). |
| `schemas/auth.ts` | Esquemas de validación para autenticación. |
| `schemas/accounts.ts` | Esquemas de validación para cuentas. |
| `schemas/account-roles.ts` | Esquemas de validación para roles. |
| `schemas/logs.ts` | Esquemas de validación para logs. |
| `schemas/files.ts` | Esquemas de validación para archivos. |
| | |
| **`shared/types/`** | **Definiciones de tipos TypeScript.** |
| `types/permissions.d.ts` | Define todos los permisos posibles del sistema (accounts:read, accounts:create, reports:export, etc.). |
| `types/sessions.d.ts` | Define la estructura de una sesión de usuario. |
| `types/custom.d.ts` | Tipos personalizados adicionales. |
| | |
| **`shared/models/`** | **Modelos de datos (definiciones de TypeScript).** |
| `models/account.d.ts` | Estructura de una cuenta de usuario (tipo `IAccount`). |
| `models/account-role.d.ts` | Estructura de un rol (tipo `IAccountRole`). |
| `models/log.d.ts` | Estructura de un registro de log. |
| `models/metadata.d.ts` | Estructura de metadatos (información de seguimiento: quién creó, cuándo, etc.). |
| `models/index.d.ts` | Exporta todos los modelos y define tipos adicionales como CampusCode, estados de respuesta, etc. |
| | |
| **`shared/constants/`** | | |
| `constants/permissions.ts` | Lista completa de todos los permisos disponibles en el sistema. |
| | |
| `shared/tsconfig.json` | Configuración de TypeScript para el área compartida. |

---

### `prisma/` — Base de Datos

Esta carpeta contiene la definición de la base de datos y el historial de cambios (migraciones).

| Archivo / Carpeta | ¿Qué es? |
|---|---|
| `prisma/schema.prisma` | **El archivo más importante de la base de datos.** Define todas las tablas (modelos), sus columnas, tipos de datos, y relaciones entre ellas. Es la fuente de verdad de la estructura de la base de datos. |
| `prisma/migrations/` | Historial de migraciones — cambios que se han aplicado a la base de datos a lo largo del tiempo. Cada migración contiene el SQL necesario para modificar la base de datos. |
| `prisma/migrations/migration_lock.toml` | Archivo de bloqueo que indica que el proveedor de base de datos es MySQL (MariaDB). |

#### Modelos definidos en `schema.prisma`:

| Modelo (tabla) | ¿Qué almacena? |
|---|---|
| **AccountRole** | Roles del sistema (nombre, descripción, nivel, permisos, si requiere doble factor). |
| **Account** | Cuentas de usuario (correo, nombre, contraseña encriptada, estado, rol asignado, configuración de doble factor, códigos de verificación). |
| **Metadata** | Metadatos de seguimiento (quién creó, actualizó, eliminó un registro, cuándo, estado, fuente, notas, etiquetas). |
| **MetadataUpdateHistory** | Historial de cambios en metadatos (qué cambió, quién lo cambió, cuándo). |
| **Config** | Configuración del sistema (vinculada a metadatos). |
| **Session** | Sesiones de usuario activas (datos de la sesión, fecha de expiración). |
| **Log** | Registros técnicos del sistema (fecha, fuente, nivel, mensaje, duración, detalles). |

---

### `docs/` — Documentación del Proyecto

Esta carpeta contiene la documentación en formato Markdown, diseñada para ser usada con **MkDocs** (una herramienta que genera sitios web de documentación a partir de archivos Markdown).

| Archivo | ¿Qué contiene? |
|---|---|
| `docs/index.md` | Página de inicio de la documentación. |
| `docs/architecture.md` | Descripción de la arquitectura del proyecto (monorepo, cliente/servidor/shared). |
| `docs/client.md` | Cómo funciona el frontend y cómo ejecutarlo. |
| `docs/server.md` | Cómo funciona el backend y cómo ejecutarlo. |
| `docs/api.md` | Referencia de la API: endpoints, estructura de rutas, autenticación. |
| `docs/prisma.md` | Cómo usar Prisma (generar cliente, migraciones). |
| `docs/routes.md` | Referencia de rutas del servidor. |
| `docs/schemas.md` | Esquemas de validación de datos. |
| `docs/middleware.md` | Middlewares del servidor. |
| `docs/services.md` | Servicios del servidor. |
| `docs/usage.md` | Cómo usar el sistema localmente. |
| `docs/testing.md` | Estrategia de pruebas. |
| `docs/deployment.md` | Guía de despliegue a producción. |
| `docs/security.md` | Consideraciones de seguridad. |
| `docs/localization.md` | Cómo funciona la internacionalización (traducciones). |
| `docs/diagrams.md` | Diagramas de arquitectura (flujo de datos). |
| `docs/CONTRIBUTING.md` | Guía para contribuir al proyecto. |
| `docs/features/accounts.md` | Documentación del feature de cuentas. |
| `docs/features/auth.md` | Documentación del feature de autenticación. |
| `docs/features/roles.md` | Documentación del feature de roles. |
| `docs/es/index.md` | Página de inicio de la documentación en español. |
| `docs/.obsidian/` | Configuración de Obsidian (editor de Markdown) para trabajar en la documentación. |

---

### Archivos en la Raíz del Proyecto

| Archivo | ¿Qué es? |
|---|---|
| **`package.json`** | Archivo principal del monorepositorio. Define los "workspaces" (client, server, shared) para que npm maneje las dependencias de forma unificada. Contiene scripts para construir (`build`), desarrollar (`dev`), y documentar (`docs`). El repositorio está vinculado a GitHub como `https://github.com/Asterki/pumai`. |
| **`compose.yaml`** | Define los servicios de Docker: **MariaDB** (base de datos), **Redis** (caché de sesiones), y el **servidor** (construye la imagen y expone el puerto 3000). Con `docker compose up` se levanta todo el entorno. |
| **`Dockerfile`** | Instrucciones para construir una imagen Docker del proyecto completo. Instala dependencias, genera el cliente de Prisma, compila el servidor y el frontend, y copia todo en una imagen lista para producción. |
| **`prisma.config.ts`** | Configuración de Prisma que indica dónde está el schema, las migraciones, y cómo obtener la URL de la base de datos (desde `.env.dev` o `.env.prod`). |
| **`mkdocs.yml`** | Configuración de MkDocs para generar el sitio web de documentación. Define la estructura del menú de navegación. |
| **`package-lock.json`** | Archivo generado automáticamente que fija las versiones exactas de todas las dependencias instaladas. |

---

## Cómo se conectan las partes

1. **El usuario abre el frontend** (`client/`) en su navegador.
2. **El frontend hace peticiones HTTP** a la API del servidor (`server/`) usando las definiciones de `shared/api/`.
3. **El servidor recibe la petición**, pasa por los middlewares (validación, autenticación), llega al controlador correspondiente.
4. **El controlador llama a un servicio** (`server/src/services/`) que contiene la lógica de negocio.
5. **El servicio usa Prisma** para leer o escribir en la base de datos MariaDB.
6. **La respuesta viaja de vuelta** — servicio → controlador → middleware → frontend.
7. **El frontend actualiza la interfaz** con los datos recibidos.

## Cómo ejecutar el proyecto

### En desarrollo:

**1. Base de datos:** Necesitas MariaDB corriendo. Puedes usar Docker:
```bash
docker compose up mariadb redis -d
```

**2. Variables de entorno:** Crea un archivo `.env.dev` en la raíz con:
```
DATABASE_URL="mysql://usuario:contraseña@localhost:3306/nombre_bd"
ALLOWED_ORIGINS="http://localhost:2173"
SESSION_SECRET="tu_secreto_aqui"
PORT=3000
```

**3. Servidor:**
```bash
cd server
npm install
npm run dev    # Arranca con nodemon, se reinicia solo al cambiar código
```

**4. Frontend:**
```bash
cd client
npm install
npm run dev    # Arranca en http://localhost:2173
```

### En producción (Docker):

```bash
docker compose up --build
```

Esto construye la imagen y levanta MariaDB, Redis, y el servidor en el puerto 3000.

### Usuario administrador por defecto:

Al iniciar el sistema por primera vez, el `setup.ts` crea automáticamente:
- **Correo:** admin@local.test
- **Contraseña:** admin123
- **Rol:** Admin (con todos los permisos, incluyendo `*`)

---

## Resumen de Tecnologías Usadas

| Área | Tecnologías |
|---|---|
| **Frontend** | React 19, TypeScript, Vite, TanStack Router, Ant Design, Tailwind CSS, Redux Toolkit, i18next, Axios, Socket.io-client, React-Leaflet, Recharts |
| **Backend** | Node.js, TypeScript, Express 5, Prisma, Passport.js, Socket.io, Redis, Zod, Bcrypt, Nodemailer |
| **Base de Datos** | MariaDB (vía Prisma ORM) |
| **Infraestructura** | Docker, Docker Compose |
| **Documentación** | MkDocs, Obsidian |

---

## Notas Finales

- Toda la validación de datos está centralizada en `shared/schemas/` usando **Zod**, y se usa tanto en el frontend como en el backend.
- El sistema de **permisos** (RBAC) está definido en `shared/constants/permissions.ts` y verificado con `hasPermissions` tanto en el cliente (`client/src/utils/permissions.ts`) como en el servidor (`server/src/utils/permissions.ts`).
- Las cuentas y roles usan **soft-delete**: al "eliminar" un registro, en realidad se marca como eliminado sin borrarlo de la base de datos. Se puede restaurar después.
- El frontend está completamente traducido al español (ver `client/src/locales/es.ts`).
