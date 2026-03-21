@echo off
REM =============================================================
REM DB Learning Lab — Copia de seguridad (Windows)
REM =============================================================

cd /d "%~dp0\.."

IF NOT EXIST ".env" (
    echo [ERROR] Archivo .env no encontrado.
    pause
    exit /b 1
)

FOR /F "usebackq eol=# tokens=1,* delims==" %%A IN (".env") DO (
    SET "%%A=%%B"
)

REM Generar timestamp YYYYMMDD_HHMMSS
FOR /F "tokens=1-3 delims=/ " %%A IN ('date /t') DO SET DATESTR=%%C%%B%%A
FOR /F "tokens=1-2 delims=: " %%A IN ('time /t') DO SET TIMESTR=%%A%%B
SET TIMESTAMP=%DATESTR%_%TIMESTR%
SET BACKUP_DIR=backups\%TIMESTAMP%
mkdir "%BACKUP_DIR%" 2>NUL

echo Guardando copias de seguridad en: %BACKUP_DIR%\
echo.

echo   [1/3] MariaDB...
docker exec mariadb_container mysqldump -u%DB_USER% -p%DB_PASSWORD% %DB_NAME% > "%BACKUP_DIR%\mariadb_%DB_NAME%.sql"
IF %ERRORLEVEL% EQU 0 (
    echo         OK -^> %BACKUP_DIR%\mariadb_%DB_NAME%.sql
) ELSE (
    echo         [ERROR] Fallo en el backup de MariaDB
)

echo   [2/3] PostgreSQL...
docker exec -e PGPASSWORD=%DB_PASSWORD% postgresql_container pg_dump -U %DB_USER% -d %DB_NAME% -F plain > "%BACKUP_DIR%\postgresql_%DB_NAME%.sql"
IF %ERRORLEVEL% EQU 0 (
    echo         OK -^> %BACKUP_DIR%\postgresql_%DB_NAME%.sql
) ELSE (
    echo         [ERROR] Fallo en el backup de PostgreSQL
)

echo   [3/3] Firebird...
docker exec firebird_container gbak -b -user %DB_USER% -password %DB_PASSWORD% "/firebird/data/%DB_NAME%" stdout > "%BACKUP_DIR%\firebird_%DB_NAME%.fbk"
IF %ERRORLEVEL% EQU 0 (
    echo         OK -^> %BACKUP_DIR%\firebird_%DB_NAME%.fbk
) ELSE (
    echo         [ERROR] Fallo en el backup de Firebird
)

echo.
echo Copias de seguridad completadas en: %BACKUP_DIR%\
pause
