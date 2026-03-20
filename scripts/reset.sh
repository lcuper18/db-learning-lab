#!/usr/bin/env bash
# =============================================================
# DB Learning Lab — Reinicio completo (borra todos los datos)
# =============================================================
# ADVERTENCIA: Este script elimina todos los volúmenes de Docker,
# lo que borra los datos almacenados en las bases de datos.
# Úsalo al inicio de cada clase para tener un entorno limpio.
# =============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

if [ ! -f .env ]; then
  echo "[ERROR] Archivo .env no encontrado."
  echo "        Copia .env.example a .env y configura las variables."
  exit 1
fi

echo "ADVERTENCIA: Se eliminarán todos los datos de las bases de datos."
read -r -p "¿Confirmar reinicio completo? [s/N] " respuesta
if [[ ! "$respuesta" =~ ^[sS]$ ]]; then
  echo "Operación cancelada."
  exit 0
fi

echo "Deteniendo contenedores y eliminando volúmenes..."
docker compose down -v

echo "Reiniciando entorno desde cero..."
docker compose up -d

echo ""
echo "Entorno reiniciado con datos de ejemplo frescos."
echo "  Adminer -> http://localhost:8080"
