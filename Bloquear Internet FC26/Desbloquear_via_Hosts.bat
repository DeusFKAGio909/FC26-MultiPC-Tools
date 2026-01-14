@echo off
:: Script para QUITAR el bloqueo de EA/FC26 del archivo hosts
:: Debe ejecutarse como Administrador
setlocal EnableDelayedExpansion

title Desbloquear Internet via Hosts

echo ========================================
echo   DESBLOQUEAR INTERNET VIA HOSTS
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

:: Verificar si el bloqueo existe
findstr /C:"%MARKER%" "%HOSTS_FILE%" >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] No se encontro ningun bloqueo de FC26 en el archivo hosts.
    echo El juego ya deberia poder conectarse a internet.
    echo.
    pause
    exit /b 0
)

echo Eliminando bloqueo del archivo hosts...
echo.

:: Usar PowerShell para eliminar las lineas de bloqueo de forma robusta
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
    echo Limpiando cache de DNS...
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
    echo Opciones:
    echo.
    echo OPCION 1 - Restaurar backup:
    echo   Si tienes un backup, puedes restaurarlo:
    if exist "%BACKUP_FILE%" (
        echo   [El backup existe: %BACKUP_FILE%]
        echo.
        choice /C SN /M "Deseas restaurar el backup ahora? (S/N)"
        if errorlevel 2 goto :manual
        if errorlevel 1 (
            copy /Y "%BACKUP_FILE%" "%HOSTS_FILE%" >nul
            if !errorLevel! equ 0 (
                echo [OK] Backup restaurado exitosamente.
                ipconfig /flushdns >nul 2>&1
                goto :done
            ) else (
                echo [ERROR] No se pudo restaurar el backup.
            )
        )
    ) else (
        echo   [No hay backup disponible]
    )
    
    :manual
    echo.
    echo OPCION 2 - Editar manualmente:
    echo   1. Abre el archivo: %HOSTS_FILE%
    echo   2. Busca las lineas entre "# === BLOQUEO FC26 ===" y "# === FIN BLOQUEO FC26 ==="
    echo   3. Elimina todas esas lineas
    echo   4. Guarda el archivo
    echo.
    choice /C SN /M "Deseas abrir el archivo hosts ahora? (S/N)"
    if errorlevel 1 if not errorlevel 2 (
        notepad "%HOSTS_FILE%"
    )
)

:done
echo.
pause
