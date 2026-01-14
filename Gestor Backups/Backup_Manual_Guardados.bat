@echo off
:: ============================================================
:: BACKUP MANUAL DE PARTIDAS FC26
:: ============================================================
:: Crea un backup inmediato de las partidas del juego
::
:: DEFINICIONES:
:: - CARPETA NATIVA: Donde FC26 guarda las partidas
::   Ubicacion: AppData\Local\EA SPORTS FC 26\settings
::
:: - CARPETA DE BACKUPS: Donde guardamos copias de seguridad
::   Ubicacion: LTA MOD 26 V1\Backups Guardados\
:: ============================================================

setlocal EnableDelayedExpansion

title Backup Manual de Partidas FC26

echo.
echo ========================================
echo   BACKUP MANUAL DE PARTIDAS FC26
echo ========================================
echo.

:: Obtener nombre de la PC
set "PC_NAME=%COMPUTERNAME%"
if [%PC_NAME%]==[] set "PC_NAME=PC-UNKNOWN"

:: CARPETA DE BACKUPS (donde guardamos copias de seguridad)
set "SCRIPT_DIR=%~dp0"
set "MOD_BASE_DIR=%~dp0.."
set "BACKUP_FOLDER=%MOD_BASE_DIR%\Backups Guardados"

:: CARPETA NATIVA DEL JUEGO (donde FC26 guarda las partidas)
:: Ubicacion: AppData\Local\EA SPORTS FC 26\settings
set "APPDATA_LOCAL=%LOCALAPPDATA%"
set "GAME_SAVE_FOLDER="

:: Buscar en AppData\Local (ubicacion nativa de FC26)
for %%G in ("EA SPORTS FC 26" "EA Sports FC 26" "FC 26") do (
    if exist "%APPDATA_LOCAL%\%%~G\settings\" (
        set "GAME_SAVE_FOLDER=%APPDATA_LOCAL%\%%~G"
        goto :found
    )
)

:: No encontrado
echo [!] No se encontro la CARPETA NATIVA del juego automaticamente.
echo.
echo La carpeta nativa de FC26 normalmente esta en:
echo   %APPDATA_LOCAL%\EA SPORTS FC 26
echo.
echo Ingresa la ruta manualmente (sin \settings al final):
set /p "GAME_SAVE_FOLDER=Ruta: "

if not exist "!GAME_SAVE_FOLDER!\settings\" (
    echo.
    echo [ERROR] No se encontro la subcarpeta 'settings' en esa ruta.
    pause
    exit /b 1
)

:found
echo.
echo ========================================
echo   UBICACIONES
echo ========================================
echo.
echo PC: %PC_NAME%
echo.
echo CARPETA NATIVA DEL JUEGO (origen):
echo   !GAME_SAVE_FOLDER!\settings\
echo.
echo CARPETA DE BACKUPS (destino):
echo   !BACKUP_FOLDER!
echo.

:: Crear estructura de carpetas de backup
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "datetime=%%I"
set "DATE_FOLDER=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!"
set "TIME_FOLDER=!datetime:~8,2!-!datetime:~10,2!-!datetime:~12,2!"

set "BACKUP_PATH=!BACKUP_FOLDER!\!PC_NAME!\!DATE_FOLDER!\!TIME_FOLDER!"

echo Creando BACKUP en: !BACKUP_PATH!
echo.

:: Crear carpetas
mkdir "!BACKUP_PATH!" 2>nul

:: Copiar archivos de partidas
echo Copiando archivos de partidas...
echo.

:: CmMgrC = Partidas de Modo Carrera
echo   - CmMgrC* (Partidas de Modo Carrera)
xcopy "!GAME_SAVE_FOLDER!\settings\CmMgrC*" "!BACKUP_PATH!\" /Y /Q >nul 2>&1

:: Settings = Configuraciones de perfil (persistentes)
echo   - Settings* (Configuraciones de perfil)
xcopy "!GAME_SAVE_FOLDER!\settings\Settings*" "!BACKUP_PATH!\" /Y /Q >nul 2>&1

:: Squads = Personajes creados (persistentes)
echo   - Squads* (Personajes creados)
xcopy "!GAME_SAVE_FOLDER!\settings\Squads*" "!BACKUP_PATH!\" /Y /Q >nul 2>&1

:: overrideAutodetect.lua = Configuracion del juego
echo   - overrideAutodetect.lua (Configuracion)
if exist "!GAME_SAVE_FOLDER!\settings\overrideAutodetect.lua" (
    copy "!GAME_SAVE_FOLDER!\settings\overrideAutodetect.lua" "!BACKUP_PATH!\" /Y >nul 2>&1
)

:: Crear archivo de informacion
set "INFO_FILE=!BACKUP_PATH!\_BACKUP_INFO.txt"
(
    echo BACKUP MANUAL DE PARTIDAS FC26
    echo ========================================
    echo Fecha y Hora: !DATE_FOLDER! !TIME_FOLDER!
    echo PC de origen: %PC_NAME%
    echo.
    echo ORIGEN ^(Carpeta nativa del juego^):
    echo !GAME_SAVE_FOLDER!\settings\
    echo.
    echo DESTINO ^(Este backup^):
    echo !BACKUP_PATH!
    echo.
    echo ARCHIVOS INCLUIDOS:
    echo - CmMgrC* = Partidas de Modo Carrera
    echo - Settings* = Configuraciones de perfil ^(persistentes^)
    echo - Squads* = Personajes creados ^(persistentes^)
    echo - overrideAutodetect.lua = Configuracion del juego
) > "!INFO_FILE!"

echo.
echo ========================================
echo   BACKUP CREADO EXITOSAMENTE
echo ========================================
echo.
echo BACKUP guardado en:
echo   !BACKUP_PATH!
echo.
echo Archivos respaldados:
dir "!BACKUP_PATH!" /B 2>nul
echo.

pause
