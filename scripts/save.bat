@echo off
REM =============================================================
REM DB Learning Lab — Guardar cambios y publicar en GitHub (Windows)
REM =============================================================
REM Uso: scripts\save.bat "descripcion del cambio"
REM Si no se pasa argumento, se pedira interactivamente.
REM =============================================================

cd /d "%~dp0\.."

REM Verificar que hay un repo git
IF NOT EXIST ".git" (
    echo [ERROR] No se encontro repositorio git en %CD%
    pause
    exit /b 1
)

REM Verificar si hay cambios
git diff --quiet >nul 2>&1
git diff --cached --quiet >nul 2>&1
git ls-files --others --exclude-standard >nul 2>&1

FOR /F "tokens=*" %%i IN ('git status --short') DO SET CAMBIOS=%%i
IF "%CAMBIOS%"=="" (
    echo No hay cambios pendientes. El repositorio esta al dia.
    pause
    exit /b 0
)

REM Obtener mensaje del commit
IF NOT "%~1"=="" (
    SET MENSAJE=%~1
) ELSE (
    echo Archivos modificados:
    git status --short
    echo.
    set /p MENSAJE="Descripcion del cambio (mensaje de commit): "
    IF "%MENSAJE%"=="" (
        echo [ERROR] El mensaje no puede estar vacio.
        pause
        exit /b 1
    )
)

REM Añadir todos los cambios, hacer commit y push
git add .
git commit -m "%MENSAJE%"
git push

echo.
echo Cambios publicados en GitHub correctamente.
FOR /F "tokens=*" %%i IN ('git remote get-url origin') DO echo   Repositorio: %%i
pause
