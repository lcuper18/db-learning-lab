# DB Learning Lab

> Entorno de aprendizaje multi-motor para laboratorios de informática  
> Multi-engine learning environment for computer science labs

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
  - [Inicialización de Firebird](#inicialización-de-firebird-manual)
  - [Base de datos de ejemplo](#base-de-datos-de-ejemplo-sistema-escolar)
  - [Notas de seguridad](#notas-de-seguridad)
- [English](#english)
  - [Description](#description)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Included Databases](#included-databases)
  - [Access from Lab PCs](#access-from-lab-pcs)
  - [Connection Strings](#connection-strings)
  - [Management Scripts](#management-scripts)
  - [Firebird Initialization](#firebird-initialization-manual)
  - [Sample Database](#sample-database-school-system)
  - [Security Notes](#security-notes)

---

# Español

## Descripción

**DB Learning Lab** es un entorno Docker listo para usar en un servidor de laboratorio de informática (LAN local o VPS). Con un solo comando arranca tres motores de bases de datos relacionales y una interfaz web de administración, permitiendo a los estudiantes comparar la sintaxis SQL entre distintos sistemas de gestión sin necesidad de instalar nada en sus propias máquinas.

**Incluye:**
- **MariaDB** — compatible con MySQL, el motor más usado en desarrollo web
- **PostgreSQL** — motor empresarial con soporte avanzado de tipos y consultas
- **Firebird** — motor compacto, ampliamente usado en aplicaciones de escritorio
- **Adminer** — interfaz web unificada para administrar los tres motores

## Requisitos previos

El **servidor** (PC del docente, servidor del lab o VPS) necesita:

| Requisito         | Versión mínima | Verificar con        |
|-------------------|---------------|----------------------|
| Docker Engine     | 24.x          | `docker --version`   |
| Docker Compose    | v2            | `docker compose version` |
| Puertos libres    | 3306, 3050, 5432, 8080 | —            |

Las **PCs de los estudiantes** solo necesitan un navegador web para acceder a Adminer, o un cliente SQL como [DBeaver](https://dbeaver.io/) (gratuito).

### Instalar Docker en el servidor (Ubuntu/Debian)

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar para aplicar el grupo
```

## Instalación

### 1. Clonar o descargar el proyecto

```bash
git clone https://github.com/lcuper18/db-learning-lab.git db-learning-lab
cd db-learning-lab
```

O descargar el archivo ZIP desde [github.com/lcuper18/db-learning-lab](https://github.com/lcuper18/db-learning-lab) y descomprimir en el servidor.

### 2. Configurar las variables de entorno

```bash
cp .env.example .env
```

Editar `.env` con las credenciales deseadas:

```
DB_USER=labuser
DB_PASSWORD=labpass123   # Cambiar por una contraseña más segura
DB_NAME=labdb
```

> **Nota:** Docker Compose carga `.env` automáticamente. Nunca subas `.env` al repositorio.

### 3. Arrancar el entorno

**Linux / macOS:**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Windows (CMD como Administrador):**
```bat
scripts\start.bat
```

**O directamente con Docker Compose:**
```bash
docker compose up -d
```

### 4. Verificar que todo está corriendo

```bash
docker compose ps
```

Deberías ver cuatro contenedores con estado `Up`:
```
NAME                  STATUS
adminer_container     Up
mariadb_container     Up
postgresql_container  Up
firebird_container    Up
```

## Bases de datos incluidas

| Motor      | Puerto | Imagen Docker              | Versión |
|------------|--------|----------------------------|---------|
| MariaDB    | 3306   | `mariadb:latest`           | 11.x    |
| PostgreSQL | 5432   | `postgres:latest`          | 17.x    |
| Firebird   | 3050   | `jacobalberty/firebird:latest` | 4.x |
| Adminer    | 8080   | `adminer:latest`           | 4.x     |

## Acceso desde las PCs del laboratorio

### Interfaz web (Adminer)

Desde cualquier PC en la misma red, abrir el navegador y entrar a:

```
http://<IP_DEL_SERVIDOR>:8080
```

Para conocer la IP del servidor:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

#### Datos de conexión para Adminer

| Campo      | MariaDB        | PostgreSQL     | Firebird                    |
|------------|---------------|----------------|-----------------------------|
| Sistema    | MySQL          | PostgreSQL     | Firebird                    |
| Servidor   | `mariadb`      | `postgresql`   | `firebird`                  |
| Usuario    | valor de `DB_USER` | valor de `DB_USER` | valor de `DB_USER` (mayúsculas) |
| Contraseña | valor de `DB_PASSWORD` | valor de `DB_PASSWORD` | valor de `DB_PASSWORD` |
| Base de datos | valor de `DB_NAME` | valor de `DB_NAME` | `/firebird/data/<DB_NAME>` |

> Para Firebird, el campo "Base de datos" en Adminer debe ser la ruta completa dentro del contenedor:  
> `/firebird/data/LABDB`  
> (el nombre de la DB se convierte automáticamente a mayúsculas).

## Cadenas de conexión

Para conectar desde clientes SQL como DBeaver, TablePlus o desde código:

### MariaDB / MySQL

```
Host:     <IP_DEL_SERVIDOR>
Puerto:   3306
Usuario:  labuser
Password: labpass123
Base de datos: labdb
JDBC URL: jdbc:mysql://<IP_DEL_SERVIDOR>:3306/labdb
```

### PostgreSQL

```
Host:     <IP_DEL_SERVIDOR>
Puerto:   5432
Usuario:  labuser
Password: labpass123
Base de datos: labdb
JDBC URL: jdbc:postgresql://<IP_DEL_SERVIDOR>:5432/labdb
```

### Firebird

```
Host:     <IP_DEL_SERVIDOR>
Puerto:   3050
Usuario:  LABUSER
Password: labpass123
Base de datos: /firebird/data/LABDB
JDBC URL: jdbc:firebirdsql://<IP_DEL_SERVIDOR>:3050//firebird/data/LABDB
```

## Scripts de gestión

Los scripts están pensados para ser ejecutados por el docente o el administrador del laboratorio.

| Script         | Acción                                                          |
|----------------|-----------------------------------------------------------------|
| `start.sh/.bat` | Arranca todos los contenedores (`docker compose up -d`)        |
| `stop.sh/.bat`  | Detiene los contenedores, conserva los datos                   |
| `reset.sh/.bat` | **Borra todos los datos** y reinicia el entorno desde cero. Ideal para usar al inicio de cada clase. |

```bash
# Arrancar
./scripts/start.sh

# Detener
./scripts/stop.sh

# Reiniciar limpio (borra datos — escribe 's' para confirmar)
./scripts/reset.sh
```

> **Nota:** Si cambias `DB_NAME` en `.env`, actualiza también la línea `USE labdb;` al inicio de `init/mariadb/01-schema.sql` para que coincida.

## Inicialización de Firebird (manual)

A diferencia de MariaDB y PostgreSQL, el contenedor de Firebird no ejecuta scripts SQL automáticamente al arrancar. Sin embargo, la base de datos **sí se crea sola** gracias a la variable `FIREBIRD_DATABASE` del `docker-compose.yml`. Solo es necesario cargar el esquema de tablas **una vez** después del primer `start.sh`.

**La forma más sencilla — Adminer:**
1. Abrir Adminer en `http://<IP_SERVIDOR>:8080`
2. Conectar: Sistema `Firebird` · Servidor `firebird` · Usuario `SYSDBA` · Contraseña `<DB_PASSWORD>` · Base de datos `/firebird/data/LABDB`
3. Ir a **Importar** y subir `init/firebird/01-schema.sql`

**Por terminal:**
```bash
docker exec -i firebird_container isql-fb \
  -user SYSDBA -password labpass123 \
  /firebird/data/LABDB \
  < init/firebird/01-schema.sql
```

> **Nota:** Sustituye `labpass123` por el valor de `DB_PASSWORD` de tu archivo `.env`.

## Base de datos de ejemplo: Sistema Escolar

Los tres motores se inicializan (MariaDB y PostgreSQL automáticamente; Firebird manualmente) con el mismo esquema de ejemplo:

```
alumnos      → id, nombre, apellido, email, fecha_nac, ciudad
cursos       → id, nombre, descripcion, creditos
matriculas   → id, alumno_id, curso_id, fecha_alta
notas        → id, matricula_id, evaluacion, nota
```

Con **5 alumnos**, **5 cursos**, **10 matrículas** y **13 notas** de ejemplo.

### Ejercicios para principiantes

```sql
-- 1. Ver todos los alumnos
SELECT * FROM alumnos;

-- 2. Buscar alumnos de Madrid
SELECT nombre, apellido FROM alumnos WHERE ciudad = 'Madrid';

-- 3. Cursos con más de 3 créditos
SELECT nombre, creditos FROM cursos WHERE creditos > 3;

-- 4. Qué cursos tiene cada alumno (JOIN)
SELECT a.nombre, a.apellido, c.nombre AS curso
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN cursos c ON c.id = m.curso_id
ORDER BY a.apellido;

-- 5. Nota promedio por alumno
SELECT a.nombre, a.apellido, ROUND(AVG(n.nota), 2) AS promedio
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN notas n ON n.matricula_id = m.id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY promedio DESC;
```

## Notas de seguridad

- **Contraseña por defecto:** Cambia `DB_PASSWORD` en `.env` antes de desplegar en cualquier red que no sea de uso exclusivo en el aula.
- **Firewall:** En un VPS, considera restringir los puertos 3306, 5432 y 3050 en el firewall para que solo sean accesibles desde la IP del servidor, y exponer únicamente el puerto 8080 (Adminer) a los estudiantes.
- **`.env` nunca al repositorio:** El archivo `.gitignore` ya lo excluye.
- **Contraseña de SYSDBA (Firebird):** La contraseña de `SYSDBA` es el valor de `DB_PASSWORD` en el compose (variable `ISC_PASSWORD`). Guárdala en un lugar seguro.

---

# English

## Description

**DB Learning Lab** is a Docker-based environment designed for computer science lab servers (local LAN or VPS). A single command starts three relational database engines and a unified web admin interface, allowing students to compare SQL syntax across different database systems without installing anything on their own machines.

**Includes:**
- **MariaDB** — MySQL-compatible, the most popular engine in web development
- **PostgreSQL** — enterprise-grade engine with advanced type and query support
- **Firebird** — compact engine widely used in desktop applications
- **Adminer** — unified web interface to manage all three engines

## Prerequisites

The **server** (teacher's PC, lab server, or VPS) requires:

| Requirement       | Min. version | Check with           |
|-------------------|-------------|----------------------|
| Docker Engine     | 24.x        | `docker --version`   |
| Docker Compose    | v2          | `docker compose version` |
| Open ports        | 3306, 3050, 5432, 8080 | —          |

**Student PCs** only need a web browser for Adminer, or a SQL client like [DBeaver](https://dbeaver.io/) (free).

### Install Docker on the server (Ubuntu/Debian)

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in to apply the group
```

## Installation

### 1. Clone or download the project

```bash
git clone https://github.com/lcuper18/db-learning-lab.git db-learning-lab
cd db-learning-lab
```

Or download the ZIP file from [github.com/lcuper18/db-learning-lab](https://github.com/lcuper18/db-learning-lab) and extract it on the server.

### 2. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` with the desired credentials:

```
DB_USER=labuser
DB_PASSWORD=labpass123   # Change to a stronger password
DB_NAME=labdb
```

> **Note:** Docker Compose loads `.env` automatically. Never commit `.env` to the repository.

### 3. Start the environment

**Linux / macOS:**
```bash
chmod +x scripts/*.sh
./scripts/start.sh
```

**Windows (CMD as Administrator):**
```bat
scripts\start.bat
```

**Or directly with Docker Compose:**
```bash
docker compose up -d
```

### 4. Verify everything is running

```bash
docker compose ps
```

You should see four containers with `Up` status:
```
NAME                  STATUS
adminer_container     Up
mariadb_container     Up
postgresql_container  Up
firebird_container    Up
```

## Included Databases

| Engine     | Port | Docker Image               | Version |
|------------|------|----------------------------|---------|
| MariaDB    | 3306 | `mariadb:latest`           | 11.x    |
| PostgreSQL | 5432 | `postgres:latest`          | 17.x    |
| Firebird   | 3050 | `jacobalberty/firebird:latest` | 4.x |
| Adminer    | 8080 | `adminer:latest`           | 4.x     |

## Access from Lab PCs

### Web interface (Adminer)

From any PC on the same network, open a browser and navigate to:

```
http://<SERVER_IP>:8080
```

To find the server's IP:
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1
```

#### Adminer connection details

| Field     | MariaDB        | PostgreSQL     | Firebird                    |
|-----------|---------------|----------------|-----------------------------|
| System    | MySQL          | PostgreSQL     | Firebird                    |
| Server    | `mariadb`      | `postgresql`   | `firebird`                  |
| Username  | `DB_USER` value | `DB_USER` value | `DB_USER` value (uppercase) |
| Password  | `DB_PASSWORD` value | `DB_PASSWORD` value | `DB_PASSWORD` value |
| Database  | `DB_NAME` value | `DB_NAME` value | `/firebird/data/<DB_NAME>` |

> For Firebird, the "Database" field in Adminer must be the full path inside the container:  
> `/firebird/data/LABDB`  
> (the DB name is automatically converted to uppercase).

## Connection Strings

For SQL clients like DBeaver, TablePlus, or from application code:

### MariaDB / MySQL

```
Host:     <SERVER_IP>
Port:     3306
User:     labuser
Password: labpass123
Database: labdb
JDBC URL: jdbc:mysql://<SERVER_IP>:3306/labdb
```

### PostgreSQL

```
Host:     <SERVER_IP>
Port:     5432
User:     labuser
Password: labpass123
Database: labdb
JDBC URL: jdbc:postgresql://<SERVER_IP>:5432/labdb
```

### Firebird

```
Host:     <SERVER_IP>
Port:     3050
User:     LABUSER
Password: labpass123
Database: /firebird/data/LABDB
JDBC URL: jdbc:firebirdsql://<SERVER_IP>:3050//firebird/data/LABDB
```

## Management Scripts

These scripts are intended to be run by the teacher or lab administrator.

| Script          | Action                                                             |
|-----------------|--------------------------------------------------------------------|
| `start.sh/.bat` | Start all containers (`docker compose up -d`)                      |
| `stop.sh/.bat`  | Stop containers, data is preserved                                 |
| `reset.sh/.bat` | **Delete all data** and restart from scratch. Best used at the start of each class. |

```bash
# Start
./scripts/start.sh

# Stop
./scripts/stop.sh

# Full reset (deletes data — type 's' to confirm)
./scripts/reset.sh
```

## Firebird Initialization (manual)

Unlike MariaDB and PostgreSQL, the Firebird container does not execute SQL scripts automatically on startup. However, the database **is created automatically** via the `FIREBIRD_DATABASE` variable in `docker-compose.yml`. You only need to load the schema **once** after the first `start.sh`.

**Via Adminer (easiest):**
1. Open Adminer at `http://<SERVER_IP>:8080`
2. Connect: System `Firebird` · Server `firebird` · User `SYSDBA` · Password `<DB_PASSWORD>` · Database `/firebird/data/LABDB`
3. Go to **Import** and upload `init/firebird/01-schema.sql`

**Via terminal:**
```bash
docker exec -i firebird_container isql-fb \
  -user SYSDBA -password labpass123 \
  /firebird/data/LABDB \
  < init/firebird/01-schema.sql
```

> **Note:** Replace `labpass123` with the value of `DB_PASSWORD` from your `.env` file.

> **Note:** If you change `DB_NAME` in `.env`, also update the hardcoded database name `USE labdb;` at the top of `init/mariadb/01-schema.sql`.

## Sample Database: School System

All three engines are initialized with the same example schema:

```
alumnos    → id, nombre (name), apellido (surname), email, fecha_nac (birthdate), ciudad (city)
cursos     → id, nombre (name), descripcion (description), creditos (credits)
matriculas → id, alumno_id, curso_id, fecha_alta (enrollment date)
notas      → id, matricula_id, evaluacion (exam name), nota (grade)
```

With **5 students**, **5 courses**, **10 enrollments** and **13 grade records**.

### Beginner Exercises

```sql
-- 1. View all students
SELECT * FROM alumnos;

-- 2. Find students from Madrid
SELECT nombre, apellido FROM alumnos WHERE ciudad = 'Madrid';

-- 3. Courses worth more than 3 credits
SELECT nombre, creditos FROM cursos WHERE creditos > 3;

-- 4. Which courses does each student have? (JOIN)
SELECT a.nombre, a.apellido, c.nombre AS curso
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN cursos c ON c.id = m.curso_id
ORDER BY a.apellido;

-- 5. Average grade per student
SELECT a.nombre, a.apellido, ROUND(AVG(n.nota), 2) AS promedio
FROM alumnos a
JOIN matriculas m ON a.id = m.alumno_id
JOIN notas n ON n.matricula_id = m.id
GROUP BY a.id, a.nombre, a.apellido
ORDER BY promedio DESC;
```

## Security Notes

- **Default password:** Change `DB_PASSWORD` in `.env` before deploying on any network outside the controlled classroom.
- **Firewall:** On a VPS, consider restricting ports 3306, 5432, and 3050 to the server's loopback interface, and only exposing port 8080 (Adminer) to students.
- **`.env` never in the repository:** The `.gitignore` already excludes it.
- **Firebird SYSDBA password:** The `SYSDBA` password equals `DB_PASSWORD` (the `ISC_PASSWORD` variable in the compose file). Keep it in a safe place.

---

## Project Structure

```
databases/
├── docker-compose.yml          # Service definitions (MariaDB, PostgreSQL, Firebird, Adminer)
├── .env.example                # Environment variable template
├── .gitignore
├── README.md                   # This file
├── init/
│   ├── mariadb/
│   │   └── 01-schema.sql       # Auto-loaded on first start
│   ├── postgresql/
│   │   └── 01-schema.sql       # Auto-loaded on first start
│   └── firebird/
│       └── 01-schema.sql       # Load manually (see instructions above)
└── scripts/
    ├── start.sh  / start.bat   # Start environment
    ├── stop.sh   / stop.bat    # Stop environment
    └── reset.sh  / reset.bat   # Full reset (deletes all data)
```

---

*DB Learning Lab — Entorno de aprendizaje multi-motor / Multi-engine learning environment*
