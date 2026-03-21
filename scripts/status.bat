@echo off
REM =============================================================
REM DB Learning Lab — Estado del entorno (Windows)
REM =============================================================

cd /d "%~dp0\.."

FOR /F "tokens=2 delims=:" %%A IN ('ipconfig ^| findstr /i "IPv4"') DO (
    SET SERVER_IP=%%A
    GOTO :FOUND_IP
)
:FOUND_IP
REM Limpiar espacio inicial
SET SERVER_IP=%SERVER_IP: =%
IF "%SERVER_IP%"=="" SET SERVER_IP=localhost

echo ============================================================
echo   DB Learning Lab -- Estado del entorno
echo   IP del servidor: %SERVER_IP%
echo ============================================================
echo.

echo --- Contenedores ---
docker compose ps
echo.

echo --- Interfaces web ---
echo   CloudBeaver (DBeaver web)  http://%SERVER_IP%:8978
echo   Adminer (GUI ligera)       http://%SERVER_IP%:8080
echo.

echo --- URLs directas Adminer ---
echo   MariaDB:    http://%SERVER_IP%:8080/?server=mariadb^&username=labuser^&db=labdb
echo   PostgreSQL: http://%SERVER_IP%:8080/?pgsql=postgresql^&username=labuser^&db=labdb
echo   Firebird:   http://%SERVER_IP%:8080/?server=firebird^&username=LABUSER^&db=%%2Ffirebird%%2Fdata%%2FLABDB
echo.

echo --- Cadenas de conexion (clientes externos) ---
echo   MariaDB:
echo     Host: %SERVER_IP%  Puerto: 3306  Usuario: labuser  DB: labdb
echo     JDBC: jdbc:mysql://%SERVER_IP%:3306/labdb
echo.
echo   PostgreSQL:
echo     Host: %SERVER_IP%  Puerto: 5432  Usuario: labuser  DB: labdb
echo     JDBC: jdbc:postgresql://%SERVER_IP%:5432/labdb
echo.
echo   Firebird:
echo     Host: %SERVER_IP%  Puerto: 3050  Usuario: LABUSER  DB: /firebird/data/LABDB
echo     JDBC: jdbc:firebirdsql://%SERVER_IP%:3050//firebird/data/LABDB
echo.
echo ============================================================
pause
