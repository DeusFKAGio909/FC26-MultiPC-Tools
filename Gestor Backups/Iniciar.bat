@echo off
:: ============================================================
:: GESTOR AUTOMATICO DE BACKUPS FC26 - MENU PRINCIPAL
:: ============================================================
::
:: EJECUTAR ESTE ARCHIVO PARA INICIAR EL SISTEMA
::
:: UBICACIONES:
:: - PARTIDAS DEL JUEGO: AppData\Local\EA SPORTS FC 26\settings
:: - BACKUPS: LTA MOD 26 V1\Backups Guardados\
:: - CACHE DINAMICO: AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
:: ============================================================

setlocal EnableDelayedExpansion

title Gestor de Backups FC26

:: Obtener rutas base
set "SCRIPT_DIR=%~dp0"
set "MOD_BASE_DIR=%SCRIPT_DIR%.."
set "PS_SCRIPT=%SCRIPT_DIR%Gestor_Guardados_FC26.ps1"
set "CONFIG_FILE=%SCRIPT_DIR%Gestor_Guardados_Config.json"

:: CARPETA DE BACKUPS
set "BACKUP_FOLDER=%MOD_BASE_DIR%\Backups Guardados"

:: CARPETA DE CACHE DINAMICO (DynamicLoc)
:: Ruta correcta: C:\Users\[Usuario]\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
set "CACHE_FOLDER=%USERPROFILE%\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc"

:: Verificar si existe el script PowerShell
if not exist "!PS_SCRIPT!" (
    echo [ERROR] No se encontro el script: !PS_SCRIPT!
    pause
    exit /b 1
)

:: Verificar si es primera vez (no existe configuracion)
set "PRIMERA_VEZ=0"
if not exist "!CONFIG_FILE!" set "PRIMERA_VEZ=1"

:menu
cls
echo.
echo ========================================
echo   GESTOR AUTOMATICO DE BACKUPS FC26
echo ========================================

if !PRIMERA_VEZ! equ 1 (
    echo.
    echo   [!] PRIMERA VEZ - Configura primero las opciones 1 y 2
    echo.
)

echo.
echo UBICACIONES:
echo   - PARTIDAS: AppData\Local\EA SPORTS FC 26\settings
echo   - BACKUPS:  LTA MOD 26 V1\Backups Guardados\
echo   - CACHE:    AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
echo.
echo ========================================
echo.
echo   CONFIGURACION INICIAL (hacer primero):
echo   [1] Configurar rutas de guardados del juego
echo   [2] Crear carpeta de backups
echo.
echo   OPCIONES DE USO:
echo   [3] INICIO COMPLETO (Limpiar cache + Monitoreo)
echo   [4] Iniciar solo monitoreo automatico
echo   [5] Limpiar cache pre-juego (DynamicLoc)
echo   [6] Crear backup manual ahora
echo   [7] Ver estado y backups existentes
echo.
echo   [8] Cerrar
echo.
choice /C 12345678 /M "Selecciona una opcion"

if errorlevel 8 goto :cerrar
if errorlevel 7 goto :estado
if errorlevel 6 goto :backup_manual
if errorlevel 5 goto :limpiar_cache
if errorlevel 4 goto :monitoreo
if errorlevel 3 goto :inicio_completo
if errorlevel 2 goto :crear_carpeta_backups
if errorlevel 1 goto :configurar_rutas

:: ============================================================
:: OPCION 1: CONFIGURAR RUTAS DE GUARDADOS DEL JUEGO
:: ============================================================
:configurar_rutas
cls
echo.
echo ========================================
echo   [1] CONFIGURAR RUTAS DE GUARDADOS
echo ========================================
echo.
echo Esta opcion configura donde FC26 guarda las partidas.
echo.
echo UBICACION ESPERADA:
echo   %LOCALAPPDATA%\EA SPORTS FC 26\settings
echo.
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" -Config
set "PRIMERA_VEZ=0"
echo.
echo ========================================
echo Configuracion completada.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: ============================================================
:: OPCION 2: CREAR CARPETA DE BACKUPS
:: ============================================================
:crear_carpeta_backups
cls
echo.
echo ========================================
echo   [2] CREAR CARPETA DE BACKUPS
echo ========================================
echo.
echo Esta carpeta es donde se guardaran las copias de seguridad
echo de tus partidas.
echo.
echo UBICACION:
echo   !BACKUP_FOLDER!
echo.

if exist "!BACKUP_FOLDER!" (
    echo [OK] La carpeta de backups ya existe.
    echo.
    echo Contenido actual:
    dir "!BACKUP_FOLDER!" /B 2>nul
    if errorlevel 1 echo   (vacia)
) else (
    echo Creando carpeta de backups...
    mkdir "!BACKUP_FOLDER!" 2>nul
    if exist "!BACKUP_FOLDER!" (
        echo.
        echo [OK] Carpeta de backups creada exitosamente.
    ) else (
        echo.
        echo [ERROR] No se pudo crear la carpeta.
    )
)
echo.
echo ========================================
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: ============================================================
:: OPCION 3: INICIO COMPLETO (Limpiar cache + Monitoreo)
:: ============================================================
:inicio_completo
cls
echo.
echo ========================================
echo   [3] INICIO COMPLETO
echo ========================================
echo.
echo Este proceso hara automaticamente:
echo   1. Verificar configuracion
echo   2. Limpiar cache pre-juego (DynamicLoc)
echo   3. Iniciar monitoreo automatico de backups
echo.
echo ========================================

:: Verificar configuracion
if not exist "!CONFIG_FILE!" (
    echo.
    echo [!] No hay configuracion previa.
    echo     Ejecuta primero la opcion [1] Configurar rutas.
    echo.
    pause
    goto :menu
)

:: Verificar carpeta de backups
if not exist "!BACKUP_FOLDER!" (
    echo.
    echo [!] No existe la carpeta de backups.
    echo     Ejecuta primero la opcion [2] Crear carpeta de backups.
    echo.
    pause
    goto :menu
)

echo.
echo ========================================
echo   PASO 1: LIMPIEZA DE CACHE
echo ========================================
echo.

:: Verificar si existe la carpeta de cache
if exist "!CACHE_FOLDER!" (
    echo [OK] Carpeta de cache encontrada:
    echo      !CACHE_FOLDER!
    echo.
    
    set "IC_FILE_COUNT=0"
    for %%F in ("!CACHE_FOLDER!\*.*") do set /a "IC_FILE_COUNT+=1"
    
    if !IC_FILE_COUNT! equ 0 (
        echo [OK] La carpeta de cache ya esta vacia.
    ) else (
        echo Archivos encontrados: !IC_FILE_COUNT!
        echo Eliminando...
        del /Q /F "!CACHE_FOLDER!\*.*" 2>nul
        for /d %%D in ("!CACHE_FOLDER!\*") do rd /S /Q "%%D" 2>nul
        echo [OK] Cache limpiado.
    )
    echo.
) else (
    echo [INFO] La carpeta de cache no existe aun.
    echo        Ruta esperada: !CACHE_FOLDER!
    echo.
    echo        Esto es normal si no has jugado con mods recientemente.
    echo        Continuando con el monitoreo...
    echo.
)

echo ========================================
echo   PASO 2: INICIANDO MONITOREO
echo ========================================
echo.
echo El sistema monitoreara la carpeta de partidas del juego.
echo Cuando FC26 guarde, se creara un backup automaticamente.
echo.
echo ========================================
echo   MONITOREO ACTIVO
echo ========================================
echo.
echo   Presiona Ctrl+C para DETENER.
echo.
echo   IMPORTANTE: Cuando presiones Ctrl+C, responde "N"
echo   para volver al menu.
echo.
echo ========================================
echo.

cmd /c powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" -Start

echo.
echo ========================================
echo   MONITOREO DETENIDO
echo ========================================
echo.
pause
goto :menu

:: ============================================================
:: OPCION 4: INICIAR SOLO MONITOREO AUTOMATICO
:: ============================================================
:monitoreo
cls
echo.
echo ========================================
echo   [4] INICIAR MONITOREO AUTOMATICO
echo ========================================
echo.

:: Verificar configuracion
if not exist "!CONFIG_FILE!" (
    echo [!] No hay configuracion previa.
    echo     Ejecuta primero la opcion [1] Configurar rutas.
    echo.
    echo ========================================
    echo Presiona cualquier tecla para volver al menu...
    pause >nul
    goto :menu
)

echo El sistema monitoreara la carpeta de partidas del juego.
echo Cuando FC26 guarde, se creara un backup automaticamente.
echo.
echo ========================================
echo   MONITOREO ACTIVO
echo ========================================
echo.
echo   Presiona Ctrl+C para DETENER.
echo.
echo   IMPORTANTE: Cuando presiones Ctrl+C, responde "N"
echo   para volver al menu.
echo.
echo ========================================
echo.

cmd /c powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" -Start

echo.
echo ========================================
echo   MONITOREO DETENIDO
echo ========================================
echo.
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: ============================================================
:: OPCION 5: LIMPIAR CACHE PRE-JUEGO (DynamicLoc)
:: ============================================================
:limpiar_cache
cls
echo.
echo ========================================
echo   [5] LIMPIAR CACHE PRE-JUEGO
echo ========================================
echo.
echo Esta opcion limpia el cache dinamico (DynamicLoc) que
echo puede causar problemas con los mods.
echo.
echo CARPETA DE CACHE:
echo   !CACHE_FOLDER!
echo.

:: Verificar si existe la carpeta de cache
if not exist "!CACHE_FOLDER!" (
    echo [!] La carpeta de cache no existe en la ruta automatica.
    echo     Ruta buscada: !CACHE_FOLDER!
    echo.
    choice /C SN /M "Quieres ingresar otra ruta manualmente (S/N)"
    if errorlevel 2 (
        echo.
        echo Operacion cancelada.
        echo.
        echo ========================================
        echo Presiona cualquier tecla para volver al menu...
        pause >nul
        goto :menu
    )
    
    echo.
    echo Ingresa la ruta completa del cache:
    echo Ejemplo: C:\Users\Giovanni\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
    echo.
    set /p "CACHE_MANUAL=Ruta: "
    
    if not defined CACHE_MANUAL (
        echo.
        echo Operacion cancelada.
        echo.
        echo ========================================
        echo Presiona cualquier tecla para volver al menu...
        pause >nul
        goto :menu
    )
    
    if exist "!CACHE_MANUAL!" (
        set "CACHE_FOLDER=!CACHE_MANUAL!"
        echo.
        echo [OK] Ruta manual aceptada: !CACHE_FOLDER!
        echo.
    ) else (
        echo.
        echo [ERROR] La ruta ingresada no existe.
        echo.
        echo ========================================
        echo Presiona cualquier tecla para volver al menu...
        pause >nul
        goto :menu
    )
)

:hacer_limpieza_cache
echo [OK] Carpeta de cache encontrada.
echo.

:: Contar archivos
set "FILE_COUNT=0"
for %%F in ("!CACHE_FOLDER!\*.*") do set /a "FILE_COUNT+=1"

:: Contar carpetas
set "FOLDER_COUNT=0"
for /d %%D in ("!CACHE_FOLDER!\*") do set /a "FOLDER_COUNT+=1"

echo Contenido encontrado:
echo   - Archivos: !FILE_COUNT!
echo   - Carpetas: !FOLDER_COUNT!
echo.

if !FILE_COUNT! equ 0 if !FOLDER_COUNT! equ 0 (
    echo [OK] La carpeta de cache ya esta vacia.
    echo     No hay nada que limpiar.
    echo.
    echo ========================================
    echo Presiona cualquier tecla para volver al menu...
    pause >nul
    goto :menu
)

echo Eliminando cache...
echo.

:: Eliminar archivos
if !FILE_COUNT! gtr 0 (
    del /Q /F "!CACHE_FOLDER!\*.*" 2>nul
    echo [OK] Archivos eliminados.
)

:: Eliminar subcarpetas
if !FOLDER_COUNT! gtr 0 (
    for /d %%D in ("!CACHE_FOLDER!\*") do (
        echo   Eliminando carpeta: %%~nxD
        rd /S /Q "%%D" 2>nul
    )
    echo [OK] Carpetas eliminadas.
)

echo.
echo ========================================
echo   CACHE LIMPIADO EXITOSAMENTE
echo ========================================
echo.
echo El juego esta listo para usar con mods.
echo.
echo ========================================
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: ============================================================
:: OPCION 6: CREAR BACKUP MANUAL
:: ============================================================
:backup_manual
cls
echo.
echo ========================================
echo   [6] CREAR BACKUP MANUAL
echo ========================================
echo.

:: Verificar configuracion
if not exist "!CONFIG_FILE!" (
    echo [!] No hay configuracion previa.
    echo     Ejecuta primero la opcion [1] Configurar rutas.
    echo.
    echo ========================================
    echo Presiona cualquier tecla para volver al menu...
    pause >nul
    goto :menu
)

call "%SCRIPT_DIR%Backup_Manual_Guardados.bat"
echo.
echo ========================================
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: ============================================================
:: OPCION 7: VER ESTADO Y BACKUPS
:: ============================================================
:estado
cls
echo.
echo ========================================
echo   [7] ESTADO DEL SISTEMA
echo ========================================
echo.
powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!" -Status
echo.
echo ========================================
echo Presiona cualquier tecla para volver al menu...
pause >nul
goto :menu

:: ============================================================
:: OPCION 8: CERRAR
:: ============================================================
:cerrar
cls
echo.
echo ========================================
echo   CERRANDO GESTOR DE BACKUPS
echo ========================================
echo.
echo Gracias por usar el Gestor de Backups FC26.
echo.
timeout /t 2 >nul
exit /b 0
