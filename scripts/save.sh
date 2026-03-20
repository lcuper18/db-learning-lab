#!/usr/bin/env bash
# =============================================================
# DB Learning Lab — Guardar cambios y publicar en GitHub
# =============================================================
# Uso: ./scripts/save.sh "descripción del cambio"
# Si no se pasa argumento, se pedirá interactivamente.
# =============================================================
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# Verificar que hay un repo git
if [ ! -d .git ]; then
  echo "[ERROR] No se encontró repositorio git en $PROJECT_DIR"
  exit 1
fi

# Verificar si hay cambios
if git diff --quiet && git diff --cached --quiet; then
  # Comprobar archivos sin seguimiento
  if [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "No hay cambios pendientes. El repositorio está al día."
    exit 0
  fi
fi

# Obtener mensaje del commit
if [ -n "$1" ]; then
  MENSAJE="$1"
else
  echo "Archivos modificados:"
  git status --short
  echo ""
  read -r -p "Descripción del cambio (mensaje de commit): " MENSAJE
  if [ -z "$MENSAJE" ]; then
    echo "[ERROR] El mensaje no puede estar vacío."
    exit 1
  fi
fi

# Añadir todos los cambios, hacer commit y push
git add .
git commit -m "$MENSAJE"
git push

echo ""
echo "Cambios publicados en GitHub correctamente."
echo "  Repositorio: $(git remote get-url origin)"
