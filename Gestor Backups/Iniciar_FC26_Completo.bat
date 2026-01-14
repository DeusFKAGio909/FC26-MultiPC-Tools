@echo off
:: ============================================================
:: INICIO COMPLETO FC26
:: ============================================================
:: Limpia cache + Inicia monitoreo automatico de backups
::
:: CARPETA DE CACHE (DynamicLoc):
:: AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
::
:: CARPETA NATIVA DEL JUEGO:
:: AppData\Local\EA SPORTS FC 26\settings
:: ============================================================

setlocal EnableDelayedExpansion

title Inicio Completo FC26

:: Obtener rutas
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%Gestor_Guardados_FC26.ps1"
set "CACHE_FOLDER=%USERPROFILE%\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc"

cls
echo.
echo ========================================
echo   INICIO COMPLETO FC26
echo ========================================
echo.
echo Este proceso hara automaticamente:
echo   1. Limpiar cache pre-juego (DynamicLoc)
echo   2. Iniciar monitoreo automatico de backups
echo.
echo UBICACIONES:
echo   - CACHE: AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
echo   - PARTIDAS: AppData\Local\EA SPORTS FC 26\settings
echo   - BACKUPS: LTA MOD 26 V1\Backups Guardados\
echo.
echo ========================================
echo.
echo ========================================
echo   PASO 1 DE 2: LIMPIANDO CACHE
echo ========================================
echo.
echo CARPETA DE CACHE (DynamicLoc):
echo   !CACHE_FOLDER!
echo.

:: Verificar si existe la carpeta de cache
if not exist "!CACHE_FOLDER!" (
    echo [!] Carpeta de cache no existe (normal si ya estaba limpia).
    echo.
) else (
    echo [OK] Carpeta de cache encontrada.
    echo.
    
    :: Contar archivos
    set "FILE_COUNT=0"
    for %%F in ("!CACHE_FOLDER!\*.*") do set /a "FILE_COUNT+=1"
    
    :: Contar carpetas
    set "FOLDER_COUNT=0"
    for /d %%D in ("!CACHE_FOLDER!\*") do set /a "FOLDER_COUNT+=1"
    
    if !FILE_COUNT! equ 0 if !FOLDER_COUNT! equ 0 (
        echo [OK] La carpeta de cache ya esta vacia.
        echo.
    ) else (
        echo Contenido encontrado:
        echo   - !FILE_COUNT! archivo(s)
        echo   - !FOLDER_COUNT! carpeta(s)
        echo.
        echo Eliminando cache...
        
        :: Eliminar archivos
        if !FILE_COUNT! gtr 0 (
            del /Q /F "!CACHE_FOLDER!\*.*" 2>nul
            echo   [OK] Archivos eliminados.
        )
        
        :: Eliminar subcarpetas
        if !FOLDER_COUNT! gtr 0 (
            for /d %%D in ("!CACHE_FOLDER!\*") do (
                echo   [OK] Eliminando carpeta: %%~nxD
                rd /S /Q "%%D" 2>nul
            )
        )
        
        echo.
        echo [OK] CACHE LIMPIADO EXITOSAMENTE
        echo.
    )
)

:: Verificar configuracion
set "CONFIG_FILE=%SCRIPT_DIR%Gestor_Guardados_Config.json"
if not exist "!CONFIG_FILE!" (
    echo ========================================
    echo   CONFIGURACION INICIAL NECESARIA
    echo ========================================
    echo.
    echo No se encontro configuracion previa.
    echo Configurando rutas automaticamente...
    echo.
    powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" -Config
    echo.
)

echo ========================================
echo   PASO 2 DE 2: INICIANDO MONITOREO
echo ========================================
echo.
echo El sistema monitoreara la carpeta de partidas del juego.
echo Cuando FC26 guarde una partida, se creara un backup automatico.
echo.
echo ========================================
echo   MONITOREO ACTIVO
echo ========================================
echo.
echo   Presiona Ctrl+C para DETENER el monitoreo.
echo.
echo   IMPORTANTE: Cuando presiones Ctrl+C, responde "N" para
echo   cerrar correctamente (no presiones "S" o se cerrara mal).
echo.
echo ========================================
echo.

cmd /c powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" -Start

echo.
echo ========================================
echo   MONITOREO DETENIDO
echo ========================================
echo.
echo El monitoreo ha sido detenido.
echo.
echo Presiona cualquier tecla para cerrar...
pause >nul
