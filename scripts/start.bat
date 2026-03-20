@echo off
REM =============================================================
REM DB Learning Lab — Arrancar el entorno (Windows)
REM =============================================================

cd /d "%~dp0\.."

IF NOT EXIST ".env" (
    echo [ERROR] Archivo .env no encontrado.
    echo         Copia .env.example a .env y configura las variables.
    pause
    exit /b 1
)

echo Arrancando DB Learning Lab...
docker compose up -d

echo.
echo Servicios disponibles:
echo   Adminer (GUI web)   -^> http://localhost:8080
echo   MariaDB             -^> localhost:3306
echo   PostgreSQL          -^> localhost:5432
echo   Firebird            -^> localhost:3050
echo.
echo Para ver los logs: docker compose logs -f
pause
