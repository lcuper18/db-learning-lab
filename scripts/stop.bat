@echo off
REM =============================================================
REM DB Learning Lab — Detener el entorno (Windows)
REM =============================================================

cd /d "%~dp0\.."

echo Deteniendo DB Learning Lab...
docker compose down

echo.
echo Entorno detenido. Los datos se conservan en los volumenes de Docker.
echo Para volver a arrancar: scripts\start.bat
pause
