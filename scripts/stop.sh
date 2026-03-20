#!/usr/bin/env bash
# =============================================================
# DB Learning Lab — Detener el entorno
# =============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "Deteniendo DB Learning Lab..."
docker compose down

echo "Entorno detenido. Los datos se conservan en los volúmenes de Docker."
echo "Para volver a arrancar: ./scripts/start.sh"
