#!/usr/bin/env bash
# =============================================================
# DB Learning Lab — Estado del entorno
# =============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# Obtener IP del servidor (primera IP no-loopback)
SERVER_IP=$(ip addr show 2>/dev/null \
  | grep -E 'inet [0-9]' \
  | grep -v '127.0.0.1' \
  | awk '{print $2}' \
  | cut -d/ -f1 \
  | head -1)
SERVER_IP="${SERVER_IP:-localhost}"

echo "============================================================"
echo "  DB Learning Lab — Estado del entorno"
echo "  IP del servidor: ${SERVER_IP}"
echo "============================================================"
echo ""

# Estado de los contenedores
echo "--- Contenedores ---"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}" 2>/dev/null \
  || docker compose ps
echo ""

# URLs de acceso
echo "--- Interfaces web ---"
echo "  CloudBeaver (DBeaver web)  http://${SERVER_IP}:8978"
echo "  Adminer (GUI ligera)       http://${SERVER_IP}:8080"
echo ""

# Adminer: URLs pre-rellenas por motor (solo falta la contraseña)
echo "--- URLs directas Adminer (comparte con los alumnos) ---"
echo "  MariaDB:    http://${SERVER_IP}:8080/?server=mariadb&username=labuser&db=labdb"
echo "  PostgreSQL: http://${SERVER_IP}:8080/?pgsql=postgresql&username=labuser&db=labdb"
echo "  Firebird:   http://${SERVER_IP}:8080/?server=firebird&username=LABUSER&db=%2Ffirebird%2Fdata%2FLABDB"
echo ""

# Cadenas de conexión para clientes SQL externos
echo "--- Cadenas de conexión (clientes externos: DBeaver, TablePlus...) ---"
echo "  MariaDB:"
echo "    Host: ${SERVER_IP}  Puerto: 3306  Usuario: labuser  DB: labdb"
echo "    JDBC: jdbc:mysql://${SERVER_IP}:3306/labdb"
echo ""
echo "  PostgreSQL:"
echo "    Host: ${SERVER_IP}  Puerto: 5432  Usuario: labuser  DB: labdb"
echo "    JDBC: jdbc:postgresql://${SERVER_IP}:5432/labdb"
echo ""
echo "  Firebird:"
echo "    Host: ${SERVER_IP}  Puerto: 3050  Usuario: LABUSER  DB: /firebird/data/LABDB"
echo "    JDBC: jdbc:firebirdsql://${SERVER_IP}:3050//firebird/data/LABDB"
echo ""
echo "============================================================"
