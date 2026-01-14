@echo off
:: ============================================================
:: LIMPIEZA DE CACHE PRE-JUEGO FC26
:: ============================================================
:: Limpia el cache DynamicLoc antes de jugar con mods
::
:: CARPETA DE CACHE (DynamicLoc):
:: C:\Users\[Usuario]\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
:: ============================================================

setlocal EnableDelayedExpansion

title Limpieza de Cache FC26

echo.
echo ========================================
echo   LIMPIEZA DE CACHE PRE-JUEGO FC26
echo ========================================
echo.

:: CARPETA DE CACHE (DynamicLoc)
:: Ruta: C:\Users\[Usuario]\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc
set "CACHE_FOLDER=%USERPROFILE%\AppData\Local\Temp\EA SPORTS FC 26\cache0\data\loc"

echo CARPETA DE CACHE (DynamicLoc):
echo   !CACHE_FOLDER!
echo.

:: Verificar si existe la carpeta de cache
if not exist "!CACHE_FOLDER!" (
    echo [!] La carpeta de cache no existe.
    echo.
    echo     Esto es normal si:
    echo     - Nunca has jugado FC26
    echo     - La carpeta ya estaba limpia
    echo     - El juego no ha creado cache aun
    echo.
    echo     Ruta buscada:
    echo     !CACHE_FOLDER!
    echo.
    pause
    exit /b 0
)

echo [OK] Carpeta de cache encontrada.
echo.
echo Analizando contenido...
echo.

:: Contar archivos
set "FILE_COUNT=0"
for %%F in ("!CACHE_FOLDER!\*.*") do set /a "FILE_COUNT+=1"

:: Contar carpetas
set "FOLDER_COUNT=0"
for /d %%D in ("!CACHE_FOLDER!\*") do set /a "FOLDER_COUNT+=1"

echo Archivos encontrados: !FILE_COUNT!
echo Carpetas encontradas: !FOLDER_COUNT!
echo.

if !FILE_COUNT! equ 0 if !FOLDER_COUNT! equ 0 (
    echo [OK] La carpeta de cache ya esta vacia.
    echo     No hay nada que limpiar.
    echo.
    pause
    exit /b 0
)

echo ========================================
echo   LIMPIANDO CACHE...
echo ========================================
echo.

:: Eliminar archivos
if !FILE_COUNT! gtr 0 (
    echo Eliminando !FILE_COUNT! archivo(s)...
    del /Q /F "!CACHE_FOLDER!\*.*" 2>nul
    echo   [OK] Archivos eliminados.
    echo.
)

:: Eliminar subcarpetas
if !FOLDER_COUNT! gtr 0 (
    echo Eliminando !FOLDER_COUNT! carpeta(s)...
    for /d %%D in ("!CACHE_FOLDER!\*") do (
        echo   Eliminando: %%~nxD
        rd /S /Q "%%D" 2>nul
    )
    echo   [OK] Carpetas eliminadas.
    echo.
)

echo ========================================
echo   CACHE LIMPIADO EXITOSAMENTE
echo ========================================
echo.
echo Se eliminaron:
echo   - !FILE_COUNT! archivo(s)
echo   - !FOLDER_COUNT! carpeta(s)
echo.
echo El juego esta listo para usar con mods.
echo.

pause
