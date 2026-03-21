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

REM Cargar variables del archivo .env
REM eol=# ignora líneas de comentario que empiezan con #
FOR /F "usebackq eol=# tokens=1,* delims==" %%A IN (".env") DO (
    SET "%%A=%%B"
)

echo Arrancando DB Learning Lab...
docker compose up -d

REM ----------------------------------------------------------------
REM Inicialización automática de Firebird
REM ----------------------------------------------------------------
echo.
echo Esperando a que Firebird este listo...

SET /A RETRY=0
:WAIT_LOOP
docker exec firebird_container isql-fb -user %DB_USER% -password %DB_PASSWORD% "/firebird/data/%DB_NAME%" -e "SELECT 1 FROM RDB$DATABASE;" > NUL 2>&1
IF %ERRORLEVEL% EQU 0 GOTO CHECK_SCHEMA
SET /A RETRY=%RETRY%+1
IF %RETRY% GEQ 30 (
    echo [AVISO] Firebird no respondio a tiempo. Carga el schema manualmente:
    echo   docker exec -i firebird_container isql-fb -user %%DB_USER%% -password %%DB_PASSWORD%% /firebird/data/%%DB_NAME%% ^< init\firebird\01-schema.sql
    GOTO SHOW_SERVICES
)
TIMEOUT /T 2 /NOBREAK > NUL
GOTO WAIT_LOOP

:CHECK_SCHEMA
docker exec firebird_container isql-fb -user %DB_USER% -password %DB_PASSWORD% "/firebird/data/%DB_NAME%" -e "SELECT COUNT(*) FROM RDB$RELATIONS WHERE RDB$RELATION_NAME = 'ALUMNOS';" > "%TEMP%\fb_check.txt" 2>&1
FINDSTR /R "[1-9]" "%TEMP%\fb_check.txt" > NUL 2>&1
IF %ERRORLEVEL% EQU 0 (
    echo   Schema de Firebird ya existe, omitiendo carga.
    GOTO SHOW_SERVICES
)
echo Cargando schema inicial de Firebird...
docker exec -i firebird_container isql-fb -user %DB_USER% -password %DB_PASSWORD% "/firebird/data/%DB_NAME%" < init\firebird\01-schema.sql
IF %ERRORLEVEL% EQU 0 (
    echo   Schema de Firebird cargado correctamente.
) ELSE (
    echo   [AVISO] Error al cargar el schema. Revisa: docker compose logs firebird
)

:SHOW_SERVICES
echo.
echo Servicios disponibles:
echo   CloudBeaver (DBeaver web) -^> http://localhost:8978
echo   Adminer (GUI web ligera)  -^> http://localhost:8080
echo   MariaDB                   -^> localhost:3306
echo   PostgreSQL                -^> localhost:5432
echo   Firebird                  -^> localhost:3050
echo.
echo Para ver los logs: docker compose logs -f
pause
