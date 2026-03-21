#!/usr/bin/env bash
# =============================================================
# DB Learning Lab — Arrancar el entorno
# =============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

if [ ! -f .env ]; then
  echo "[ERROR] Archivo .env no encontrado."
  echo "        Copia .env.example a .env y configura las variables."
  exit 1
fi

echo "Arrancando DB Learning Lab..."
docker compose up -d

# ----------------------------------------------------------------
# Inicialización automática de Firebird
# El contenedor de Firebird no ejecuta scripts al arrancar.
# Esperamos a que esté listo y cargamos el schema si no existe
# la tabla 'alumnos' (indicador de que el schema está vacío).
# ----------------------------------------------------------------
echo ""
echo "Esperando a que Firebird esté listo..."

# Leer credenciales del .env de forma robusta:
#   - tr -d '\r' elimina retornos de carro de archivos creados en Windows
#   - grep filtra líneas que empiezan por # (comentarios)
#   - La expresión corta en el primer '=' para soportar contraseñas con '='
_env_get() {
  grep -E "^${1}=" .env | head -1 | cut -d= -f2- | tr -d '\r'
}

FB_USER=$(_env_get DB_USER)
FB_PASS=$(_env_get DB_PASSWORD)
FB_DB=$(_env_get DB_NAME)

_firebird_init() {
  local MAX_RETRIES=30
  local RETRY=0

  until docker exec firebird_container isql-fb \
        -user "$FB_USER" -password "$FB_PASS" \
        "/firebird/data/${FB_DB}" \
        -e "SELECT 1 FROM RDB\$DATABASE;" > /dev/null 2>&1; do
    RETRY=$((RETRY + 1))
    if [ "$RETRY" -ge "$MAX_RETRIES" ]; then
      echo "[AVISO] Firebird no respondió a tiempo. Carga el schema manualmente:"
      echo "        docker exec -i firebird_container isql-fb -user \$DB_USER \\"
      echo "          -password \$DB_PASSWORD /firebird/data/\$DB_NAME \\"
      echo "          < init/firebird/01-schema.sql"
      return 0
    fi
    sleep 2
  done

  # Comprobar si el schema ya fue cargado
  local TABLE_EXISTS
  TABLE_EXISTS=$(docker exec firebird_container isql-fb \
    -user "$FB_USER" -password "$FB_PASS" \
    "/firebird/data/${FB_DB}" \
    -e "SELECT COUNT(*) FROM RDB\$RELATIONS WHERE RDB\$RELATION_NAME = 'ALUMNOS';" 2>/dev/null \
    | grep -E '^[[:space:]]*[0-9]' | tr -d ' \r' || echo "0")

  if [ "$TABLE_EXISTS" = "0" ] || [ -z "$TABLE_EXISTS" ]; then
    echo "Cargando schema inicial de Firebird..."
    docker exec -i firebird_container isql-fb \
      -user "$FB_USER" -password "$FB_PASS" \
      "/firebird/data/${FB_DB}" \
      < init/firebird/01-schema.sql && \
      echo "  Schema de Firebird cargado correctamente." || \
      echo "  [AVISO] Error al cargar el schema. Revisa: docker compose logs firebird"
  else
    echo "  Schema de Firebird ya existe, omitiendo carga."
  fi
}

_firebird_init

echo ""
echo "Servicios disponibles:"
echo "  CloudBeaver (DBeaver web) -> http://localhost:8978"
echo "  Adminer (GUI web ligera)  -> http://localhost:8080"
echo "  MariaDB                   -> localhost:3306"
echo "  PostgreSQL                -> localhost:5432"
echo "  Firebird                  -> localhost:3050"
echo ""
echo "Para ver los logs: docker compose logs -f"
echo "Para ver el estado: ./scripts/status.sh"
