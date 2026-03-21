# DB Learning Lab

> Entorno de aprendizaje multi-motor para laboratorios de informática  
> Multi-engine learning environment for computer science labs

---

## Quick Start

```bash
cp .env.example .env          # 1. Configurar credenciales
chmod +x scripts/*.sh         # 2. Dar permisos (Linux/macOS)
./scripts/start.sh            # 3. Arrancar
./scripts/status.sh           # 4. Ver URLs y cadenas de conexión
```

Acceso web: **`http://<IP_SERVIDOR>:8978`** (CloudBeaver) · **`http://<IP_SERVIDOR>:8080`** (Adminer)

---

## Índice / Table of Contents

- [Español](#español)
  - [Descripción](#descripción)
  - [Requisitos previos](#requisitos-previos)
  - [Instalación](#instalación)
  - [Bases de datos incluidas](#bases-de-datos-incluidas)
  - [Acceso desde las PCs del laboratorio](#acceso-desde-las-pcs-del-laboratorio)
  - [Cadenas de conexión](#cadenas-de-conexión)
  - [Scripts de gestión](#scripts-de-gestión)
  - [Base de datos de ejemplo](#base-de-datos-de-ejemplo-sistema-escolar)
  - [Ejercicios estructurados](#ejercicios-estructurados)
  - [Comparación de sintaxis cross-engine](#comparación-de-sintaxis-cross-engine)
  - [Notas de seguridad](#notas-de-seguridad)
  - [Solución de problemas](#solución-de-problemas)
- [English](#english)
  - [Description](#description)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Included Databases](#included-databases)
  - [Access from Lab PCs](#access-from-lab-pcs)
  - [Connection Strings](#connection-strings)
  - [Management Scripts](#management-scripts)
  - [Sample Database](#sample-database-school-system)
  - [Structured Exercises](#structured-exercises)
  - [Cross-engine Syntax Reference](#cross-engine-syntax-reference)
  - [Security Notes](#security-notes)
  - [Troubleshooting](#troubleshooting)

---

# Español

## Descripción

**DB Learning Lab** es un entorno Docker listo para usar en un servidor de laboratorio de informática (LAN local o VPS). Con un solo comando arranca tres motores de bases de datos relacionales y dos interfaces web de administración, permitiendo a los estudiantes comparar la sintaxis SQL entre distintos sistemas de gestión sin necesidad de instalar nada en sus propias máquinas.

**Incluye:**
- **MariaDB** — compatible con MySQL, el motor más usado en desarrollo web
- **PostgreSQL** — motor empresarial con soporte avanzado de tipos y consultas
- **Firebird** — motor compacto, ampliamente usado en aplicaciones de escritorio
- **CloudBeaver** — interfaz web completa tipo DBeaver (recomendada para alumnos)
- **Adminer** — interfaz web ligera para administración rápida

## Requisitos previos

El **servidor** (PC del docente, servidor del lab o VPS) necesita:

| Requisito         | Versión mínima | Verificar con            |
|-------------------|---------------|--------------------------|
| Docker Engine     | 24.x          | `docker --version`       |
| Docker Compose V2 | 2.x           | `docker compose version` |
| RAM disponible    | 2 GB          | —                        |
| Puertos libres    | 3306, 3050, 5432, 8080, 8978 | —       |

Las **PCs de los estudiantes** solo necesitan un navegador web.

### Instalar Docker en el servidor (Ubuntu/Debian)

```bash
# 1. Instalar Docker Engine
curl -fsSL https://get.docker.com | sh

# 2. Instalar el plugin Docker Compose V2 (paso necesario)
sudo apt-get install -y docker-compose-v2

# 3. Añadir el usuario al grupo docker (para no necesitar sudo)
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar para aplicar el grupo
```

> **Nota:** Los scripts **no requieren `sudo`** si el usuario está en el grupo `docker`.

## Instalación

### 1. Clonar o descargar el proyecto

```bash
git clone https://github.com/lcuper18/db-learning-lab.git db-learning-lab
cd db-learning-lab
```

### 2. Configurar las variables de entorno

```bash
cp .env.example .env
```

Editar `.env` con las credenciales deseadas:

```
DB_USER=labuser
DB_PASSWORD=labpass123   # Cambiar por una contraseña más segura
DB_NAME=labdb
CB_ADMIN_NAME=admin
CB_ADMIN_PASSWORD=changeme
```

> **Nota:** Docker Compose carga `.env` automáticamente. Nunca subas `.env` al repositorio.

### 3. Arrancar el entorno

**Linux / macOS:**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Windows (CMD):**
```bat
scripts\start.bat
```

El script arranca todos los contenedores, espera a que los tres motores estén listos y carga automáticamente el schema de Firebird.

### 4. Verificar el estado

```bash
./scripts/status.sh
```

Este comando muestra el estado de los contenedores, la IP del servidor y todas las URLs y cadenas de conexión listas para compartir con los alumnos.

## Bases de datos incluidas

| Motor       | Puerto | Imagen Docker                     | Versión |
|-------------|--------|-----------------------------------|---------|
| MariaDB     | 3306   | `mariadb:lts`                     | 11.x LTS |
| PostgreSQL  | 5432   | `postgres:17`                     | 17.x    |
| Firebird    | 3050   | `jacobalberty/firebird:v4.0`      | 4.0     |
| CloudBeaver | 8978   | `dbeaver/cloudbeaver:latest`      | última estable |
| Adminer     | 8080   | `adminer:4`                       | 4.x     |

## Acceso desde las PCs del laboratorio

### CloudBeaver (interfaz recomendada para alumnos)

CloudBeaver es la versión web de DBeaver. Tiene editor SQL completo, autocompletado, visor de datos y esquema visual.

```
http://<IP_DEL_SERVIDOR>:8978
```

Las tres conexiones (MariaDB, PostgreSQL, Firebird) están preconfiguradas. Los alumnos solo necesitan hacer login con las credenciales de `CB_ADMIN_NAME` / `CB_ADMIN_PASSWORD` del archivo `.env`.

### Adminer (interfaz ligera)

```
http://<IP_DEL_SERVIDOR>:8080
```

#### URLs pre-rellenas para Adminer (comparte con los alumnos)

Sustituyendo `<IP>` por la IP real del servidor:

| Motor      | URL directa |
|------------|-------------|
| MariaDB    | `http://<IP>:8080/?server=mariadb&username=labuser&db=labdb` |
| PostgreSQL | `http://<IP>:8080/?pgsql=postgresql&username=labuser&db=labdb` |
| Firebird   | `http://<IP>:8080/?server=firebird&username=LABUSER&db=%2Ffirebird%2Fdata%2FLABDB` |

> **Importante para Firebird:** el usuario debe estar en **MAYÚSCULAS** (`LABUSER`, no `labuser`). Firebird convierte todos los identificadores a mayúsculas internamente.

Para conocer la IP del servidor:
```bash
./scripts/status.sh
# o manualmente:
ip addr show | grep "inet " | grep -v 127.0.0.1
```

#### Datos de conexión manual para Adminer

| Campo         | MariaDB        | PostgreSQL     | Firebird                          |
|---------------|---------------|----------------|-----------------------------------|
| Sistema       | MySQL          | PostgreSQL     | Firebird                          |
| Servidor      | `mariadb`      | `postgresql`   | `firebird`                        |
| Usuario       | `DB_USER`      | `DB_USER`      | `DB_USER` **en MAYÚSCULAS**       |
| Contraseña    | `DB_PASSWORD`  | `DB_PASSWORD`  | `DB_PASSWORD`                     |
| Base de datos | `DB_NAME`      | `DB_NAME`      | `/firebird/data/<DB_NAME en MAY>` |

## Cadenas de conexión

Para conectar desde clientes SQL externos (DBeaver de escritorio, TablePlus, etc.):

### MariaDB / MySQL

```
Host:     <IP_DEL_SERVIDOR>
Puerto:   3306
Usuario:  labuser
Password: <DB_PASSWORD>
Base de datos: labdb
JDBC URL: jdbc:mysql://<IP_DEL_SERVIDOR>:3306/labdb
```

### PostgreSQL

```
Host:     <IP_DEL_SERVIDOR>
Puerto:   5432
Usuario:  labuser
Password: <DB_PASSWORD>
Base de datos: labdb
JDBC URL: jdbc:postgresql://<IP_DEL_SERVIDOR>:5432/labdb
```

### Firebird

```
Host:     <IP_DEL_SERVIDOR>
Puerto:   3050
Usuario:  LABUSER  ← siempre en mayúsculas
Password: <DB_PASSWORD>
Base de datos: /firebird/data/LABDB
JDBC URL: jdbc:firebirdsql://<IP_DEL_SERVIDOR>:3050//firebird/data/LABDB
```

## Scripts de gestión

Los scripts están pensados para el docente o administrador del laboratorio.

| Script             | Acción                                                                          |
|--------------------|---------------------------------------------------------------------------------|
| `start.sh/.bat`    | Arranca todos los contenedores e inicializa Firebird automáticamente            |
| `stop.sh/.bat`     | Detiene los contenedores, conserva los datos                                    |
| `reset.sh/.bat`    | **Borra todos los datos** y reinicia desde cero (ideal al inicio de cada clase) |
| `status.sh/.bat`   | Muestra estado, IP del servidor, URLs y cadenas de conexión                     |
| `backup.sh/.bat`   | Guarda dumps de los tres motores en `backups/<timestamp>/`                      |
| `save.sh/.bat`     | `git add . && git commit && git push` — publica cambios en GitHub               |

```bash
./scripts/start.sh        # Arrancar
./scripts/stop.sh         # Detener
./scripts/reset.sh        # Reinicio limpio (pide confirmación)
./scripts/status.sh       # Ver estado y URLs
./scripts/backup.sh       # Copia de seguridad
./scripts/save.sh "msg"   # Publicar cambios en git
```

## Base de datos de ejemplo: Sistema Escolar

Los tres motores se inicializan con el mismo esquema:

```
alumnos    → id, nombre, apellido, email, fecha_nac, ciudad
cursos     → id, nombre, descripcion, creditos
matriculas → id, alumno_id, curso_id, fecha_alta
notas      → id, matricula_id, evaluacion, nota
```

Con **8 alumnos**, **6 cursos**, **12 matrículas** y **15 notas** de ejemplo.

Los datos incluyen casos pedagógicos intencionados:

| Caso                                 | Qué enseña                        |
|--------------------------------------|-----------------------------------|
| 2 alumnos sin `email` (NULL)         | `IS NULL`, `IS NOT NULL`, `COALESCE` |
| 1 alumno sin ninguna matrícula       | `LEFT JOIN` que devuelve NULL     |
| 1 curso sin alumnos matriculados     | `LEFT JOIN` inverso               |
| 2 alumnos de la misma ciudad         | `GROUP BY` con resultados múltiples |
| Fechas de alta variadas              | Ejercicios de rangos de fecha     |
| 1 matrícula sin notas                | `OUTER JOIN` sobre notas          |

## Ejercicios estructurados

El directorio `exercises/` contiene ejercicios SQL listos para usar, organizados por nivel:

| Archivo                  | Nivel        | Contenido                                             |
|--------------------------|--------------|-------------------------------------------------------|
| `01-select-basico.sql`   | Principiante | SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, IS NULL     |
| `02-joins.sql`           | Intermedio   | INNER JOIN, LEFT JOIN, patrones NULL                  |
| `03-agregados.sql`       | Intermedio   | COUNT, AVG, GROUP BY, HAVING, SUM                     |
| `04-dml.sql`             | Intermedio   | INSERT, UPDATE, DELETE, errores de FK                 |
| `05-transacciones.sql`   | Avanzado     | BEGIN/COMMIT/ROLLBACK, atomicidad, aislamiento        |
| `06-ddl.sql`             | Intermedio   | CREATE TABLE, ALTER TABLE, índices, vistas            |
| `07-cross-engine.sql`    | Referencia   | Mismas consultas en los 3 dialectos SQL               |

Cada archivo incluye enunciados como comentarios y soluciones comentadas debajo con `-- SOLUCIÓN:`.

## Comparación de sintaxis cross-engine

| Concepto              | MariaDB                     | PostgreSQL                  | Firebird                              |
|-----------------------|-----------------------------|-----------------------------|---------------------------------------|
| Auto-incremento       | `INT AUTO_INCREMENT`        | `SERIAL`                    | `INTEGER GENERATED BY DEFAULT AS IDENTITY` |
| Texto largo           | `TEXT`                      | `TEXT`                      | `BLOB SUB_TYPE TEXT`                  |
| Límite de filas       | `LIMIT n`                   | `LIMIT n`                   | `FIRST n` / `FETCH FIRST n ROWS ONLY`|
| Fecha actual          | `CURDATE()`                 | `CURRENT_DATE`              | `CURRENT_DATE`                        |
| Concatenación         | `CONCAT(a,b)` / `a\|\|b`   | `a\|\|b`                    | `a\|\|b`                              |
| Cast                  | `CAST(x AS CHAR)`           | `CAST(x AS TEXT)` / `x::TEXT` | `CAST(x AS VARCHAR(n))`            |
| Nulo seguro           | `IFNULL(x, y)`              | `COALESCE(x, y)`            | `COALESCE(x, y)` / `NVL(x, y)`       |
| IF NOT EXISTS         | Soportado                   | Soportado                   | **No soportado**                      |
| Multi-row INSERT      | Soportado                   | Soportado                   | **No soportado** (un INSERT por fila) |
| COMMIT explícito      | No necesario (auto-commit)  | No necesario (auto-commit)  | **Necesario** en isql-fb              |
| SELECT sin tabla      | `SELECT 1`                  | `SELECT 1`                  | `SELECT 1 FROM RDB$DATABASE`          |
| BOOLEAN nativo        | `TINYINT(1)`                | `BOOLEAN`                   | No existe (usar `SMALLINT`)           |

## Notas de seguridad

- **Contraseña por defecto:** Cambia `DB_PASSWORD` y `CB_ADMIN_PASSWORD` en `.env` antes de desplegar.
- **Puertos en loopback:** Los puertos de las BD (3306, 5432, 3050) escuchan en `127.0.0.1`. Solo CloudBeaver y Adminer (8978, 8080) deben ser accesibles desde la red del aula.
- **Firewall (VPS):**
  ```bash
  sudo ufw allow from <RED_DEL_AULA>/24 to any port 8978
  sudo ufw allow from <RED_DEL_AULA>/24 to any port 8080
  sudo ufw deny 3306 && sudo ufw deny 5432 && sudo ufw deny 3050
  ```
- **`.env` nunca al repositorio:** El archivo `.gitignore` ya lo excluye.
- **Contraseña de SYSDBA (Firebird):** Igual al valor de `DB_PASSWORD` (`ISC_PASSWORD` en el compose).

## Solución de problemas

### Los contenedores no arrancan / estado `Exited`
```bash
docker compose logs <servicio>   # Ver error concreto
# Ejemplos:
docker compose logs mariadb
docker compose logs firebird
```

### Puerto en uso (`address already in use`)
```bash
ss -tulnp | grep 3306   # Ver qué proceso usa el puerto
```

### Contenedor `Up (unhealthy)` tras varios minutos
El motor tardó más de lo esperado en arrancar. Reinicia solo ese servicio:
```bash
docker compose restart firebird
```

### Firebird: error de autenticación en Adminer
- El usuario debe estar en **MAYÚSCULAS**: `LABUSER`, no `labuser`.
- La base de datos debe incluir la ruta completa: `/firebird/data/LABDB`.

### CloudBeaver pide login pero las credenciales no funcionan
Las credenciales de CloudBeaver son `CB_ADMIN_NAME` y `CB_ADMIN_PASSWORD` del archivo `.env`, **no** las credenciales de las bases de datos. Valores por defecto: `admin` / `changeme`.

### Quiero volver al estado inicial de los datos
```bash
./scripts/reset.sh   # Borra todos los volúmenes y reinicia (pide confirmación)
```

---

# English

## Description

**DB Learning Lab** is a Docker-based environment designed for computer science lab servers (local LAN or VPS). A single command starts three relational database engines and two web admin interfaces, allowing students to compare SQL syntax across different database systems without installing anything on their own machines.

**Includes:**
- **MariaDB** — MySQL-compatible, the most popular engine in web development
- **PostgreSQL** — enterprise-grade engine with advanced type and query support
- **Firebird** — compact engine widely used in desktop applications
- **CloudBeaver** — full-featured web SQL IDE (recommended for students)
- **Adminer** — lightweight web interface for quick admin tasks

## Prerequisites

The **server** (teacher's PC, lab server, or VPS) requires:

| Requirement       | Min. version | Check with               |
|-------------------|-------------|---------------------------|
| Docker Engine     | 24.x        | `docker --version`        |
| Docker Compose V2 | 2.x         | `docker compose version`  |
| Available RAM     | 2 GB        | —                         |
| Open ports        | 3306, 3050, 5432, 8080, 8978 | —        |

**Student PCs** only need a web browser.

### Install Docker on the server (Ubuntu/Debian)

```bash
# 1. Install Docker Engine
curl -fsSL https://get.docker.com | sh

# 2. Install the Docker Compose V2 plugin (required)
sudo apt-get install -y docker-compose-v2

# 3. Add your user to the docker group (to run without sudo)
sudo usermod -aG docker $USER
# Log out and back in to apply the group
```

## Installation

### 1. Clone or download the project

```bash
git clone https://github.com/lcuper18/db-learning-lab.git db-learning-lab
cd db-learning-lab
```

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env`:

```
DB_USER=labuser
DB_PASSWORD=labpass123   # Change to a stronger password
DB_NAME=labdb
CB_ADMIN_NAME=admin
CB_ADMIN_PASSWORD=changeme
```

### 3. Start the environment

**Linux / macOS:**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Windows (CMD):**
```bat
scripts\start.bat
```

The script starts all containers, waits for the three engines to be ready, and automatically loads the Firebird schema.

### 4. Check the status

```bash
./scripts/status.sh
```

Displays container status, server IP, all URLs and connection strings ready to share with students.

## Included Databases

| Engine      | Port | Docker Image                      | Version        |
|-------------|------|-----------------------------------|----------------|
| MariaDB     | 3306 | `mariadb:lts`                     | 11.x LTS       |
| PostgreSQL  | 5432 | `postgres:17`                     | 17.x           |
| Firebird    | 3050 | `jacobalberty/firebird:v4.0`      | 4.0            |
| CloudBeaver | 8978 | `dbeaver/cloudbeaver:latest`      | latest stable  |
| Adminer     | 8080 | `adminer:4`                       | 4.x            |

## Access from Lab PCs

### CloudBeaver (recommended for students)

```
http://<SERVER_IP>:8978
```

All three connections are pre-configured. Students log in with `CB_ADMIN_NAME` / `CB_ADMIN_PASSWORD` from `.env`.

### Adminer (lightweight interface)

```
http://<SERVER_IP>:8080
```

#### Pre-filled Adminer URLs (share with students)

| Engine     | URL |
|------------|-----|
| MariaDB    | `http://<IP>:8080/?server=mariadb&username=labuser&db=labdb` |
| PostgreSQL | `http://<IP>:8080/?pgsql=postgresql&username=labuser&db=labdb` |
| Firebird   | `http://<IP>:8080/?server=firebird&username=LABUSER&db=%2Ffirebird%2Fdata%2FLABDB` |

> **Important for Firebird:** the username must be **UPPERCASE** (`LABUSER`, not `labuser`).

#### Manual Adminer connection details

| Field     | MariaDB        | PostgreSQL     | Firebird                          |
|-----------|---------------|----------------|-----------------------------------|
| System    | MySQL          | PostgreSQL     | Firebird                          |
| Server    | `mariadb`      | `postgresql`   | `firebird`                        |
| Username  | `DB_USER`      | `DB_USER`      | `DB_USER` **UPPERCASE**           |
| Password  | `DB_PASSWORD`  | `DB_PASSWORD`  | `DB_PASSWORD`                     |
| Database  | `DB_NAME`      | `DB_NAME`      | `/firebird/data/<DB_NAME UPPER>`  |

## Connection Strings

### MariaDB / MySQL

```
Host:     <SERVER_IP>
Port:     3306
User:     labuser
Password: <DB_PASSWORD>
Database: labdb
JDBC URL: jdbc:mysql://<SERVER_IP>:3306/labdb
```

### PostgreSQL

```
Host:     <SERVER_IP>
Port:     5432
User:     labuser
Password: <DB_PASSWORD>
Database: labdb
JDBC URL: jdbc:postgresql://<SERVER_IP>:5432/labdb
```

### Firebird

```
Host:     <SERVER_IP>
Port:     3050
User:     LABUSER  ← always uppercase
Password: <DB_PASSWORD>
Database: /firebird/data/LABDB
JDBC URL: jdbc:firebirdsql://<SERVER_IP>:3050//firebird/data/LABDB
```

## Management Scripts

| Script             | Action                                                                    |
|--------------------|---------------------------------------------------------------------------|
| `start.sh/.bat`    | Start all containers, auto-initialize Firebird schema                     |
| `stop.sh/.bat`     | Stop containers, data is preserved                                        |
| `reset.sh/.bat`    | **Delete all data** and restart from scratch (asks for confirmation)      |
| `status.sh/.bat`   | Show status, server IP, all URLs and connection strings                   |
| `backup.sh/.bat`   | Save DB dumps to `backups/<timestamp>/`                                   |
| `save.sh/.bat`     | `git add . && git commit && git push` — publish changes to GitHub         |

## Sample Database: School System

All three engines are initialized with the same schema:

```
alumnos    → id, nombre (name), apellido (surname), email, fecha_nac (birthdate), ciudad (city)
cursos     → id, nombre (name), descripcion (description), creditos (credits)
matriculas → id, alumno_id, curso_id, fecha_alta (enrollment date)
notas      → id, matricula_id, evaluacion (exam name), nota (grade)
```

With **8 students**, **6 courses**, **12 enrollments** and **15 grade records**.

Pedagogically intentional data cases:

| Case                                  | Teaches                                   |
|---------------------------------------|-------------------------------------------|
| 2 students with no email (NULL)       | `IS NULL`, `IS NOT NULL`, `COALESCE`      |
| 1 student with no enrollment          | `LEFT JOIN` returning NULL                |
| 1 course with no enrolled students    | Reverse `LEFT JOIN`                       |
| 2 students from the same city         | `GROUP BY` with multiple results          |
| Varied enrollment dates               | Date range queries                        |
| 1 enrollment with no grades           | `OUTER JOIN` on grades table              |

## Structured Exercises

The `exercises/` directory contains ready-to-use SQL exercises organized by difficulty:

| File                     | Level        | Content                                              |
|--------------------------|--------------|------------------------------------------------------|
| `01-select-basico.sql`   | Beginner     | SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, IS NULL    |
| `02-joins.sql`           | Intermediate | INNER JOIN, LEFT JOIN, NULL patterns                 |
| `03-agregados.sql`       | Intermediate | COUNT, AVG, GROUP BY, HAVING, SUM                    |
| `04-dml.sql`             | Intermediate | INSERT, UPDATE, DELETE, FK constraint errors         |
| `05-transacciones.sql`   | Advanced     | BEGIN/COMMIT/ROLLBACK, atomicity, isolation          |
| `06-ddl.sql`             | Intermediate | CREATE TABLE, ALTER TABLE, indexes, views            |
| `07-cross-engine.sql`    | Reference    | Same queries in all 3 SQL dialects                   |

Each file includes problem statements as comments and solutions commented below with `-- SOLUCIÓN:`.

## Cross-engine Syntax Reference

| Concept               | MariaDB                     | PostgreSQL                  | Firebird                              |
|-----------------------|-----------------------------|-----------------------------|---------------------------------------|
| Auto-increment        | `INT AUTO_INCREMENT`        | `SERIAL`                    | `INTEGER GENERATED BY DEFAULT AS IDENTITY` |
| Long text             | `TEXT`                      | `TEXT`                      | `BLOB SUB_TYPE TEXT`                  |
| Row limit             | `LIMIT n`                   | `LIMIT n`                   | `FIRST n` / `FETCH FIRST n ROWS ONLY`|
| Current date          | `CURDATE()`                 | `CURRENT_DATE`              | `CURRENT_DATE`                        |
| String concat         | `CONCAT(a,b)` / `a\|\|b`   | `a\|\|b`                    | `a\|\|b`                              |
| Cast                  | `CAST(x AS CHAR)`           | `CAST(x AS TEXT)` / `x::TEXT` | `CAST(x AS VARCHAR(n))`            |
| Null coalesce         | `IFNULL(x, y)`              | `COALESCE(x, y)`            | `COALESCE(x, y)` / `NVL(x, y)`       |
| IF NOT EXISTS         | Supported                   | Supported                   | **Not supported**                     |
| Multi-row INSERT      | Supported                   | Supported                   | **Not supported** (one INSERT per row)|
| Explicit COMMIT       | Not needed (auto-commit)    | Not needed (auto-commit)    | **Required** in isql-fb               |
| SELECT without table  | `SELECT 1`                  | `SELECT 1`                  | `SELECT 1 FROM RDB$DATABASE`          |
| Native BOOLEAN        | `TINYINT(1)`                | `BOOLEAN`                   | None (use `SMALLINT`)                 |

## Security Notes

- **Default password:** Change `DB_PASSWORD` and `CB_ADMIN_PASSWORD` in `.env` before deploying.
- **Ports bound to loopback:** DB ports (3306, 5432, 3050) listen on `127.0.0.1`. Only CloudBeaver (8978) and Adminer (8080) need to be reachable from the classroom network.
- **Firewall (VPS):**
  ```bash
  sudo ufw allow from <LAB_NETWORK>/24 to any port 8978
  sudo ufw allow from <LAB_NETWORK>/24 to any port 8080
  sudo ufw deny 3306 && sudo ufw deny 5432 && sudo ufw deny 3050
  ```
- **`.env` never in the repository:** Already excluded by `.gitignore`.

## Troubleshooting

### Containers won't start / `Exited` status
```bash
docker compose logs <service>   # See the specific error
docker compose logs mariadb
docker compose logs firebird
```

### Port already in use
```bash
ss -tulnp | grep 3306
```

### Container shows `Up (unhealthy)` after several minutes
The engine took longer than expected. Restart just that service:
```bash
docker compose restart firebird
```

### Firebird: authentication error in Adminer
- Username must be **UPPERCASE**: `LABUSER`, not `labuser`.
- Database path must be complete: `/firebird/data/LABDB`.

### CloudBeaver login credentials not working
CloudBeaver credentials are `CB_ADMIN_NAME` and `CB_ADMIN_PASSWORD` from `.env`, **not** the database credentials. Defaults: `admin` / `changeme`.

### How to reset to the original sample data
```bash
./scripts/reset.sh   # Deletes all volumes and restarts (asks for confirmation)
```

---

## Project Structure

```
db-learning-lab/
├── docker-compose.yml          # Service definitions (5 services)
├── .env.example                # Environment variable template
├── .gitignore
├── README.md                   # This file
├── init/
│   ├── mariadb/
│   │   └── 01-schema.sql       # Auto-loaded on first start
│   ├── postgresql/
│   │   └── 01-schema.sql       # Auto-loaded on first start
│   ├── firebird/
│   │   └── 01-schema.sql       # Auto-loaded by start.sh
│   └── cloudbeaver/
│       └── data-sources.json   # Pre-configured connections
├── exercises/
│   ├── 01-select-basico.sql    # Beginner
│   ├── 02-joins.sql            # Intermediate
│   ├── 03-agregados.sql        # Intermediate
│   ├── 04-dml.sql              # Intermediate
│   ├── 05-transacciones.sql    # Advanced
│   ├── 06-ddl.sql              # Intermediate
│   └── 07-cross-engine.sql     # Reference
└── scripts/
    ├── start.sh  / start.bat   # Start environment
    ├── stop.sh   / stop.bat    # Stop environment
    ├── reset.sh  / reset.bat   # Full reset (deletes all data)
    ├── status.sh / status.bat  # Show status, IP and connection strings
    ├── backup.sh / backup.bat  # Database dumps to backups/
    └── save.sh   / save.bat    # git commit + push
```

---

*DB Learning Lab — Entorno de aprendizaje multi-motor / Multi-engine learning environment*
