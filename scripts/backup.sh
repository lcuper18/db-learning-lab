#!/usr/bin/env bash
# =============================================================
# DB Learning Lab — Copia de seguridad de las bases de datos
# =============================================================
# Guarda dumps de MariaDB, PostgreSQL y Firebird en backups/
# El directorio backups/ está excluido del repositorio git.
# =============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

if [ ! -f .env ]; then
  echo "[ERROR] Archivo .env no encontrado."
  exit 1
fi

_env_get() {
  grep -E "^${1}=" .env | head -1 | cut -d= -f2- | tr -d '\r'
}

DB_USER=$(_env_get DB_USER)
DB_PASS=$(_env_get DB_PASSWORD)
DB_NAME=$(_env_get DB_NAME)

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$PROJECT_DIR/backups/$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

echo "Guardando copias de seguridad en: backups/$TIMESTAMP/"
echo ""

# --- MariaDB ---
echo "  [1/3] MariaDB..."
docker exec mariadb_container \
  mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  > "$BACKUP_DIR/mariadb_${DB_NAME}.sql" && \
  echo "        OK -> backups/$TIMESTAMP/mariadb_${DB_NAME}.sql" || \
  echo "        [ERROR] Fallo en el backup de MariaDB"

# --- PostgreSQL ---
echo "  [2/3] PostgreSQL..."
docker exec -e PGPASSWORD="$DB_PASS" postgresql_container \
  pg_dump -U "$DB_USER" -d "$DB_NAME" -F plain \
  > "$BACKUP_DIR/postgresql_${DB_NAME}.sql" && \
  echo "        OK -> backups/$TIMESTAMP/postgresql_${DB_NAME}.sql" || \
  echo "        [ERROR] Fallo en el backup de PostgreSQL"

# --- Firebird ---
echo "  [3/3] Firebird..."
docker exec firebird_container \
  gbak -b -user "$DB_USER" -password "$DB_PASS" \
  "/firebird/data/${DB_NAME}" stdout \
  > "$BACKUP_DIR/firebird_${DB_NAME}.fbk" && \
  echo "        OK -> backups/$TIMESTAMP/firebird_${DB_NAME}.fbk" || \
  echo "        [ERROR] Fallo en el backup de Firebird"

echo ""
echo "Copias de seguridad completadas en: backups/$TIMESTAMP/"
echo "Para restaurar, consulta la sección 'Backup y restauración' del README."
