-- =====================================================================
-- LinkedInChino - Esquema rediseñado (MySQL 8.0.16+ por uso de CHECK; recomendado 8.0.30+)
-- Convenciones: snake_case, BIGINT UNSIGNED AUTO_INCREMENT, utf8mb4, borrado logico (activo/deleted_at),
-- created_at/updated_at. Las reglas de negocio complejas (no auto-revision, nivel de comentario = padre+1,
-- conexion aceptada para chatear, permisos por rol de empresa) se validan en la aplicacion.
-- Cada linea lleva un comentario: que hace y por que es necesaria.
-- =====================================================================
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `agarra_la_pala` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `agarra_la_pala`;

-- -----------------------------------------------------
-- Tabla `usuario`: Cuenta unica del sistema: persona, candidato y reclutador a la vez (el rol de reclutador depende de la empresa)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `primer_nombre` VARCHAR(60) NOT NULL COMMENT 'Primer nombre; necesario para mostrar la identidad del usuario',  -- Primer nombre; necesario para mostrar la identidad del usuario
  `segundo_nombre` VARCHAR(60) NULL COMMENT 'Segundo nombre opcional; no todas las personas lo tienen',  -- Segundo nombre opcional; no todas las personas lo tienen
  `primer_apellido` VARCHAR(60) NOT NULL COMMENT 'Primer apellido; necesario para identificar a la persona',  -- Primer apellido; necesario para identificar a la persona
  `segundo_apellido` VARCHAR(60) NULL COMMENT 'Segundo apellido opcional; comun en paises hispanohablantes',  -- Segundo apellido opcional; comun en paises hispanohablantes
  `genero` ENUM('masculino','femenino','otro','prefiere_no_decir') NULL COMMENT 'Genero declarado; opcional por privacidad',  -- Genero declarado; opcional por privacidad
  `fecha_nacimiento` DATE NULL COMMENT 'Fecha de nacimiento; opcional (puede venir vacia con login de Google) y sirve para validar edad minima',  -- Fecha de nacimiento; opcional (puede venir vacia con login de Google) y sirve para validar edad minima
  `ubicacion` VARCHAR(200) NOT NULL DEFAULT '' COMMENT 'Ciudad y pais de residencia en texto; se muestra en perfil y filtra ofertas cercanas',  -- Ciudad y pais de residencia en texto; se muestra en perfil y filtra ofertas cercanas
  `password_hash` VARCHAR(255) NULL COMMENT 'Hash de contrasena (bcrypt o argon2, nunca texto plano); NULL si la cuenta solo usa Google',  -- Hash de contrasena (bcrypt o argon2, nunca texto plano); NULL si la cuenta solo usa Google
  `rol_sistema` ENUM('usuario','administrador_sistema') NOT NULL DEFAULT 'usuario' COMMENT 'Rol global: usuario normal (incluye reclutadores) o administrador del sistema con panel propio',  -- Rol global: usuario normal (incluye reclutadores) o administrador del sistema con panel propio
  `avatar_archivo_id` BIGINT UNSIGNED NULL COMMENT 'Foto de perfil del usuario; reutiliza la tabla de archivos',  -- Foto de perfil del usuario; reutiliza la tabla de archivos
  `ultimo_login_at` DATETIME NULL COMMENT 'Ultimo inicio de sesion; seguridad y deteccion de cuentas inactivas',  -- Ultimo inicio de sesion; seguridad y deteccion de cuentas inactivas
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_usuario_avatar_archivo_id` (`avatar_archivo_id`),  -- Indice de avatar_archivo_id; acelera joins y filtros por esta relacion
  KEY `idx_usuario_nombre` (`primer_apellido`, `primer_nombre`),  -- Busqueda de personas por apellido y nombre
  KEY `idx_usuario_rol_activo` (`rol_sistema`, `activo`),  -- Listar administradores y usuarios activos rapidamente
  CONSTRAINT `fk_usuario_avatar_archivo_id` FOREIGN KEY (`avatar_archivo_id`) REFERENCES `archivo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia archivo; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cuenta unica del sistema: persona, candidato y reclutador a la vez (el rol de reclutador depende de la empresa)';

-- -----------------------------------------------------
-- Tabla `usuario_correo`: Correos de un usuario; el primario y verificado es el usado para iniciar sesion
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario_correo` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario dueno del correo',  -- Usuario dueno del correo
  `correo` VARCHAR(255) NOT NULL COMMENT 'Direccion de correo; identificador de login y canal de comunicacion',  -- Direccion de correo; identificador de login y canal de comunicacion
  `verificado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si el usuario confirmo el correo con token; solo correos verificados pueden ser de login',  -- 1 si el usuario confirmo el correo con token; solo correos verificados pueden ser de login
  `verificado_at` DATETIME NULL COMMENT 'Momento de verificacion; trazabilidad',  -- Momento de verificacion; trazabilidad
  `es_primario` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si es el correo principal de login y notificaciones',  -- 1 si es el correo principal de login y notificaciones
  `publico` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si se muestra en el perfil; control de privacidad',  -- 1 si se muestra en el perfil; control de privacidad
  `primario_key` TINYINT GENERATED ALWAYS AS (IF(`es_primario` = 1 AND `activo` = 1, 1, NULL)) VIRTUAL COMMENT 'Columna calculada para forzar un unico correo primario activo por usuario',  -- Columna calculada para forzar un unico correo primario activo por usuario
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_usuario_correo_correo` (`correo`),  -- Un correo pertenece a una sola cuenta; evita duplicados (collation ai_ci ignora mayusculas)
  UNIQUE KEY `uq_usuario_correo_primario` (`usuario_id`, `primario_key`),  -- Garantiza un solo correo primario activo por usuario (NULL no choca)
  CONSTRAINT `fk_usuario_correo_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Correos de un usuario; el primario y verificado es el usado para iniciar sesion';

-- -----------------------------------------------------
-- Tabla `usuario_telefono`: Telefonos de contacto de un usuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario_telefono` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario dueno del telefono',  -- Usuario dueno del telefono
  `numero` VARCHAR(25) NOT NULL COMMENT 'Numero en formato internacional E.164 (hasta 15 digitos con +); VARCHAR conserva ceros y signo +',  -- Numero en formato internacional E.164 (hasta 15 digitos con +); VARCHAR conserva ceros y signo +
  `verificado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si se verifico por SMS u otro medio; confianza del contacto',  -- 1 si se verifico por SMS u otro medio; confianza del contacto
  `es_primario` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si es el telefono principal',  -- 1 si es el telefono principal
  `publico` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si es visible en el perfil; privacidad',  -- 1 si es visible en el perfil; privacidad
  `primario_key` TINYINT GENERATED ALWAYS AS (IF(`es_primario` = 1 AND `activo` = 1, 1, NULL)) VIRTUAL COMMENT 'Columna calculada para forzar un unico telefono primario activo por usuario',  -- Columna calculada para forzar un unico telefono primario activo por usuario
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_usuario_telefono_primario` (`usuario_id`, `primario_key`),  -- Un solo telefono primario activo por usuario
  KEY `idx_usuario_telefono_numero` (`numero`),  -- Busqueda por numero
  CONSTRAINT `fk_usuario_telefono_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Telefonos de contacto de un usuario';

-- -----------------------------------------------------
-- Tabla `usuario_identidad_externa`: Vinculo de una cuenta con un proveedor de login externo (por ahora solo Google)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario_identidad_externa` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario al que pertenece la identidad externa',  -- Usuario al que pertenece la identidad externa
  `proveedor` ENUM('google') NOT NULL COMMENT 'Proveedor OAuth; ENUM extensible si se agregan otros',  -- Proveedor OAuth; ENUM extensible si se agregan otros
  `subject_id` VARCHAR(191) NOT NULL COMMENT 'Identificador estable del usuario en el proveedor (claim sub); no cambia aunque cambie el correo',  -- Identificador estable del usuario en el proveedor (claim sub); no cambia aunque cambie el correo
  `correo_proveedor` VARCHAR(255) NULL COMMENT 'Correo reportado por el proveedor; referencia al vincular',  -- Correo reportado por el proveedor; referencia al vincular
  `ultimo_login_at` DATETIME NULL COMMENT 'Ultimo login con este proveedor; auditoria',  -- Ultimo login con este proveedor; auditoria
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_identidad_proveedor_subject` (`proveedor`, `subject_id`),  -- Una identidad externa solo puede estar ligada a un usuario
  UNIQUE KEY `uq_identidad_usuario_proveedor` (`usuario_id`, `proveedor`),  -- Un usuario vincula una sola cuenta por proveedor
  CONSTRAINT `fk_usuario_identidad_externa_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Vinculo de una cuenta con un proveedor de login externo (por ahora solo Google)';

-- -----------------------------------------------------
-- Tabla `usuario_token_verificacion`: Tokens de un solo uso para verificar un correo
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario_token_verificacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_correo_id` BIGINT UNSIGNED NOT NULL COMMENT 'Correo que se verifica con este token',  -- Correo que se verifica con este token
  `token_hash` CHAR(64) NOT NULL COMMENT 'Hash SHA-256 del token enviado; no se guarda el token en claro por seguridad',  -- Hash SHA-256 del token enviado; no se guarda el token en claro por seguridad
  `expira_at` DATETIME NOT NULL COMMENT 'Fecha de expiracion; limita la ventana de uso',  -- Fecha de expiracion; limita la ventana de uso
  `usado_at` DATETIME NULL COMMENT 'Momento de uso (NULL si no se uso); evita reutilizacion',  -- Momento de uso (NULL si no se uso); evita reutilizacion
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de emision del token',  -- Fecha de emision del token
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_usuario_token_verificacion_usuario_correo_id` (`usuario_correo_id`),  -- Indice de usuario_correo_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_token_verificacion_hash` (`token_hash`),  -- Busqueda rapida y unicidad del token
  KEY `idx_token_verificacion_expira` (`expira_at`),  -- Limpieza de tokens expirados
  CONSTRAINT `fk_usuario_token_verificacion_usuario_correo_id` FOREIGN KEY (`usuario_correo_id`) REFERENCES `usuario_correo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario_correo; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Tokens de un solo uso para verificar un correo';

-- -----------------------------------------------------
-- Tabla `usuario_token_recuperacion`: Tokens de un solo uso para restablecer la contrasena
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario_token_recuperacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que solicito recuperar su contrasena',  -- Usuario que solicito recuperar su contrasena
  `token_hash` CHAR(64) NOT NULL COMMENT 'Hash SHA-256 del token enviado por correo; no se guarda en claro',  -- Hash SHA-256 del token enviado por correo; no se guarda en claro
  `expira_at` DATETIME NOT NULL COMMENT 'Fecha de expiracion; reduce riesgo de tokens robados',  -- Fecha de expiracion; reduce riesgo de tokens robados
  `usado_at` DATETIME NULL COMMENT 'Momento de uso; evita reutilizacion',  -- Momento de uso; evita reutilizacion
  `ip_solicitud` VARCHAR(45) NULL COMMENT 'IP (IPv4 o IPv6) de la solicitud; deteccion de abuso',  -- IP (IPv4 o IPv6) de la solicitud; deteccion de abuso
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de emision del token',  -- Fecha de emision del token
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_usuario_token_recuperacion_usuario_id` (`usuario_id`),  -- Indice de usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_token_recuperacion_hash` (`token_hash`),  -- Busqueda rapida y unicidad del token
  KEY `idx_token_recuperacion_expira` (`expira_at`),  -- Limpieza de tokens expirados
  CONSTRAINT `fk_usuario_token_recuperacion_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Tokens de un solo uso para restablecer la contrasena';

-- -----------------------------------------------------
-- Tabla `usuario_preferencia`: Preferencias de interfaz y notificaciones (1:1 con usuario)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `usuario_preferencia` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario dueno de las preferencias',  -- Usuario dueno de las preferencias
  `idioma_codigo` VARCHAR(10) NOT NULL DEFAULT 'es' COMMENT 'Codigo de idioma de la interfaz (es, en, pt-BR); mejora la experiencia',  -- Codigo de idioma de la interfaz (es, en, pt-BR); mejora la experiencia
  `tema` ENUM('claro','oscuro','sistema') NOT NULL DEFAULT 'sistema' COMMENT 'Tema visual preferido',  -- Tema visual preferido
  `zona_horaria` VARCHAR(64) NOT NULL DEFAULT 'UTC' COMMENT 'Zona horaria IANA; mostrar fechas locales aunque se guarden en UTC',  -- Zona horaria IANA; mostrar fechas locales aunque se guarden en UTC
  `notificar_por_correo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 si desea recibir notificaciones por correo',  -- 1 si desea recibir notificaciones por correo
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_usuario_preferencia_usuario` (`usuario_id`),  -- Garantiza relacion 1:1 con usuario
  CONSTRAINT `fk_usuario_preferencia_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Preferencias de interfaz y notificaciones (1:1 con usuario)';

-- -----------------------------------------------------
-- Tabla `perfil`: Perfil publico del usuario, uno por usuario (1:1)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `perfil` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario dueno del perfil',  -- Usuario dueno del perfil
  `titular` VARCHAR(220) NOT NULL DEFAULT '' COMMENT 'Titular profesional corto (headline); primera impresion del perfil',  -- Titular profesional corto (headline); primera impresion del perfil
  `acerca_de` TEXT NULL COMMENT 'Descripcion extensa; el limite anterior de 45 caracteres era insuficiente',  -- Descripcion extensa; el limite anterior de 45 caracteres era insuficiente
  `sitio_web` VARCHAR(255) NULL COMMENT 'Sitio o portafolio personal',  -- Sitio o portafolio personal
  `publico` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 si el perfil es visible para cualquiera; privacidad',  -- 1 si el perfil es visible para cualquiera; privacidad
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_perfil_usuario` (`usuario_id`),  -- Un solo perfil por usuario
  FULLTEXT KEY `ft_perfil_busqueda` (`titular`, `acerca_de`),  -- Busqueda de texto de perfiles
  CONSTRAINT `fk_perfil_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Perfil publico del usuario, uno por usuario (1:1)';

-- -----------------------------------------------------
-- Tabla `archivo`: Archivos subidos guardados en disco; solo se almacena su ruta y metadatos
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `archivo` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `subido_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que subio el archivo; responsabilidad y permisos',  -- Usuario que subio el archivo; responsabilidad y permisos
  `nombre_original` VARCHAR(255) NOT NULL COMMENT 'Nombre con el que el usuario subio el archivo; para descarga',  -- Nombre con el que el usuario subio el archivo; para descarga
  `ruta_almacenamiento` VARCHAR(500) NOT NULL COMMENT 'Ruta relativa al directorio base configurado; evita rutas absolutas atadas al servidor',  -- Ruta relativa al directorio base configurado; evita rutas absolutas atadas al servidor
  `url_publica` VARCHAR(1000) NULL COMMENT 'URL de acceso si el archivo es publico; NULL si requiere autorizacion',  -- URL de acceso si el archivo es publico; NULL si requiere autorizacion
  `mime_type` VARCHAR(127) NOT NULL COMMENT 'Tipo MIME; validacion y cabeceras de descarga',  -- Tipo MIME; validacion y cabeceras de descarga
  `extension` VARCHAR(10) NOT NULL COMMENT 'Extension sin punto; validacion contra la lista permitida',  -- Extension sin punto; validacion contra la lista permitida
  `tamano_bytes` BIGINT UNSIGNED NOT NULL COMMENT 'Tamano en bytes; control de cuotas y limites',  -- Tamano en bytes; control de cuotas y limites
  `hash_sha256` CHAR(64) NOT NULL COMMENT 'Huella del contenido; detectar duplicados e integridad',  -- Huella del contenido; detectar duplicados e integridad
  `proposito` ENUM('avatar','logo_empresa','cv','adjunto_publicacion','adjunto_mensaje','otro') NOT NULL DEFAULT 'otro' COMMENT 'Uso previsto; facilita reglas y limpieza',  -- Uso previsto; facilita reglas y limpieza
  `visibilidad` ENUM('publico','privado') NOT NULL DEFAULT 'privado' COMMENT 'Define si se sirve sin autenticacion; seguridad por defecto privada',  -- Define si se sirve sin autenticacion; seguridad por defecto privada
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_archivo_subido_por_usuario_id` (`subido_por_usuario_id`),  -- Indice de subido_por_usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_archivo_ruta` (`ruta_almacenamiento`),  -- Una ruta en disco solo puede pertenecer a un registro
  KEY `idx_archivo_hash` (`hash_sha256`),  -- Busqueda de duplicados
  KEY `idx_archivo_subido_fecha` (`subido_por_usuario_id`, `created_at`),  -- Listar archivos de un usuario por fecha
  CONSTRAINT `fk_archivo_subido_por_usuario_id` FOREIGN KEY (`subido_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Archivos subidos guardados en disco; solo se almacena su ruta y metadatos';

-- -----------------------------------------------------
-- Tabla `moneda`: Catalogo de monedas ISO 4217 para salarios
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `moneda` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `codigo` CHAR(3) NOT NULL COMMENT 'Codigo ISO 4217 (USD, MXN); estandar internacional',  -- Codigo ISO 4217 (USD, MXN); estandar internacional
  `nombre` VARCHAR(60) NOT NULL COMMENT 'Nombre legible de la moneda',  -- Nombre legible de la moneda
  `simbolo` VARCHAR(8) NULL COMMENT 'Simbolo para mostrar en interfaz',  -- Simbolo para mostrar en interfaz
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_moneda_codigo` (`codigo`)  -- No repetir monedas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Catalogo de monedas ISO 4217 para salarios';

-- -----------------------------------------------------
-- Tabla `empresa`: Empresa u organizacion; puede ser creada por cualquier usuario y verificada por un administrador del sistema
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `empresa` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `nombre` VARCHAR(150) NOT NULL COMMENT 'Nombre comercial; identifica la empresa',  -- Nombre comercial; identifica la empresa
  `slug` VARCHAR(160) NOT NULL COMMENT 'Identificador amigable para URLs; enlaces limpios y unicos',  -- Identificador amigable para URLs; enlaces limpios y unicos
  `rubro` VARCHAR(100) NULL COMMENT 'Industria o sector; filtros y clasificacion',  -- Industria o sector; filtros y clasificacion
  `tamano` ENUM('1_10','11_50','51_200','201_500','501_1000','1001_5000','mas_5000') NULL COMMENT 'Rango de empleados; ENUM reemplaza texto libre y permite filtrar',  -- Rango de empleados; ENUM reemplaza texto libre y permite filtrar
  `ubicacion` VARCHAR(200) NULL COMMENT 'Sede principal en texto; mostrar y buscar por ubicacion',  -- Sede principal en texto; mostrar y buscar por ubicacion
  `sitio_web` VARCHAR(255) NULL COMMENT 'Sitio oficial de la empresa',  -- Sitio oficial de la empresa
  `descripcion` TEXT NULL COMMENT 'Presentacion de la empresa',  -- Presentacion de la empresa
  `logo_archivo_id` BIGINT UNSIGNED NULL COMMENT 'Logo de la empresa',  -- Logo de la empresa
  `creado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que registro la empresa; se vuelve propietario inicial',  -- Usuario que registro la empresa; se vuelve propietario inicial
  `verificada` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si un administrador del sistema valido la empresa; genera confianza',  -- 1 si un administrador del sistema valido la empresa; genera confianza
  `verificada_por_usuario_id` BIGINT UNSIGNED NULL COMMENT 'Administrador del sistema que verifico la empresa',  -- Administrador del sistema que verifico la empresa
  `verificada_at` DATETIME NULL COMMENT 'Momento de verificacion; auditoria',  -- Momento de verificacion; auditoria
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_empresa_logo_archivo_id` (`logo_archivo_id`),  -- Indice de logo_archivo_id; acelera joins y filtros por esta relacion
  KEY `idx_empresa_creado_por_usuario_id` (`creado_por_usuario_id`),  -- Indice de creado_por_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_empresa_verificada_por_usuario_id` (`verificada_por_usuario_id`),  -- Indice de verificada_por_usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_empresa_slug` (`slug`),  -- URL unica por empresa
  KEY `idx_empresa_nombre` (`nombre`),  -- Busqueda por nombre
  KEY `idx_empresa_verificada_activo` (`verificada`, `activo`),  -- Filtrar empresas verificadas y activas
  CONSTRAINT `fk_empresa_logo_archivo_id` FOREIGN KEY (`logo_archivo_id`) REFERENCES `archivo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia archivo; impide referencias huerfanas
  CONSTRAINT `fk_empresa_creado_por_usuario_id` FOREIGN KEY (`creado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_empresa_verificada_por_usuario_id` FOREIGN KEY (`verificada_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Empresa u organizacion; puede ser creada por cualquier usuario y verificada por un administrador del sistema';

-- -----------------------------------------------------
-- Tabla `empresa_correo`: Correos de contacto de una empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `empresa_correo` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa dueña del correo',  -- Empresa dueña del correo
  `correo` VARCHAR(255) NOT NULL COMMENT 'Direccion de contacto de la empresa',  -- Direccion de contacto de la empresa
  `verificado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si fue verificado',  -- 1 si fue verificado
  `es_primario` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si es el correo principal',  -- 1 si es el correo principal
  `publico` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 si se muestra en la pagina de empresa',  -- 1 si se muestra en la pagina de empresa
  `primario_key` TINYINT GENERATED ALWAYS AS (IF(`es_primario` = 1 AND `activo` = 1, 1, NULL)) VIRTUAL COMMENT 'Calculada: fuerza un unico correo primario activo por empresa',  -- Calculada: fuerza un unico correo primario activo por empresa
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_empresa_correo` (`empresa_id`, `correo`),  -- Evita repetir el mismo correo en una empresa
  UNIQUE KEY `uq_empresa_correo_primario` (`empresa_id`, `primario_key`),  -- Un solo correo primario activo por empresa
  CONSTRAINT `fk_empresa_correo_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia empresa; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Correos de contacto de una empresa';

-- -----------------------------------------------------
-- Tabla `empresa_telefono`: Telefonos de contacto de una empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `empresa_telefono` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa dueña del telefono',  -- Empresa dueña del telefono
  `numero` VARCHAR(25) NOT NULL COMMENT 'Numero en formato internacional',  -- Numero en formato internacional
  `verificado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si fue verificado',  -- 1 si fue verificado
  `es_primario` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si es el telefono principal',  -- 1 si es el telefono principal
  `publico` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 si se muestra publicamente',  -- 1 si se muestra publicamente
  `primario_key` TINYINT GENERATED ALWAYS AS (IF(`es_primario` = 1 AND `activo` = 1, 1, NULL)) VIRTUAL COMMENT 'Calculada: fuerza un unico telefono primario activo por empresa',  -- Calculada: fuerza un unico telefono primario activo por empresa
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_empresa_telefono` (`empresa_id`, `numero`),  -- Evita repetir numero en una empresa
  UNIQUE KEY `uq_empresa_telefono_primario` (`empresa_id`, `primario_key`),  -- Un solo telefono primario activo por empresa
  CONSTRAINT `fk_empresa_telefono_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia empresa; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Telefonos de contacto de una empresa';

-- -----------------------------------------------------
-- Tabla `empresa_miembro`: Relacion N:M usuario-empresa con rol; un usuario puede trabajar en varias empresas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `empresa_miembro` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa a la que pertenece el miembro',  -- Empresa a la que pertenece el miembro
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario miembro',  -- Usuario miembro
  `rol_empresa` ENUM('propietario','administrador','reclutador','empleado') NOT NULL DEFAULT 'empleado' COMMENT 'Rol dentro de la empresa: define si gestiona, recluta (revisa aplicaciones y ve mensajes) o solo es empleado',  -- Rol dentro de la empresa: define si gestiona, recluta (revisa aplicaciones y ve mensajes) o solo es empleado
  `puede_invitar` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si puede invitar personas; el propietario delega este permiso',  -- 1 si puede invitar personas; el propietario delega este permiso
  `cargo` VARCHAR(150) NULL COMMENT 'Cargo mostrado en la empresa; informativo',  -- Cargo mostrado en la empresa; informativo
  `origen` ENUM('creacion','solicitud','invitacion') NOT NULL COMMENT 'Como ingreso el miembro; trazabilidad',  -- Como ingreso el miembro; trazabilidad
  `aprobado_por_usuario_id` BIGINT UNSIGNED NULL COMMENT 'Usuario que aprobo el ingreso; NULL si fue el creador',  -- Usuario que aprobo el ingreso; NULL si fue el creador
  `fecha_ingreso` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de ingreso a la empresa',  -- Fecha de ingreso a la empresa
  `fecha_salida` DATETIME NULL COMMENT 'Fecha de salida; conserva historial',  -- Fecha de salida; conserva historial
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_empresa_miembro_usuario_id` (`usuario_id`),  -- Indice de usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_empresa_miembro_aprobado_por_usuario_id` (`aprobado_por_usuario_id`),  -- Indice de aprobado_por_usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_empresa_miembro` (`empresa_id`, `usuario_id`),  -- Un usuario tiene una sola membresia por empresa (se reactiva al volver)
  KEY `idx_empresa_miembro_rol` (`empresa_id`, `rol_empresa`, `activo`),  -- Listar reclutadores o administradores de una empresa
  CONSTRAINT `fk_empresa_miembro_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia empresa; impide referencias huerfanas
  CONSTRAINT `fk_empresa_miembro_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_empresa_miembro_aprobado_por_usuario_id` FOREIGN KEY (`aprobado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Relacion N:M usuario-empresa con rol; un usuario puede trabajar en varias empresas';

-- -----------------------------------------------------
-- Tabla `empresa_solicitud_union`: Solicitud de un usuario para ser empleado de una empresa; la aprueba un administrador o propietario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `empresa_solicitud_union` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa a la que se solicita unirse',  -- Empresa a la que se solicita unirse
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que solicita',  -- Usuario que solicita
  `mensaje` VARCHAR(500) NULL COMMENT 'Mensaje del solicitante; contexto para quien decide',  -- Mensaje del solicitante; contexto para quien decide
  `estado` ENUM('pendiente','aprobada','rechazada','cancelada') NOT NULL DEFAULT 'pendiente' COMMENT 'Estado del flujo de aprobacion',  -- Estado del flujo de aprobacion
  `resuelta_por_usuario_id` BIGINT UNSIGNED NULL COMMENT 'Quien aprobo o rechazo',  -- Quien aprobo o rechazo
  `resuelta_at` DATETIME NULL COMMENT 'Momento de la decision',  -- Momento de la decision
  `pendiente_key` TINYINT GENERATED ALWAYS AS (IF(`estado` = 'pendiente', 1, NULL)) VIRTUAL COMMENT 'Calculada: impide solicitudes pendientes duplicadas',  -- Calculada: impide solicitudes pendientes duplicadas
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_empresa_solicitud_union_usuario_id` (`usuario_id`),  -- Indice de usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_empresa_solicitud_union_resuelta_por_usuario_id` (`resuelta_por_usuario_id`),  -- Indice de resuelta_por_usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_solicitud_union_pendiente` (`empresa_id`, `usuario_id`, `pendiente_key`),  -- Una sola solicitud pendiente por usuario y empresa
  KEY `idx_solicitud_union_estado` (`empresa_id`, `estado`),  -- Bandeja de solicitudes por empresa
  CONSTRAINT `fk_empresa_solicitud_union_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia empresa; impide referencias huerfanas
  CONSTRAINT `fk_empresa_solicitud_union_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_empresa_solicitud_union_resuelta_por_usuario_id` FOREIGN KEY (`resuelta_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Solicitud de un usuario para ser empleado de una empresa; la aprueba un administrador o propietario';

-- -----------------------------------------------------
-- Tabla `empresa_invitacion`: Invitacion por correo con token para unirse a una empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `empresa_invitacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa que invita',  -- Empresa que invita
  `invitado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Miembro con permiso que envio la invitacion',  -- Miembro con permiso que envio la invitacion
  `correo_invitado` VARCHAR(255) NOT NULL COMMENT 'Correo al que se envia; el invitado puede no estar registrado',  -- Correo al que se envia; el invitado puede no estar registrado
  `usuario_invitado_id` BIGINT UNSIGNED NULL COMMENT 'Usuario resuelto al aceptar; NULL hasta entonces',  -- Usuario resuelto al aceptar; NULL hasta entonces
  `rol_empresa` ENUM('administrador','reclutador','empleado') NOT NULL DEFAULT 'empleado' COMMENT 'Rol que tendra al aceptar; propietario no se asigna por invitacion',  -- Rol que tendra al aceptar; propietario no se asigna por invitacion
  `token_hash` CHAR(64) NOT NULL COMMENT 'Hash SHA-256 del token enviado por correo',  -- Hash SHA-256 del token enviado por correo
  `estado` ENUM('pendiente','aceptada','rechazada','cancelada','expirada') NOT NULL DEFAULT 'pendiente' COMMENT 'Estado de la invitacion',  -- Estado de la invitacion
  `expira_at` DATETIME NOT NULL COMMENT 'Fecha limite para aceptar',  -- Fecha limite para aceptar
  `respondida_at` DATETIME NULL COMMENT 'Momento de respuesta',  -- Momento de respuesta
  `pendiente_key` TINYINT GENERATED ALWAYS AS (IF(`estado` = 'pendiente', 1, NULL)) VIRTUAL COMMENT 'Calculada: impide invitaciones pendientes duplicadas',  -- Calculada: impide invitaciones pendientes duplicadas
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_empresa_invitacion_invitado_por_usuario_id` (`invitado_por_usuario_id`),  -- Indice de invitado_por_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_empresa_invitacion_usuario_invitado_id` (`usuario_invitado_id`),  -- Indice de usuario_invitado_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_invitacion_token` (`token_hash`),  -- Busqueda y unicidad del token
  UNIQUE KEY `uq_invitacion_pendiente` (`empresa_id`, `correo_invitado`, `pendiente_key`),  -- Una invitacion pendiente por correo y empresa
  KEY `idx_invitacion_correo` (`correo_invitado`),  -- Mostrar invitaciones al registrarse con ese correo
  CONSTRAINT `fk_empresa_invitacion_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia empresa; impide referencias huerfanas
  CONSTRAINT `fk_empresa_invitacion_invitado_por_usuario_id` FOREIGN KEY (`invitado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_empresa_invitacion_usuario_invitado_id` FOREIGN KEY (`usuario_invitado_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Invitacion por correo con token para unirse a una empresa';

-- -----------------------------------------------------
-- Tabla `habilidad`: Catalogo colaborativo de habilidades
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `habilidad` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre de la habilidad',  -- Nombre de la habilidad
  `tipo` ENUM('tecnica','blanda','herramienta','otra') NOT NULL DEFAULT 'otra' COMMENT 'Clasificacion para agrupar',  -- Clasificacion para agrupar
  `creado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que creo el elemento; los catalogos son colaborativos',  -- Usuario que creo el elemento; los catalogos son colaborativos
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_habilidad_nombre` (`nombre`),  -- Evita duplicados (ignora mayusculas y acentos)
  KEY `idx_habilidad_creado_por_usuario_id` (`creado_por_usuario_id`),  -- Indice de creado_por_usuario_id; acelera joins y filtros por esta relacion
  CONSTRAINT `fk_habilidad_creado_por_usuario_id` FOREIGN KEY (`creado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Catalogo colaborativo de habilidades';

-- -----------------------------------------------------
-- Tabla `idioma`: Catalogo colaborativo de idiomas
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `idioma` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `nombre` VARCHAR(80) NOT NULL COMMENT 'Nombre del idioma',  -- Nombre del idioma
  `codigo_iso` VARCHAR(10) NULL COMMENT 'Codigo ISO 639 opcional',  -- Codigo ISO 639 opcional
  `creado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que creo el elemento; los catalogos son colaborativos',  -- Usuario que creo el elemento; los catalogos son colaborativos
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  UNIQUE KEY `uq_idioma_nombre` (`nombre`),  -- Evita duplicados
  KEY `idx_idioma_creado_por_usuario_id` (`creado_por_usuario_id`),  -- Indice de creado_por_usuario_id; acelera joins y filtros por esta relacion
  CONSTRAINT `fk_idioma_creado_por_usuario_id` FOREIGN KEY (`creado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Catalogo colaborativo de idiomas';

-- -----------------------------------------------------
-- Tabla `institucion`: Catalogo colaborativo de instituciones educativas o emisoras
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `institucion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `nombre` VARCHAR(200) NOT NULL COMMENT 'Nombre de la institucion',  -- Nombre de la institucion
  `ubicacion` VARCHAR(200) NULL COMMENT 'Ciudad o pais; distingue instituciones homonimas',  -- Ciudad o pais; distingue instituciones homonimas
  `sitio_web` VARCHAR(255) NULL COMMENT 'Sitio oficial',  -- Sitio oficial
  `creado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que creo el elemento; los catalogos son colaborativos',  -- Usuario que creo el elemento; los catalogos son colaborativos
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_institucion_nombre` (`nombre`),  -- Busqueda y autocompletado (no unico: hay homonimas)
  KEY `idx_institucion_creado_por_usuario_id` (`creado_por_usuario_id`),  -- Indice de creado_por_usuario_id; acelera joins y filtros por esta relacion
  CONSTRAINT `fk_institucion_creado_por_usuario_id` FOREIGN KEY (`creado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Catalogo colaborativo de instituciones educativas o emisoras';

-- -----------------------------------------------------
-- Tabla `credencial`: Catalogo colaborativo de certificaciones y licencias
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `credencial` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `nombre` VARCHAR(200) NOT NULL COMMENT 'Nombre de la credencial',  -- Nombre de la credencial
  `institucion_emisora_id` BIGINT UNSIGNED NULL COMMENT 'Institucion que la emite',  -- Institucion que la emite
  `creado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que creo el elemento; los catalogos son colaborativos',  -- Usuario que creo el elemento; los catalogos son colaborativos
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_credencial_institucion_emisora_id` (`institucion_emisora_id`),  -- Indice de institucion_emisora_id; acelera joins y filtros por esta relacion
  KEY `idx_credencial_nombre` (`nombre`),  -- Busqueda y autocompletado
  KEY `idx_credencial_creado_por_usuario_id` (`creado_por_usuario_id`),  -- Indice de creado_por_usuario_id; acelera joins y filtros por esta relacion
  CONSTRAINT `fk_credencial_institucion_emisora_id` FOREIGN KEY (`institucion_emisora_id`) REFERENCES `institucion` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia institucion; impide referencias huerfanas
  CONSTRAINT `fk_credencial_creado_por_usuario_id` FOREIGN KEY (`creado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Catalogo colaborativo de certificaciones y licencias';

-- -----------------------------------------------------
-- Tabla `cv`: Curriculum de un usuario; un usuario puede tener varios
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Dueno del CV',  -- Dueno del CV
  `titulo` VARCHAR(150) NOT NULL COMMENT 'Nombre interno del CV (por ejemplo CV tecnico); distinguir versiones',  -- Nombre interno del CV (por ejemplo CV tecnico); distinguir versiones
  `resumen` TEXT NULL COMMENT 'Resumen profesional del CV',  -- Resumen profesional del CV
  `archivo_id` BIGINT UNSIGNED NULL COMMENT 'Archivo PDF asociado, si lo hay',  -- Archivo PDF asociado, si lo hay
  `es_principal` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si es el CV predeterminado al aplicar',  -- 1 si es el CV predeterminado al aplicar
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_usuario_id` (`usuario_id`),  -- Indice de usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_cv_archivo_id` (`archivo_id`),  -- Indice de archivo_id; acelera joins y filtros por esta relacion
  KEY `idx_cv_usuario_activo` (`usuario_id`, `activo`),  -- Listar CV activos del usuario
  CONSTRAINT `fk_cv_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_cv_archivo_id` FOREIGN KEY (`archivo_id`) REFERENCES `archivo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia archivo; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Curriculum de un usuario; un usuario puede tener varios';

-- -----------------------------------------------------
-- Tabla `cv_educacion`: Estudios de un CV
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_educacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `institucion_id` BIGINT UNSIGNED NOT NULL COMMENT 'Institucion donde estudio',  -- Institucion donde estudio
  `titulo` VARCHAR(200) NOT NULL COMMENT 'Titulo o grado obtenido',  -- Titulo o grado obtenido
  `campo_estudio` VARCHAR(150) NULL COMMENT 'Area de estudio',  -- Area de estudio
  `fecha_inicio` DATE NOT NULL COMMENT 'Inicio de estudios; antes era VARCHAR',  -- Inicio de estudios; antes era VARCHAR
  `fecha_fin` DATE NULL COMMENT 'Fin de estudios; NULL si sigue en curso',  -- Fin de estudios; NULL si sigue en curso
  `en_curso` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si aun estudia',  -- 1 si aun estudia
  `descripcion` TEXT NULL COMMENT 'Detalles, logros o materias',  -- Detalles, logros o materias
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_educacion_institucion_id` (`institucion_id`),  -- Indice de institucion_id; acelera joins y filtros por esta relacion
  KEY `idx_cv_educacion_cv` (`cv_id`),  -- Cargar estudios de un CV
  CONSTRAINT `chk_cv_educacion_fechas` CHECK (`fecha_fin` IS NULL OR `fecha_fin` >= `fecha_inicio`),  -- Fin no puede ser anterior al inicio
  CONSTRAINT `chk_cv_educacion_curso` CHECK ((`en_curso` = 1 AND `fecha_fin` IS NULL) OR `en_curso` = 0),  -- Si esta en curso no hay fecha fin
  CONSTRAINT `fk_cv_educacion_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia cv; impide referencias huerfanas
  CONSTRAINT `fk_cv_educacion_institucion_id` FOREIGN KEY (`institucion_id`) REFERENCES `institucion` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia institucion; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Estudios de un CV';

-- -----------------------------------------------------
-- Tabla `cv_experiencia`: Experiencia laboral de un CV; permite varios periodos en la misma empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_experiencia` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa donde trabajo; si no existe se crea en el catalogo',  -- Empresa donde trabajo; si no existe se crea en el catalogo
  `rol` VARCHAR(150) NOT NULL COMMENT 'Cargo desempenado',  -- Cargo desempenado
  `tipo_empleo` ENUM('tiempo_completo','medio_tiempo','contrato','freelance','pasantia','temporal','voluntariado') NOT NULL COMMENT 'Tipo de contratacion',  -- Tipo de contratacion
  `modalidad` ENUM('presencial','remoto','hibrido') NOT NULL COMMENT 'Modalidad de trabajo',  -- Modalidad de trabajo
  `ubicacion` VARCHAR(200) NULL COMMENT 'Lugar de trabajo en texto',  -- Lugar de trabajo en texto
  `fecha_inicio` DATE NOT NULL COMMENT 'Inicio del periodo',  -- Inicio del periodo
  `fecha_fin` DATE NULL COMMENT 'Fin del periodo; NULL si es el trabajo actual',  -- Fin del periodo; NULL si es el trabajo actual
  `es_actual` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si trabaja actualmente alli',  -- 1 si trabaja actualmente alli
  `descripcion` TEXT NULL COMMENT 'Responsabilidades y logros',  -- Responsabilidades y logros
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_experiencia_empresa_id` (`empresa_id`),  -- Indice de empresa_id; acelera joins y filtros por esta relacion
  KEY `idx_cv_experiencia_cv` (`cv_id`, `fecha_inicio`),  -- Cargar experiencia ordenada
  CONSTRAINT `chk_cv_experiencia_fechas` CHECK (`fecha_fin` IS NULL OR `fecha_fin` >= `fecha_inicio`),  -- Fin no puede ser anterior al inicio
  CONSTRAINT `chk_cv_experiencia_actual` CHECK ((`es_actual` = 1 AND `fecha_fin` IS NULL) OR `es_actual` = 0),  -- Si es actual no hay fecha fin
  CONSTRAINT `fk_cv_experiencia_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia cv; impide referencias huerfanas
  CONSTRAINT `fk_cv_experiencia_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia empresa; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Experiencia laboral de un CV; permite varios periodos en la misma empresa';

-- -----------------------------------------------------
-- Tabla `cv_credencial`: Credenciales o certificaciones de un CV (N:M cv-credencial)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_credencial` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `credencial_id` BIGINT UNSIGNED NOT NULL COMMENT 'Credencial obtenida',  -- Credencial obtenida
  `codigo_credencial` VARCHAR(100) NULL COMMENT 'Numero o ID de la credencial emitido por la entidad (antes idCredencial)',  -- Numero o ID de la credencial emitido por la entidad (antes idCredencial)
  `url_verificacion` VARCHAR(500) NULL COMMENT 'Enlace de verificacion; 45 caracteres era insuficiente',  -- Enlace de verificacion; 45 caracteres era insuficiente
  `fecha_emision` DATE NOT NULL COMMENT 'Fecha de obtencion',  -- Fecha de obtencion
  `fecha_expiracion` DATE NULL COMMENT 'Fecha de vencimiento; NULL si no expira (corrige typo expericacion)',  -- Fecha de vencimiento; NULL si no expira (corrige typo expericacion)
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_credencial_credencial_id` (`credencial_id`),  -- Indice de credencial_id; acelera joins y filtros por esta relacion
  KEY `idx_cv_credencial_cv` (`cv_id`),  -- Cargar credenciales de un CV
  CONSTRAINT `chk_cv_credencial_fechas` CHECK (`fecha_expiracion` IS NULL OR `fecha_expiracion` >= `fecha_emision`),  -- Vencimiento posterior a emision
  CONSTRAINT `fk_cv_credencial_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia cv; impide referencias huerfanas
  CONSTRAINT `fk_cv_credencial_credencial_id` FOREIGN KEY (`credencial_id`) REFERENCES `credencial` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia credencial; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Credenciales o certificaciones de un CV (N:M cv-credencial)';

-- -----------------------------------------------------
-- Tabla `cv_habilidad`: Habilidades de un CV con nivel (N:M)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_habilidad` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `habilidad_id` BIGINT UNSIGNED NOT NULL COMMENT 'Habilidad declarada',  -- Habilidad declarada
  `nivel` ENUM('basico','intermedio','avanzado','experto') NOT NULL DEFAULT 'intermedio' COMMENT 'Nivel de dominio; ENUM reemplaza VARCHAR eficiencia',  -- Nivel de dominio; ENUM reemplaza VARCHAR eficiencia
  `anios_experiencia` TINYINT UNSIGNED NULL COMMENT 'Anos de experiencia con la habilidad',  -- Anos de experiencia con la habilidad
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_habilidad_habilidad_id` (`habilidad_id`),  -- Indice de habilidad_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_cv_habilidad` (`cv_id`, `habilidad_id`),  -- No repetir habilidad en un CV
  CONSTRAINT `fk_cv_habilidad_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia cv; impide referencias huerfanas
  CONSTRAINT `fk_cv_habilidad_habilidad_id` FOREIGN KEY (`habilidad_id`) REFERENCES `habilidad` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia habilidad; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Habilidades de un CV con nivel (N:M)';

-- -----------------------------------------------------
-- Tabla `cv_idioma`: Idiomas de un CV con nivel de fluidez (N:M)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_idioma` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `idioma_id` BIGINT UNSIGNED NOT NULL COMMENT 'Idioma hablado',  -- Idioma hablado
  `nivel` ENUM('basico','conversacional','profesional','nativo') NOT NULL DEFAULT 'conversacional' COMMENT 'Nivel de fluidez',  -- Nivel de fluidez
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_idioma_idioma_id` (`idioma_id`),  -- Indice de idioma_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_cv_idioma` (`cv_id`, `idioma_id`),  -- No repetir idioma en un CV
  CONSTRAINT `fk_cv_idioma_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia cv; impide referencias huerfanas
  CONSTRAINT `fk_cv_idioma_idioma_id` FOREIGN KEY (`idioma_id`) REFERENCES `idioma` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia idioma; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Idiomas de un CV con nivel de fluidez (N:M)';

-- -----------------------------------------------------
-- Tabla `cv_proyecto`: Proyectos destacados de un CV
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_proyecto` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `nombre` VARCHAR(200) NOT NULL COMMENT 'Nombre del proyecto',  -- Nombre del proyecto
  `descripcion` TEXT NULL COMMENT 'Descripcion y resultados',  -- Descripcion y resultados
  `url` VARCHAR(500) NULL COMMENT 'Enlace al proyecto o repositorio',  -- Enlace al proyecto o repositorio
  `fecha_inicio` DATE NULL COMMENT 'Inicio del proyecto',  -- Inicio del proyecto
  `fecha_fin` DATE NULL COMMENT 'Fin del proyecto',  -- Fin del proyecto
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_proyecto_cv` (`cv_id`),  -- Cargar proyectos de un CV
  CONSTRAINT `chk_cv_proyecto_fechas` CHECK (`fecha_fin` IS NULL OR `fecha_inicio` IS NULL OR `fecha_fin` >= `fecha_inicio`),  -- Coherencia de fechas
  CONSTRAINT `fk_cv_proyecto_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia cv; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Proyectos destacados de un CV';

-- -----------------------------------------------------
-- Tabla `cv_referencia`: Referencias personales o laborales de un CV
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cv_referencia` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'CV al que pertenece el registro',  -- CV al que pertenece el registro
  `nombre` VARCHAR(150) NOT NULL COMMENT 'Nombre de la persona de referencia',  -- Nombre de la persona de referencia
  `cargo` VARCHAR(150) NULL COMMENT 'Cargo de la referencia (antes titulo)',  -- Cargo de la referencia (antes titulo)
  `relacion` VARCHAR(100) NULL COMMENT 'Relacion con el candidato, por ejemplo jefe directo (antes rol)',  -- Relacion con el candidato, por ejemplo jefe directo (antes rol)
  `telefono` VARCHAR(25) NULL COMMENT 'Telefono de contacto',  -- Telefono de contacto
  `correo` VARCHAR(255) NULL COMMENT 'Correo de contacto',  -- Correo de contacto
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_cv_referencia_cv` (`cv_id`),  -- Cargar referencias de un CV
  CONSTRAINT `chk_cv_referencia_contacto` CHECK (`telefono` IS NOT NULL OR `correo` IS NOT NULL),  -- Al menos un medio de contacto
  CONSTRAINT `fk_cv_referencia_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia cv; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Referencias personales o laborales de un CV';

-- -----------------------------------------------------
-- Tabla `publicacion_laboral`: Oferta de trabajo publicada por una empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `publicacion_laboral` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `empresa_id` BIGINT UNSIGNED NOT NULL COMMENT 'Empresa que ofrece el puesto',  -- Empresa que ofrece el puesto
  `publicado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Reclutador que la publico; responsable de la oferta',  -- Reclutador que la publico; responsable de la oferta
  `titulo` VARCHAR(200) NOT NULL COMMENT 'Nombre del puesto (antes rol)',  -- Nombre del puesto (antes rol)
  `descripcion` TEXT NOT NULL COMMENT 'Descripcion del puesto; 2000 caracteres se quedaba corto',  -- Descripcion del puesto; 2000 caracteres se quedaba corto
  `requisitos` TEXT NOT NULL COMMENT 'Requisitos en texto libre (alimenta la comparacion con IA)',  -- Requisitos en texto libre (alimenta la comparacion con IA)
  `tipo_empleo` ENUM('tiempo_completo','medio_tiempo','contrato','freelance','pasantia','temporal','voluntariado') NOT NULL COMMENT 'Tipo de contratacion',  -- Tipo de contratacion
  `modalidad` ENUM('presencial','remoto','hibrido') NOT NULL COMMENT 'Presencial, remoto o hibrido',  -- Presencial, remoto o hibrido
  `ubicacion` VARCHAR(200) NULL COMMENT 'Ciudad o pais del puesto; NULL si es totalmente remoto',  -- Ciudad o pais del puesto; NULL si es totalmente remoto
  `salario_min` DECIMAL(12,2) NULL COMMENT 'Minimo del rango salarial; DECIMAL evita errores de redondeo',  -- Minimo del rango salarial; DECIMAL evita errores de redondeo
  `salario_max` DECIMAL(12,2) NULL COMMENT 'Maximo del rango salarial',  -- Maximo del rango salarial
  `moneda_id` BIGINT UNSIGNED NULL COMMENT 'Moneda del salario; obligatoria si hay salario',  -- Moneda del salario; obligatoria si hay salario
  `periodo_salario` ENUM('hora','dia','semana','mes','anio') NULL COMMENT 'Periodo al que aplica el salario',  -- Periodo al que aplica el salario
  `salario_visible` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 muestra el salario; 0 lo oculta a candidatos',  -- 1 muestra el salario; 0 lo oculta a candidatos
  `num_vacantes` SMALLINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Cantidad de vacantes disponibles',  -- Cantidad de vacantes disponibles
  `fecha_cierre` DATETIME NULL COMMENT 'Fecha limite para aplicar; NULL si es abierta',  -- Fecha limite para aplicar; NULL si es abierta
  `estado` ENUM('borrador','abierta','pausada','cerrada') NOT NULL DEFAULT 'abierta' COMMENT 'Ciclo de vida de la oferta',  -- Ciclo de vida de la oferta
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_publicacion_laboral_publicado_por_usuario_id` (`publicado_por_usuario_id`),  -- Indice de publicado_por_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_publicacion_laboral_moneda_id` (`moneda_id`),  -- Indice de moneda_id; acelera joins y filtros por esta relacion
  KEY `idx_oferta_empresa_estado` (`empresa_id`, `estado`, `created_at`),  -- Ofertas de una empresa por estado
  KEY `idx_oferta_listado` (`estado`, `activo`, `fecha_cierre`),  -- Listado publico de ofertas abiertas
  FULLTEXT KEY `ft_oferta_busqueda` (`titulo`, `descripcion`),  -- Busqueda de texto en ofertas
  CONSTRAINT `chk_oferta_salario` CHECK (`salario_max` IS NULL OR `salario_min` IS NULL OR `salario_max` >= `salario_min`),  -- Maximo no menor que minimo
  CONSTRAINT `chk_oferta_moneda` CHECK ((`salario_min` IS NULL AND `salario_max` IS NULL) OR (`moneda_id` IS NOT NULL AND `periodo_salario` IS NOT NULL)),  -- Salario exige moneda y periodo
  CONSTRAINT `chk_oferta_vacantes` CHECK (`num_vacantes` >= 1),  -- Al menos una vacante
  CONSTRAINT `fk_publicacion_laboral_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia empresa; impide referencias huerfanas
  CONSTRAINT `fk_publicacion_laboral_publicado_por_usuario_id` FOREIGN KEY (`publicado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_publicacion_laboral_moneda_id` FOREIGN KEY (`moneda_id`) REFERENCES `moneda` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia moneda; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Oferta de trabajo publicada por una empresa';

-- -----------------------------------------------------
-- Tabla `aplicacion_trabajo`: Aplicacion de un usuario a una oferta con un CV
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `aplicacion_trabajo` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `publicacion_laboral_id` BIGINT UNSIGNED NOT NULL COMMENT 'Oferta a la que aplica',  -- Oferta a la que aplica
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Candidato; puede ser tambien reclutador de otra empresa',  -- Candidato; puede ser tambien reclutador de otra empresa
  `cv_id` BIGINT UNSIGNED NOT NULL COMMENT 'Unico CV enviado en esta aplicacion',  -- Unico CV enviado en esta aplicacion
  `carta_presentacion` TEXT NULL COMMENT 'Carta del candidato; opcional',  -- Carta del candidato; opcional
  `estado` ENUM('enviada','en_revision','preseleccionada','entrevista','oferta','aprobada','rechazada','retirada') NOT NULL DEFAULT 'enviada' COMMENT 'Estado actual del flujo; ENUM fijo',  -- Estado actual del flujo; ENUM fijo
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_aplicacion_trabajo_usuario_id` (`usuario_id`),  -- Indice de usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_aplicacion_trabajo_cv_id` (`cv_id`),  -- Indice de cv_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_aplicacion_oferta_usuario` (`publicacion_laboral_id`, `usuario_id`),  -- Un usuario aplica una sola vez por oferta
  KEY `idx_aplicacion_oferta_estado` (`publicacion_laboral_id`, `estado`),  -- Bandeja del reclutador por estado
  CONSTRAINT `fk_aplicacion_trabajo_publicacion_laboral_id` FOREIGN KEY (`publicacion_laboral_id`) REFERENCES `publicacion_laboral` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia publicacion_laboral; impide referencias huerfanas
  CONSTRAINT `fk_aplicacion_trabajo_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_aplicacion_trabajo_cv_id` FOREIGN KEY (`cv_id`) REFERENCES `cv` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia cv; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Aplicacion de un usuario a una oferta con un CV';

-- -----------------------------------------------------
-- Tabla `aplicacion_estado_historial`: Bitacora de cambios de estado de cada aplicacion
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `aplicacion_estado_historial` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `aplicacion_trabajo_id` BIGINT UNSIGNED NOT NULL COMMENT 'Aplicacion que cambio',  -- Aplicacion que cambio
  `estado_anterior` ENUM('enviada','en_revision','preseleccionada','entrevista','oferta','aprobada','rechazada','retirada') NULL COMMENT 'Estado previo; NULL en el primer registro',  -- Estado previo; NULL en el primer registro
  `estado_nuevo` ENUM('enviada','en_revision','preseleccionada','entrevista','oferta','aprobada','rechazada','retirada') NOT NULL COMMENT 'Nuevo estado',  -- Nuevo estado
  `cambiado_por_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Quien realizo el cambio (candidato o reclutador)',  -- Quien realizo el cambio (candidato o reclutador)
  `comentario` VARCHAR(500) NULL COMMENT 'Motivo o nota del cambio',  -- Motivo o nota del cambio
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Momento del cambio',  -- Momento del cambio
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_aplicacion_estado_historial_aplicacion_trabajo_id` (`aplicacion_trabajo_id`),  -- Indice de aplicacion_trabajo_id; acelera joins y filtros por esta relacion
  KEY `idx_aplicacion_estado_historial_cambiado_por_usuario_id` (`cambiado_por_usuario_id`),  -- Indice de cambiado_por_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_aplicacion_historial_fecha` (`aplicacion_trabajo_id`, `created_at`),  -- Linea de tiempo de una aplicacion
  CONSTRAINT `fk_aplicacion_estado_historial_aplicacion_trabajo_id` FOREIGN KEY (`aplicacion_trabajo_id`) REFERENCES `aplicacion_trabajo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia aplicacion_trabajo; impide referencias huerfanas
  CONSTRAINT `fk_aplicacion_estado_historial_cambiado_por_usuario_id` FOREIGN KEY (`cambiado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Bitacora de cambios de estado de cada aplicacion';

-- -----------------------------------------------------
-- Tabla `aplicacion_revision`: Evaluacion interna de un reclutador sobre una aplicacion (no visible al candidato)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `aplicacion_revision` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `aplicacion_trabajo_id` BIGINT UNSIGNED NOT NULL COMMENT 'Aplicacion evaluada',  -- Aplicacion evaluada
  `revisor_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Reclutador que evalua; la app impide que sea el candidato',  -- Reclutador que evalua; la app impide que sea el candidato
  `calificacion` TINYINT UNSIGNED NULL COMMENT 'Puntaje de 1 a 5',  -- Puntaje de 1 a 5
  `notas` TEXT NULL COMMENT 'Notas internas',  -- Notas internas
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_aplicacion_revision_revisor_usuario_id` (`revisor_usuario_id`),  -- Indice de revisor_usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_revision_aplicacion_revisor` (`aplicacion_trabajo_id`, `revisor_usuario_id`),  -- Una revision por revisor y aplicacion
  CONSTRAINT `chk_revision_calificacion` CHECK (`calificacion` IS NULL OR `calificacion` BETWEEN 1 AND 5),  -- Rango valido
  CONSTRAINT `fk_aplicacion_revision_aplicacion_trabajo_id` FOREIGN KEY (`aplicacion_trabajo_id`) REFERENCES `aplicacion_trabajo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia aplicacion_trabajo; impide referencias huerfanas
  CONSTRAINT `fk_aplicacion_revision_revisor_usuario_id` FOREIGN KEY (`revisor_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Evaluacion interna de un reclutador sobre una aplicacion (no visible al candidato)';

-- -----------------------------------------------------
-- Tabla `publicacion`: Publicacion del muro, de un usuario o en nombre de una empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `publicacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `autor_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que escribe la publicacion',  -- Usuario que escribe la publicacion
  `empresa_id` BIGINT UNSIGNED NULL COMMENT 'Empresa en cuyo nombre se publica; NULL si es personal',  -- Empresa en cuyo nombre se publica; NULL si es personal
  `titulo` VARCHAR(200) NULL COMMENT 'Titulo opcional',  -- Titulo opcional
  `contenido` TEXT NOT NULL COMMENT 'Cuerpo de la publicacion; antes 45 caracteres',  -- Cuerpo de la publicacion; antes 45 caracteres
  `visibilidad` ENUM('publica','conexiones','privada') NOT NULL DEFAULT 'publica' COMMENT 'Quien puede verla',  -- Quien puede verla
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_publicacion_autor_usuario_id` (`autor_usuario_id`),  -- Indice de autor_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_publicacion_empresa_id` (`empresa_id`),  -- Indice de empresa_id; acelera joins y filtros por esta relacion
  KEY `idx_publicacion_autor_fecha` (`autor_usuario_id`, `created_at`),  -- Publicaciones de un usuario
  KEY `idx_publicacion_empresa_fecha` (`empresa_id`, `created_at`),  -- Publicaciones de una empresa
  KEY `idx_publicacion_feed` (`visibilidad`, `activo`, `created_at`),  -- Armado del feed
  CONSTRAINT `fk_publicacion_autor_usuario_id` FOREIGN KEY (`autor_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_publicacion_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia empresa; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Publicacion del muro, de un usuario o en nombre de una empresa';

-- -----------------------------------------------------
-- Tabla `publicacion_archivo`: Archivos adjuntos de una publicacion (N:M)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `publicacion_archivo` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `publicacion_id` BIGINT UNSIGNED NOT NULL COMMENT 'Publicacion',  -- Publicacion
  `archivo_id` BIGINT UNSIGNED NOT NULL COMMENT 'Archivo adjunto',  -- Archivo adjunto
  `orden` TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Posicion de visualizacion',  -- Posicion de visualizacion
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de adjunto',  -- Fecha de adjunto
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_publicacion_archivo_archivo_id` (`archivo_id`),  -- Indice de archivo_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_publicacion_archivo` (`publicacion_id`, `archivo_id`),  -- No repetir adjunto
  CONSTRAINT `fk_publicacion_archivo_publicacion_id` FOREIGN KEY (`publicacion_id`) REFERENCES `publicacion` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia publicacion; impide referencias huerfanas
  CONSTRAINT `fk_publicacion_archivo_archivo_id` FOREIGN KEY (`archivo_id`) REFERENCES `archivo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia archivo; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Archivos adjuntos de una publicacion (N:M)';

-- -----------------------------------------------------
-- Tabla `comentario`: Comentarios en publicaciones con anidacion de hasta 3 niveles
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `comentario` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `publicacion_id` BIGINT UNSIGNED NOT NULL COMMENT 'Publicacion comentada',  -- Publicacion comentada
  `parent_comentario_id` BIGINT UNSIGNED NULL COMMENT 'Comentario padre; NULL en el nivel 1',  -- Comentario padre; NULL en el nivel 1
  `nivel` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Profundidad 1 a 3; la app comprueba que sea padre+1',  -- Profundidad 1 a 3; la app comprueba que sea padre+1
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Autor del comentario',  -- Autor del comentario
  `contenido` TEXT NOT NULL COMMENT 'Texto del comentario',  -- Texto del comentario
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_comentario_parent_comentario_id` (`parent_comentario_id`),  -- Indice de parent_comentario_id; acelera joins y filtros por esta relacion
  KEY `idx_comentario_usuario_id` (`usuario_id`),  -- Indice de usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_comentario_publicacion` (`publicacion_id`, `parent_comentario_id`, `created_at`),  -- Cargar hilo de una publicacion
  CONSTRAINT `chk_comentario_nivel` CHECK (`nivel` BETWEEN 1 AND 3),  -- Maximo tercer nivel
  CONSTRAINT `chk_comentario_padre` CHECK ((`nivel` = 1 AND `parent_comentario_id` IS NULL) OR (`nivel` > 1 AND `parent_comentario_id` IS NOT NULL)),  -- Nivel 1 sin padre; otros con padre
  CONSTRAINT `fk_comentario_publicacion_id` FOREIGN KEY (`publicacion_id`) REFERENCES `publicacion` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia publicacion; impide referencias huerfanas
  CONSTRAINT `fk_comentario_parent_comentario_id` FOREIGN KEY (`parent_comentario_id`) REFERENCES `comentario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia comentario; impide referencias huerfanas
  CONSTRAINT `fk_comentario_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Comentarios en publicaciones con anidacion de hasta 3 niveles';

-- -----------------------------------------------------
-- Tabla `me_gusta`: Likes de usuarios a publicaciones o comentarios
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `me_gusta` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que da el like',  -- Usuario que da el like
  `publicacion_id` BIGINT UNSIGNED NULL COMMENT 'Publicacion con like; NULL si es a comentario',  -- Publicacion con like; NULL si es a comentario
  `comentario_id` BIGINT UNSIGNED NULL COMMENT 'Comentario con like; NULL si es a publicacion',  -- Comentario con like; NULL si es a publicacion
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Momento del like',  -- Momento del like
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_me_gusta_publicacion_id` (`publicacion_id`),  -- Indice de publicacion_id; acelera joins y filtros por esta relacion
  KEY `idx_me_gusta_comentario_id` (`comentario_id`),  -- Indice de comentario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_me_gusta_publicacion` (`usuario_id`, `publicacion_id`),  -- Un like por usuario y publicacion
  UNIQUE KEY `uq_me_gusta_comentario` (`usuario_id`, `comentario_id`),  -- Un like por usuario y comentario
  CONSTRAINT `chk_me_gusta_objetivo` CHECK ((`publicacion_id` IS NOT NULL) + (`comentario_id` IS NOT NULL) = 1),  -- Exactamente un objetivo
  CONSTRAINT `fk_me_gusta_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_me_gusta_publicacion_id` FOREIGN KEY (`publicacion_id`) REFERENCES `publicacion` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia publicacion; impide referencias huerfanas
  CONSTRAINT `fk_me_gusta_comentario_id` FOREIGN KEY (`comentario_id`) REFERENCES `comentario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia comentario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Likes de usuarios a publicaciones o comentarios';

-- -----------------------------------------------------
-- Tabla `conexion`: Relacion de conexion entre dos usuarios (solicitud y aceptacion)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `conexion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `solicitante_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Quien envia la solicitud',  -- Quien envia la solicitud
  `receptor_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Quien la recibe',  -- Quien la recibe
  `usuario_menor_id` BIGINT UNSIGNED GENERATED ALWAYS AS (LEAST(`solicitante_usuario_id`, `receptor_usuario_id`)) STORED COMMENT 'Calculada: id menor del par; evita duplicados A-B y B-A',  -- Calculada: id menor del par; evita duplicados A-B y B-A
  `usuario_mayor_id` BIGINT UNSIGNED GENERATED ALWAYS AS (GREATEST(`solicitante_usuario_id`, `receptor_usuario_id`)) STORED COMMENT 'Calculada: id mayor del par',  -- Calculada: id mayor del par
  `estado` ENUM('pendiente','aceptada','rechazada','bloqueada') NOT NULL DEFAULT 'pendiente' COMMENT 'Estado de la conexion',  -- Estado de la conexion
  `respondida_at` DATETIME NULL COMMENT 'Momento de respuesta',  -- Momento de respuesta
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_conexion_solicitante_usuario_id` (`solicitante_usuario_id`),  -- Indice de solicitante_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_conexion_receptor_usuario_id` (`receptor_usuario_id`),  -- Indice de receptor_usuario_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_conexion_par` (`usuario_menor_id`, `usuario_mayor_id`),  -- Una sola relacion por par de usuarios
  KEY `idx_conexion_mayor` (`usuario_mayor_id`, `estado`),  -- Conexiones desde el otro extremo del par
  CONSTRAINT `chk_conexion_distintos` CHECK (`solicitante_usuario_id` <> `receptor_usuario_id`),  -- Nadie se conecta consigo mismo
  CONSTRAINT `fk_conexion_solicitante_usuario_id` FOREIGN KEY (`solicitante_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_conexion_receptor_usuario_id` FOREIGN KEY (`receptor_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Relacion de conexion entre dos usuarios (solicitud y aceptacion)';

-- -----------------------------------------------------
-- Tabla `conversacion`: Chat 1:1 entre usuarios o entre un usuario y una empresa
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `conversacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `tipo` ENUM('usuario_usuario','usuario_empresa') NOT NULL COMMENT 'Tipo de chat',  -- Tipo de chat
  `usuario_iniciador_id` BIGINT UNSIGNED NOT NULL COMMENT 'Usuario que abrio la conversacion',  -- Usuario que abrio la conversacion
  `usuario_destino_id` BIGINT UNSIGNED NULL COMMENT 'Otro usuario en chats 1:1; NULL si es con empresa',  -- Otro usuario en chats 1:1; NULL si es con empresa
  `empresa_id` BIGINT UNSIGNED NULL COMMENT 'Empresa destino; NULL en chats entre usuarios',  -- Empresa destino; NULL en chats entre usuarios
  `usuario_menor_id` BIGINT UNSIGNED GENERATED ALWAYS AS (LEAST(`usuario_iniciador_id`, `usuario_destino_id`)) STORED COMMENT 'Calculada: menor del par; un solo chat por pareja',  -- Calculada: menor del par; un solo chat por pareja
  `usuario_mayor_id` BIGINT UNSIGNED GENERATED ALWAYS AS (GREATEST(`usuario_iniciador_id`, `usuario_destino_id`)) STORED COMMENT 'Calculada: mayor del par',  -- Calculada: mayor del par
  `ultimo_mensaje_at` DATETIME NULL COMMENT 'Fecha del ultimo mensaje; ordenar bandeja',  -- Fecha del ultimo mensaje; ordenar bandeja
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_conversacion_usuario_destino_id` (`usuario_destino_id`),  -- Indice de usuario_destino_id; acelera joins y filtros por esta relacion
  KEY `idx_conversacion_empresa_id` (`empresa_id`),  -- Indice de empresa_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_conversacion_par` (`usuario_menor_id`, `usuario_mayor_id`),  -- Un chat 1:1 por par
  UNIQUE KEY `uq_conversacion_empresa` (`usuario_iniciador_id`, `empresa_id`),  -- Un chat por usuario y empresa
  KEY `idx_conversacion_destino` (`usuario_destino_id`, `ultimo_mensaje_at`),  -- Bandeja del destinatario
  KEY `idx_conversacion_empresa` (`empresa_id`, `ultimo_mensaje_at`),  -- Bandeja de reclutadores de la empresa
  CONSTRAINT `chk_conversacion_tipo` CHECK ((`tipo` = 'usuario_usuario' AND `usuario_destino_id` IS NOT NULL AND `empresa_id` IS NULL AND `usuario_iniciador_id` <> `usuario_destino_id`) OR (`tipo` = 'usuario_empresa' AND `empresa_id` IS NOT NULL AND `usuario_destino_id` IS NULL)),  -- Coherencia entre tipo y participantes
  CONSTRAINT `fk_conversacion_usuario_iniciador_id` FOREIGN KEY (`usuario_iniciador_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_conversacion_usuario_destino_id` FOREIGN KEY (`usuario_destino_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_conversacion_empresa_id` FOREIGN KEY (`empresa_id`) REFERENCES `empresa` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia empresa; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Chat 1:1 entre usuarios o entre un usuario y una empresa';

-- -----------------------------------------------------
-- Tabla `mensaje`: Mensajes almacenados; no editables, con borrado logico para ambas partes
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mensaje` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `conversacion_id` BIGINT UNSIGNED NOT NULL COMMENT 'Conversacion',  -- Conversacion
  `remitente_usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Quien escribio; en chats con empresa registra que reclutador respondio',  -- Quien escribio; en chats con empresa registra que reclutador respondio
  `contenido` TEXT NULL COMMENT 'Texto; NULL si solo lleva adjunto',  -- Texto; NULL si solo lleva adjunto
  `leido_at` DATETIME NULL COMMENT 'Momento de lectura por la contraparte',  -- Momento de lectura por la contraparte
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 0 oculta el mensaje para ambos',  -- Borrado logico: 0 oculta el mensaje para ambos
  `eliminado_por_usuario_id` BIGINT UNSIGNED NULL COMMENT 'Quien lo borro',  -- Quien lo borro
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado',  -- Momento del borrado
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Momento de envio',  -- Momento de envio
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_mensaje_remitente_usuario_id` (`remitente_usuario_id`),  -- Indice de remitente_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_mensaje_eliminado_por_usuario_id` (`eliminado_por_usuario_id`),  -- Indice de eliminado_por_usuario_id; acelera joins y filtros por esta relacion
  KEY `idx_mensaje_conversacion` (`conversacion_id`, `id`),  -- Paginacion del historial
  CONSTRAINT `fk_mensaje_conversacion_id` FOREIGN KEY (`conversacion_id`) REFERENCES `conversacion` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia conversacion; impide referencias huerfanas
  CONSTRAINT `fk_mensaje_remitente_usuario_id` FOREIGN KEY (`remitente_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia usuario; impide referencias huerfanas
  CONSTRAINT `fk_mensaje_eliminado_por_usuario_id` FOREIGN KEY (`eliminado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Mensajes almacenados; no editables, con borrado logico para ambas partes';

-- -----------------------------------------------------
-- Tabla `mensaje_archivo`: Adjuntos de un mensaje (N:M)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mensaje_archivo` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `mensaje_id` BIGINT UNSIGNED NOT NULL COMMENT 'Mensaje',  -- Mensaje
  `archivo_id` BIGINT UNSIGNED NOT NULL COMMENT 'Archivo adjunto',  -- Archivo adjunto
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de adjunto',  -- Fecha de adjunto
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_mensaje_archivo_archivo_id` (`archivo_id`),  -- Indice de archivo_id; acelera joins y filtros por esta relacion
  UNIQUE KEY `uq_mensaje_archivo` (`mensaje_id`, `archivo_id`),  -- No repetir adjunto
  CONSTRAINT `fk_mensaje_archivo_mensaje_id` FOREIGN KEY (`mensaje_id`) REFERENCES `mensaje` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,  -- Integridad referencial hacia mensaje; impide referencias huerfanas
  CONSTRAINT `fk_mensaje_archivo_archivo_id` FOREIGN KEY (`archivo_id`) REFERENCES `archivo` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia archivo; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Adjuntos de un mensaje (N:M)';

-- -----------------------------------------------------
-- Tabla `notificacion`: Notificaciones dirigidas a un usuario
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `notificacion` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NOT NULL COMMENT 'Destinatario',  -- Destinatario
  `categoria` ENUM('mensaje_nuevo','solicitud_conexion','conexion_aceptada','cambio_estado_aplicacion','nueva_aplicacion','invitacion_empresa','solicitud_union_empresa','solicitud_union_resuelta','comentario_publicacion','respuesta_comentario','me_gusta','empresa_verificada','oferta_cerrando','sistema') NOT NULL DEFAULT 'sistema' COMMENT 'Tipo de evento; agrupa e inserta iconos',  -- Tipo de evento; agrupa e inserta iconos
  `prioridad` ENUM('baja','normal','alta','urgente') NOT NULL DEFAULT 'normal' COMMENT 'Urgencia visual (el antiguo tipo)',  -- Urgencia visual (el antiguo tipo)
  `titulo` VARCHAR(150) NOT NULL COMMENT 'Titulo corto',  -- Titulo corto
  `descripcion` VARCHAR(500) NOT NULL COMMENT 'Detalle del mensaje',  -- Detalle del mensaje
  `url` VARCHAR(500) NULL COMMENT 'Enlace al recurso relacionado',  -- Enlace al recurso relacionado
  `leido` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 si fue leida',  -- 1 si fue leida
  `leido_at` DATETIME NULL COMMENT 'Momento de lectura',  -- Momento de lectura
  `activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar',  -- Borrado logico: 1 visible, 0 eliminado; evita perder historial y permite restaurar
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creacion; auditoria y ordenamiento cronologico',  -- Fecha y hora de creacion; auditoria y ordenamiento cronologico
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha y hora de la ultima modificacion; sincronizacion y auditoria',  -- Fecha y hora de la ultima modificacion; sincronizacion y auditoria
  `deleted_at` DATETIME NULL COMMENT 'Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino',  -- Momento del borrado logico (NULL si sigue activo); permite saber cuando se elimino
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_notificacion_bandeja` (`usuario_id`, `leido`, `created_at`),  -- Bandeja de no leidas
  CONSTRAINT `fk_notificacion_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Notificaciones dirigidas a un usuario';

-- -----------------------------------------------------
-- Tabla `configuracion_sistema`: Configuracion global singleton (una sola fila con id=1)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `configuracion_sistema` (
  `id` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Siempre 1; garantiza fila unica',  -- Siempre 1; garantiza fila unica
  `nombre_sitio` VARCHAR(100) NOT NULL DEFAULT 'LinkedInChino' COMMENT 'Nombre mostrado',  -- Nombre mostrado
  `url_sitio` VARCHAR(255) NULL COMMENT 'URL base para enlaces',  -- URL base para enlaces
  `correo_soporte` VARCHAR(255) NULL COMMENT 'Contacto de ayuda',  -- Contacto de ayuda
  `modo_mantenimiento` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 bloquea acceso',  -- 1 bloquea acceso
  `registro_abierto` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 permite registrarse',  -- 1 permite registrarse
  `verificacion_correo_obligatoria` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 exige verificar correo para login',  -- 1 exige verificar correo para login
  `token_verificacion_horas` SMALLINT UNSIGNED NOT NULL DEFAULT 48 COMMENT 'Vigencia del token de verificacion',  -- Vigencia del token de verificacion
  `token_recuperacion_minutos` SMALLINT UNSIGNED NOT NULL DEFAULT 60 COMMENT 'Vigencia del token de recuperacion',  -- Vigencia del token de recuperacion
  `login_google_habilitado` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 activa login con Google',  -- 1 activa login con Google
  `google_client_id` VARCHAR(255) NULL COMMENT 'Client ID OAuth',  -- Client ID OAuth
  `google_client_secret_cifrado` VARBINARY(512) NULL COMMENT 'Secreto OAuth cifrado',  -- Secreto OAuth cifrado
  `ruta_base_archivos` VARCHAR(500) NOT NULL DEFAULT '/var/lib/linkedinchino/uploads' COMMENT 'Directorio raiz en disco',  -- Directorio raiz en disco
  `tamano_max_archivo_mb` SMALLINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Maximo por archivo en MB',  -- Maximo por archivo en MB
  `extensiones_permitidas` VARCHAR(500) NOT NULL DEFAULT 'pdf,doc,docx,png,jpg,jpeg,webp' COMMENT 'Extensiones validas separadas por coma',  -- Extensiones validas separadas por coma
  `max_cv_por_usuario` TINYINT UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Limite de CV',  -- Limite de CV
  `ia_habilitada` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 activa funciones de IA',  -- 1 activa funciones de IA
  `ia_base_url` VARCHAR(255) NOT NULL DEFAULT 'https://api.deepseek.com' COMMENT 'Endpoint de DeepSeek',  -- Endpoint de DeepSeek
  `ia_modelo` VARCHAR(100) NOT NULL DEFAULT 'deepseek-chat' COMMENT 'Modelo a usar',  -- Modelo a usar
  `ia_api_key_cifrada` VARBINARY(1024) NULL COMMENT 'API key de DeepSeek cifrada',  -- API key de DeepSeek cifrada
  `ia_temperatura` DECIMAL(3,2) NOT NULL DEFAULT 0.30 COMMENT 'Creatividad del modelo',  -- Creatividad del modelo
  `ia_max_tokens` INT UNSIGNED NOT NULL DEFAULT 1024 COMMENT 'Tope de tokens por respuesta',  -- Tope de tokens por respuesta
  `ia_timeout_segundos` SMALLINT UNSIGNED NOT NULL DEFAULT 30 COMMENT 'Timeout de la llamada',  -- Timeout de la llamada
  `ia_prompt_perfil_oferta` TEXT NULL COMMENT 'Prompt: perfil del usuario vs oferta',  -- Prompt: perfil del usuario vs oferta
  `ia_prompt_aplicacion_oferta` TEXT NULL COMMENT 'Prompt: aplicacion vs oferta (reclutador)',  -- Prompt: aplicacion vs oferta (reclutador)
  `actualizado_por_usuario_id` BIGINT UNSIGNED NULL COMMENT 'Administrador que hizo el ultimo cambio',  -- Administrador que hizo el ultimo cambio
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creacion de la fila',  -- Creacion de la fila
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Ultima modificacion',  -- Ultima modificacion
  PRIMARY KEY (`id`),  -- Clave primaria singleton
  KEY `idx_configuracion_sistema_actualizado_por_usuario_id` (`actualizado_por_usuario_id`),  -- Indice de actualizado_por_usuario_id; acelera joins y filtros por esta relacion
  CONSTRAINT `chk_configuracion_singleton` CHECK (`id` = 1),  -- Impide mas de una fila
  CONSTRAINT `chk_configuracion_ia_temp` CHECK (`ia_temperatura` BETWEEN 0 AND 2),  -- Rango valido
  CONSTRAINT `fk_configuracion_sistema_actualizado_por_usuario_id` FOREIGN KEY (`actualizado_por_usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Configuracion global singleton (una sola fila con id=1)';

-- -----------------------------------------------------
-- Tabla `auditoria_log`: Bitacora: quien hizo que, sobre que tabla y registro, y cuando
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `auditoria_log` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador unico autoincremental; permite referenciar el registro desde otras tablas',  -- Identificador unico autoincremental; permite referenciar el registro desde otras tablas
  `usuario_id` BIGINT UNSIGNED NULL COMMENT 'Actor; NULL para acciones del sistema',  -- Actor; NULL para acciones del sistema
  `accion` ENUM('crear','actualizar','eliminar_logico','restaurar','eliminar_fisico','login','logout','otra') NOT NULL COMMENT 'Que se hizo',  -- Que se hizo
  `tabla_afectada` VARCHAR(64) NOT NULL COMMENT 'Tabla afectada',  -- Tabla afectada
  `registro_id` BIGINT UNSIGNED NULL COMMENT 'Id del registro afectado',  -- Id del registro afectado
  `valores_anteriores` JSON NULL COMMENT 'Estado previo',  -- Estado previo
  `valores_nuevos` JSON NULL COMMENT 'Estado posterior',  -- Estado posterior
  `ip` VARCHAR(45) NULL COMMENT 'IP del actor',  -- IP del actor
  `user_agent` VARCHAR(255) NULL COMMENT 'Navegador o cliente',  -- Navegador o cliente
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) COMMENT 'Cuando ocurrio, con milisegundos',  -- Cuando ocurrio, con milisegundos
  PRIMARY KEY (`id`),  -- Clave primaria; garantiza unicidad y acceso rapido por id
  KEY `idx_auditoria_usuario_fecha` (`usuario_id`, `created_at`),  -- Acciones por usuario
  KEY `idx_auditoria_objeto` (`tabla_afectada`, `registro_id`),  -- Historial de un registro
  KEY `idx_auditoria_fecha` (`created_at`),  -- Consultas por fecha
  CONSTRAINT `fk_auditoria_log_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT  -- Integridad referencial hacia usuario; impide referencias huerfanas
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Bitacora: quien hizo que, sobre que tabla y registro, y cuando';

-- -----------------------------------------------------
-- Datos semilla: fila singleton de configuracion y monedas comunes
-- -----------------------------------------------------
INSERT INTO `configuracion_sistema` (`id`) VALUES (1) ON DUPLICATE KEY UPDATE `id` = `id`;  -- crea la unica fila de configuracion con valores por defecto
INSERT INTO `moneda` (`codigo`, `nombre`, `simbolo`) VALUES
 ('USD','Dolar estadounidense','$'),('EUR','Euro','EUR'),('MXN','Peso mexicano','$'),('COP','Peso colombiano','$'),
 ('ARS','Peso argentino','$'),('CLP','Peso chileno','$'),('PEN','Sol peruano','S/'),('BRL','Real brasileno','R$'),
 ('GBP','Libra esterlina','GBP'),('CAD','Dolar canadiense','$'),('CNY','Yuan chino','CNY')
ON DUPLICATE KEY UPDATE `nombre` = VALUES(`nombre`);  -- catalogo inicial de monedas para salarios

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
