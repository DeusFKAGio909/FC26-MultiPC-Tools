@echo off
:: Script para bloquear conexiones de EA/FC26 usando el archivo hosts
:: Debe ejecutarse como Administrador
setlocal EnableDelayedExpansion

title Bloqueo de Internet via Hosts

echo ========================================
echo   BLOQUEO DE INTERNET VIA HOSTS
echo ========================================
echo.

:: Verificar permisos de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Este script debe ejecutarse como Administrador
    echo.
    echo Solicitando permisos de administrador...
    
    :: Crear VBScript temporal para solicitar UAC
    set "vbsFile=%temp%\getadmin_%random%.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "!vbsFile!"
    echo UAC.ShellExecute "cmd.exe", "/c cd /d ""%~dp0"" && ""%~f0""", "", "runas", 1 >> "!vbsFile!"
    cscript //nologo "!vbsFile!"
    del "!vbsFile!" >nul 2>&1
    exit /b
)

set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "BACKUP_FILE=%SystemRoot%\System32\drivers\etc\hosts.fc26_backup"
set "MARKER=# === BLOQUEO FC26 ==="

:: Crear backup del archivo hosts original (solo la primera vez)
if not exist "%BACKUP_FILE%" (
    echo Creando backup del archivo hosts...
    copy "%HOSTS_FILE%" "%BACKUP_FILE%" >nul
    if !errorLevel! equ 0 (
        echo [OK] Backup creado: %BACKUP_FILE%
    ) else (
        echo [ERROR] No se pudo crear el backup
        pause
        exit /b 1
    )
    echo.
)

:: Verificar si ya esta bloqueado
findstr /C:"%MARKER%" "%HOSTS_FILE%" >nul 2>&1
if %errorLevel% equ 0 (
    echo [!] El bloqueo ya esta activo en el archivo hosts.
    echo.
    echo Opciones:
    echo   [1] Quitar el bloqueo
    echo   [2] Salir sin cambios
    echo.
    choice /C 12 /M "Selecciona una opcion"
    if errorlevel 2 goto :end
    if errorlevel 1 goto :unblock
)

:block
echo.
echo Agregando reglas de bloqueo al archivo hosts...
echo.

:: Agregar bloqueos al final del archivo hosts
(
    echo.
    echo %MARKER%
    echo # Dominios de EA bloqueados para FC26
    echo # Para quitar el bloqueo, ejecuta Desbloquear_via_Hosts.bat
    echo # ----------------------------------------
    echo 127.0.0.1 ea.com
    echo 127.0.0.1 www.ea.com
    echo 127.0.0.1 easports.com
    echo 127.0.0.1 www.easports.com
    echo 127.0.0.1 origin.com
    echo 127.0.0.1 www.origin.com
    echo 127.0.0.1 accounts.ea.com
    echo 127.0.0.1 api.ea.com
    echo 127.0.0.1 api.origin.com
    echo 127.0.0.1 login.ea.com
    echo 127.0.0.1 signin.ea.com
    echo 127.0.0.1 fifa.easports.com
    echo 127.0.0.1 www.fifa.easports.com
    echo 127.0.0.1 fc.easports.com
    echo 127.0.0.1 www.fc.easports.com
    echo 127.0.0.1 fut.ea.com
    echo 127.0.0.1 www.fut.ea.com
    echo 127.0.0.1 gateway.ea.com
    echo 127.0.0.1 pin-river.data.ea.com
    echo 127.0.0.1 river.data.ea.com
    echo 127.0.0.1 eaassets-a.akamaihd.net
    echo 127.0.0.1 gosredirector.ea.com
    echo 127.0.0.1 gosredirector.origin.com
    echo 127.0.0.1 eacom.s3.amazonaws.com
    echo 127.0.0.1 telemetry-internal.ea.com
    echo 127.0.0.1 telemetry.ea.com
    echo 127.0.0.1 analytics.ea.com
    echo 127.0.0.1 tos.ea.com
    echo 127.0.0.1 anticheat.ea.com
    echo # ----------------------------------------
    echo # === FIN BLOQUEO FC26 ===
) >> "%HOSTS_FILE%"

:: Limpiar cache de DNS
echo.
echo Limpiando cache de DNS...
ipconfig /flushdns >nul 2>&1

echo.
echo ========================================
echo   BLOQUEO COMPLETADO EXITOSAMENTE
echo ========================================
echo.
echo Los dominios de EA ahora estan redirigidos a localhost.
echo FC26 no podra conectarse a los servidores de EA.
echo.
echo Para quitar el bloqueo, ejecuta "Desbloquear_via_Hosts.bat"
echo.
goto :end

:unblock
echo.
echo Eliminando bloqueo del archivo hosts...
echo.

:: Usar PowerShell para eliminar las lineas de bloqueo de forma mas robusta
PowerShell -ExecutionPolicy Bypass -Command ^
    "$hostsPath = '%HOSTS_FILE%'; " ^
    "$content = Get-Content $hostsPath -Raw; " ^
    "$pattern = '(?s)\r?\n?# === BLOQUEO FC26 ===.*?# === FIN BLOQUEO FC26 ===\r?\n?'; " ^
    "$newContent = $content -replace $pattern, ''; " ^
    "$newContent = $newContent.TrimEnd(); " ^
    "Set-Content -Path $hostsPath -Value $newContent -NoNewline; " ^
    "Add-Content -Path $hostsPath -Value ''"

if %errorLevel% equ 0 (
    :: Limpiar cache de DNS
    ipconfig /flushdns >nul 2>&1
    
    echo.
    echo ========================================
    echo   BLOQUEO ELIMINADO EXITOSAMENTE
    echo ========================================
    echo.
    echo FC26 ahora puede conectarse a internet normalmente.
) else (
    echo.
    echo [ERROR] No se pudo eliminar el bloqueo automaticamente.
    echo.
    echo Solucion manual:
    echo 1. Abre el archivo: %HOSTS_FILE%
    echo 2. Busca las lineas entre "# === BLOQUEO FC26 ===" y "# === FIN BLOQUEO FC26 ==="
    echo 3. Elimina todas esas lineas
    echo 4. Guarda el archivo
)

:end
echo.
echo Nota: Si tienes problemas, puedes restaurar el archivo hosts original
echo copiando el backup desde: %BACKUP_FILE%
echo.
pause
