@echo off
:: Script batch para ejecutar el desbloqueador de internet
:: Este archivo solicita permisos de administrador automaticamente

title Desbloqueador de Internet para FC26

echo ========================================
echo   DESBLOQUEADOR DE INTERNET PARA FC26
echo ========================================
echo.

:: Verificar si ya somos administrador
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :runScript
)

:: Solicitar elevacion de privilegios
echo Solicitando permisos de administrador...
echo.

:: Crear VBScript temporal para solicitar UAC
set "vbsFile=%temp%\getadmin_%random%.vbs"
echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsFile%"
echo UAC.ShellExecute "cmd.exe", "/c cd /d ""%~dp0"" && PowerShell -ExecutionPolicy Bypass -File ""%~dp0Desbloquear_Internet_FC26.ps1""", "", "runas", 1 >> "%vbsFile%"

:: Ejecutar el VBScript
cscript //nologo "%vbsFile%"

:: Eliminar el VBScript temporal
del "%vbsFile%" >nul 2>&1

exit /b

:runScript
echo Ejecutando script de PowerShell...
echo.
cd /d "%~dp0"
PowerShell -ExecutionPolicy Bypass -File "%~dp0Desbloquear_Internet_FC26.ps1"
