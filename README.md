# PostgreSQL + pgAdmin — Docker Template

Plantilla reutilizable para levantar un entorno de **PostgreSQL 16 + pgAdmin 4** con Docker Compose.  
Ideal para prácticas de Bases de Datos: solo agrega tu script SQL y el entorno queda listo en minutos.

---

## Stack

| Servicio | Imagen | Puerto local |
|---|---|---|
| PostgreSQL 16 | `postgres:16-alpine` | `5433` |
| pgAdmin 4 | `dpage/pgadmin4:latest` | `8081` |

---

## Estructura del proyecto

```
proyecto/
├── docker-compose.yml          # Definición de servicios (editar credenciales aquí)
├── init-scripts/
│   └── tu_script.sql           # Tu script SQL se coloca aquí
└── README.md
```

---

## Instrucciones de uso

### 1. Prerrequisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) instalado y corriendo.

### 2. Configura tus credenciales

Edita `docker-compose.yml` y reemplaza los placeholders:

```yaml
POSTGRES_DB: your_db_name        # Nombre de tu base de datos
POSTGRES_USER: your_user         # Usuario de PostgreSQL
POSTGRES_PASSWORD: your_password # Contraseña de PostgreSQL

PGADMIN_DEFAULT_EMAIL: admin@example.com      # Email para entrar a pgAdmin
PGADMIN_DEFAULT_PASSWORD: your_pgadmin_password
```

### 3. Agrega tu script SQL

Coloca tu archivo `.sql` dentro de `init-scripts/`.  
PostgreSQL lo ejecutará automáticamente en el primer arranque.

> **Importante:** El script **NO debe incluir** `CREATE DATABASE ...` — Docker ya crea la base de datos con el valor de `POSTGRES_DB`. Solo incluye `CREATE TABLE`, `INSERT`, `CREATE TYPE`, etc.

Puedes tomar como referencia el archivo de ejemplo:  
`init-scripts/esports-tournament.sql`

### 4. Levantar los servicios

```bash
docker compose up -d
```

### 5. Acceder a pgAdmin

Abre tu navegador en: **[http://localhost:8081](http://localhost:8081)**

| Campo | Valor |
|---|---|
| Email | el que definiste en `PGADMIN_DEFAULT_EMAIL` |
| Contraseña | el que definiste en `PGADMIN_DEFAULT_PASSWORD` |

Una vez dentro, registra un nuevo servidor con:

| Campo | Valor |
|---|---|
| Host | `postgres_db` |
| Port | `5432` |
| Database | el que definiste en `POSTGRES_DB` |
| Username | el que definiste en `POSTGRES_USER` |
| Password | el que definiste en `POSTGRES_PASSWORD` |

### 6. Conectarse directamente (psql / DBeaver)

| Parámetro | Valor |
|---|---|
| Host | `localhost` |
| Puerto | `5433` |
| Base de datos | el que definiste en `POSTGRES_DB` |
| Usuario | el que definiste en `POSTGRES_USER` |
| Contraseña | el que definiste en `POSTGRES_PASSWORD` |

### 7. Detener y eliminar los contenedores

```bash
# Solo detener (conserva los datos)
docker compose down

# Detener y borrar todo (útil para reiniciar desde cero)
docker compose down -v
```

---

## Red interna

Ambos servicios comparten la red `db_network` (bridge), lo que permite que pgAdmin se conecte al contenedor de PostgreSQL por nombre de host (`postgres_db`) sin exponer puertos entre ellos.

---

## Notas

- El volumen `pgdata` persiste los datos de PostgreSQL entre reinicios.
- El script SQL **solo se ejecuta una vez**, en el primer arranque. Si necesitas reiniciarlo, ejecuta `docker compose down -v` antes de `docker compose up -d`.
- Si tienes **varios archivos SQL**, PostgreSQL los ejecuta en **orden alfabético**. Nombra tus archivos como `01_schema.sql`, `02_data.sql`, etc.

---

## Solución de problemas

| Problema | Causa probable | Solución |
|---|---|---|
| pgAdmin no carga en `localhost:8081` | El contenedor de Postgres aún está iniciando | Espera 10-15 segundos y recarga la página |
| Las tablas no aparecen en pgAdmin | El volumen ya existía de una ejecución anterior sin el script | Ejecuta `docker compose down -v` y luego `docker compose up -d` |
| Error al registrar el servidor en pgAdmin | Se usó `localhost` como host | El host debe ser **`postgres_db`** (nombre del contenedor), no `localhost` |
| Puerto `5433` ocupado al levantar los servicios | Hay una instancia local de PostgreSQL usando ese puerto | Cambia `"5433:5432"` a `"5434:5432"` en el `docker-compose.yml` |
