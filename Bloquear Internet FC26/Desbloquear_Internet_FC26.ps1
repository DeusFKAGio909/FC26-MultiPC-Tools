# Script para desbloquear conexiones de internet de FC26
# Ejecutar como Administrador

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Desbloqueador de Internet para FC26"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESBLOQUEADOR DE INTERNET PARA FC26" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[ERROR] Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Write-Host "Haz clic derecho en el script y selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Nombre base de la regla del firewall
$ruleNameBase = "Bloquear FC26 Internet"

# Buscar y eliminar todas las reglas relacionadas
Write-Host "Buscando reglas de bloqueo de FC26..." -ForegroundColor Cyan
Write-Host ""

$existingRules = Get-NetFirewallRule -DisplayName "$ruleNameBase*" -ErrorAction SilentlyContinue

if ($existingRules) {
    $ruleCount = @($existingRules).Count
    Write-Host "Se encontraron $ruleCount regla(s) de bloqueo." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($rule in $existingRules) {
        Write-Host "Eliminando: $($rule.DisplayName)" -ForegroundColor Cyan
        try {
            Remove-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction Stop
            Write-Host "[OK] Regla eliminada exitosamente." -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] No se pudo eliminar la regla: $_" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  DESBLOQUEO COMPLETADO" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Se eliminaron $ruleCount regla(s) de firewall." -ForegroundColor Cyan
    Write-Host "FC26 ahora puede conectarse a internet normalmente." -ForegroundColor Green
} else {
    Write-Host "[!] No se encontraron reglas de bloqueo para FC26." -ForegroundColor Yellow
    Write-Host "El juego ya deberia poder conectarse a internet." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para salir"
