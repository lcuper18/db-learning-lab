@echo off
REM =============================================================
REM DB Learning Lab — Reinicio completo (Windows)
REM ADVERTENCIA: Elimina todos los datos de las bases de datos.
REM =============================================================

cd /d "%~dp0\.."

IF NOT EXIST ".env" (
    echo [ERROR] Archivo .env no encontrado.
    echo         Copia .env.example a .env y configura las variables.
    pause
    exit /b 1
)

echo ADVERTENCIA: Se eliminaran todos los datos de las bases de datos.
set /p CONFIRMAR="Confirmar reinicio completo? [s/N]: "
if /i NOT "%CONFIRMAR%"=="s" (
    echo Operacion cancelada.
    pause
    exit /b 0
)

echo Deteniendo contenedores y eliminando volumenes...
docker compose down -v

echo Reiniciando entorno desde cero...
docker compose up -d

echo.
echo Entorno reiniciado con datos de ejemplo frescos.
echo   Adminer -^> http://localhost:8080
pause
