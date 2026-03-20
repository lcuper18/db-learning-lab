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

echo ""
echo "Servicios disponibles:"
echo "  Adminer (GUI web)   -> http://localhost:8080"
echo "  MariaDB             -> localhost:3306"
echo "  PostgreSQL          -> localhost:5432"
echo "  Firebird            -> localhost:3050"
echo ""
echo "Para ver los logs: docker compose logs -f"
