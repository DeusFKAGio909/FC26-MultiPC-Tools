@echo off
:: Script para hacer backup de los guardados de FC26
:: No requiere permisos de administrador
setlocal EnableDelayedExpansion

title Backup de Guardados FC26

echo ========================================
echo   BACKUP DE GUARDADOS FC26
echo ========================================
echo.

:: Definir rutas posibles de guardados
set "DOCS=%USERPROFILE%\Documents"
set "ONEDRIVE_DOCS=%USERPROFILE%\OneDrive\Documents"
set "ONEDRIVE_DOCS2=%USERPROFILE%\OneDrive\Documentos"

:: Nombres posibles de la carpeta del juego
set "GAME_FOLDER1=EA SPORTS FC 26"
set "GAME_FOLDER2=EA Sports FC 26"
set "GAME_FOLDER3=FC 26"

set "SAVE_PATH="

:: Buscar la carpeta de guardados
echo Buscando carpeta de guardados de FC26...
echo.

:: Buscar en Documents normal
for %%G in ("%GAME_FOLDER1%" "%GAME_FOLDER2%" "%GAME_FOLDER3%") do (
    if exist "%DOCS%\%%~G\settings\" (
        set "SAVE_PATH=%DOCS%\%%~G"
        echo [OK] Encontrado en: %DOCS%\%%~G
        goto :found
    )
)

:: Buscar en OneDrive Documents
for %%G in ("%GAME_FOLDER1%" "%GAME_FOLDER2%" "%GAME_FOLDER3%") do (
    if exist "%ONEDRIVE_DOCS%\%%~G\settings\" (
        set "SAVE_PATH=%ONEDRIVE_DOCS%\%%~G"
        echo [OK] Encontrado en: %ONEDRIVE_DOCS%\%%~G
        goto :found
    )
)

:: Buscar en OneDrive Documentos (espanol)
for %%G in ("%GAME_FOLDER1%" "%GAME_FOLDER2%" "%GAME_FOLDER3%") do (
    if exist "%ONEDRIVE_DOCS2%\%%~G\settings\" (
        set "SAVE_PATH=%ONEDRIVE_DOCS2%\%%~G"
        echo [OK] Encontrado en: %ONEDRIVE_DOCS2%\%%~G
        goto :found
    )
)

:: No encontrado
echo [!] No se encontro la carpeta de guardados automaticamente.
echo.
echo Rutas buscadas:
echo   - %DOCS%\EA SPORTS FC 26\settings\
echo   - %ONEDRIVE_DOCS%\EA SPORTS FC 26\settings\
echo   - %ONEDRIVE_DOCS2%\EA SPORTS FC 26\settings\
echo.
echo Por favor, ingresa la ruta manualmente.
echo Ejemplo: C:\Users\TuUsuario\Documents\EA SPORTS FC 26
echo.
set /p "SAVE_PATH=Ruta de la carpeta del juego: "

if not exist "!SAVE_PATH!\settings\" (
    echo.
    echo [ERROR] No se encontro la subcarpeta 'settings' en esa ruta.
    echo Verifica que la ruta sea correcta.
    pause
    exit /b 1
)

:found
echo.
echo Carpeta de guardados: !SAVE_PATH!\settings\
echo.

:: Crear carpeta de backups
set "BACKUP_BASE=%~dp0Backups"
if not exist "!BACKUP_BASE!" mkdir "!BACKUP_BASE!"

:: Crear nombre del backup con fecha y hora
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "datetime=%%I"
set "TIMESTAMP=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!_!datetime:~8,2!-!datetime:~10,2!-!datetime:~12,2!"
set "BACKUP_FOLDER=!BACKUP_BASE!\Backup_!TIMESTAMP!"

echo ========================================
echo   MENU DE OPCIONES
echo ========================================
echo.
echo [1] Crear nuevo backup
echo [2] Restaurar backup anterior
echo [3] Ver backups existentes
echo [4] Abrir carpeta de guardados
echo [5] Salir
echo.
choice /C 12345 /M "Selecciona una opcion"

if errorlevel 5 goto :exit
if errorlevel 4 goto :open_folder
if errorlevel 3 goto :list_backups
if errorlevel 2 goto :restore
if errorlevel 1 goto :backup

:backup
echo.
echo Creando backup...
echo.

:: Crear carpeta del backup
mkdir "!BACKUP_FOLDER!" 2>nul

:: Copiar todos los archivos de settings
xcopy "!SAVE_PATH!\settings\*" "!BACKUP_FOLDER!\settings\" /E /I /Y /Q

if !errorLevel! equ 0 (
    echo.
    echo ========================================
    echo   BACKUP CREADO EXITOSAMENTE
    echo ========================================
    echo.
    echo Ubicacion: !BACKUP_FOLDER!
    echo.
    echo Archivos respaldados:
    dir "!BACKUP_FOLDER!\settings\" /B 2>nul
    echo.
    echo Este backup incluye:
    echo   - Configuraciones del juego
    echo   - Guardados del Modo Carrera
    echo   - Progreso general
    echo.
) else (
    echo.
    echo [ERROR] No se pudo crear el backup.
    echo Verifica que la carpeta de guardados exista.
)
goto :end

:restore
echo.
echo ========================================
echo   RESTAURAR BACKUP
echo ========================================
echo.

if not exist "!BACKUP_BASE!" (
    echo [!] No hay backups disponibles.
    goto :end
)

echo Backups disponibles:
echo.
set "count=0"
for /d %%D in ("!BACKUP_BASE!\Backup_*") do (
    set /a "count+=1"
    echo   [!count!] %%~nxD
    set "backup_!count!=%%D"
)

if !count! equ 0 (
    echo [!] No hay backups disponibles.
    goto :end
)

echo.
echo   [0] Cancelar
echo.
set /p "selection=Selecciona el numero del backup a restaurar: "

if "!selection!"=="0" goto :end
if !selection! gtr !count! (
    echo [ERROR] Seleccion invalida.
    goto :end
)

set "selected_backup=!backup_%selection%!"

echo.
echo [ADVERTENCIA] Esto sobrescribira tus guardados actuales.
echo Backup seleccionado: !selected_backup!
echo.
choice /C SN /M "Estas seguro? (S/N)"
if errorlevel 2 goto :end

:: Hacer backup de los guardados actuales antes de restaurar
set "PRE_RESTORE_BACKUP=!BACKUP_BASE!\Pre_Restauracion_!TIMESTAMP!"
mkdir "!PRE_RESTORE_BACKUP!" 2>nul
xcopy "!SAVE_PATH!\settings\*" "!PRE_RESTORE_BACKUP!\settings\" /E /I /Y /Q >nul 2>&1
echo.
echo [OK] Backup de seguridad creado: !PRE_RESTORE_BACKUP!

:: Restaurar el backup seleccionado
xcopy "!selected_backup!\settings\*" "!SAVE_PATH!\settings\" /E /I /Y /Q

if !errorLevel! equ 0 (
    echo.
    echo ========================================
    echo   BACKUP RESTAURADO EXITOSAMENTE
    echo ========================================
    echo.
    echo Tus guardados han sido restaurados desde:
    echo !selected_backup!
) else (
    echo.
    echo [ERROR] No se pudo restaurar el backup.
)
goto :end

:list_backups
echo.
echo ========================================
echo   BACKUPS EXISTENTES
echo ========================================
echo.

if not exist "!BACKUP_BASE!" (
    echo [!] No hay backups disponibles.
    goto :end
)

echo Ubicacion: !BACKUP_BASE!
echo.
set "count=0"
for /d %%D in ("!BACKUP_BASE!\*") do (
    set /a "count+=1"
    echo   - %%~nxD
)

if !count! equ 0 (
    echo [!] No hay backups disponibles.
)
echo.
echo Total: !count! backup(s)
goto :end

:open_folder
echo.
echo Abriendo carpeta de guardados...
explorer "!SAVE_PATH!\settings\"
goto :end

:end
echo.
pause
goto :exit

:exit
