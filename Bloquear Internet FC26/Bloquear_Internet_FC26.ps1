# Script para bloquear conexiones de internet de FC26
# Ejecutar como Administrador

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Bloqueador de Internet para FC26"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  BLOQUEADOR DE INTERNET PARA FC26" -ForegroundColor Cyan
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

# Rutas comunes del ejecutable de FC26 (EA App, Steam, Epic, Origin)
$executablePaths = @(
    # EA App / Origin
    "C:\Program Files\EA Games\EA SPORTS FC 26\FC26.exe",
    "C:\Program Files (x86)\EA Games\EA SPORTS FC 26\FC26.exe",
    "$env:ProgramFiles\EA Games\EA SPORTS FC 26\FC26.exe",
    "${env:ProgramFiles(x86)}\EA Games\EA SPORTS FC 26\FC26.exe",
    # Steam
    "C:\Program Files (x86)\Steam\steamapps\common\EA SPORTS FC 26\FC26.exe",
    "C:\Program Files\Steam\steamapps\common\EA SPORTS FC 26\FC26.exe",
    "D:\Steam\steamapps\common\EA SPORTS FC 26\FC26.exe",
    "D:\SteamLibrary\steamapps\common\EA SPORTS FC 26\FC26.exe",
    "E:\Steam\steamapps\common\EA SPORTS FC 26\FC26.exe",
    "E:\SteamLibrary\steamapps\common\EA SPORTS FC 26\FC26.exe",
    # Epic Games
    "C:\Program Files\Epic Games\EA SPORTS FC 26\FC26.exe",
    "D:\Epic Games\EA SPORTS FC 26\FC26.exe",
    "E:\Epic Games\EA SPORTS FC 26\FC26.exe"
)

$foundPath = $null
$foundPaths = @()

Write-Host "Buscando ejecutables de FC26..." -ForegroundColor Cyan
Write-Host ""

# Buscar todos los ejecutables posibles
foreach ($path in $executablePaths) {
    if (Test-Path $path) {
        $foundPaths += $path
        Write-Host "[OK] Encontrado: $path" -ForegroundColor Green
    }
}

# También buscar el Anti-Cheat y Launcher en las mismas carpetas
$additionalExes = @()
foreach ($path in $foundPaths) {
    $folder = Split-Path -Parent $path
    
    # Buscar EAAntiCheat
    $antiCheatPath = Join-Path $folder "EAAntiCheat.GameServiceLauncher.exe"
    if (Test-Path $antiCheatPath) {
        $additionalExes += $antiCheatPath
        Write-Host "[OK] Encontrado Anti-Cheat: $antiCheatPath" -ForegroundColor Green
    }
    
    # Buscar en subcarpeta
    $antiCheatPath2 = Join-Path $folder "EAAntiCheat\EAAntiCheat.GameServiceLauncher.exe"
    if (Test-Path $antiCheatPath2) {
        $additionalExes += $antiCheatPath2
        Write-Host "[OK] Encontrado Anti-Cheat: $antiCheatPath2" -ForegroundColor Green
    }
}

# Agregar ejecutables adicionales a la lista
$foundPaths += $additionalExes

if ($foundPaths.Count -eq 0) {
    Write-Host "[!] No se encontro FC26.exe en las rutas comunes." -ForegroundColor Yellow
    Write-Host ""
    $customPath = Read-Host "Ingresa la ruta completa al ejecutable FC26.exe (o presiona Enter para cancelar)"
    
    if ([string]::IsNullOrWhiteSpace($customPath)) {
        Write-Host "Operacion cancelada." -ForegroundColor Yellow
        Read-Host "Presiona Enter para salir"
        exit 0
    }
    
    if (Test-Path $customPath) {
        $foundPaths += $customPath
    } else {
        Write-Host "[ERROR] La ruta ingresada no existe: $customPath" -ForegroundColor Red
        Read-Host "Presiona Enter para salir"
        exit 1
    }
}

Write-Host ""
Write-Host "Se encontraron $($foundPaths.Count) ejecutable(s) para bloquear." -ForegroundColor Cyan
Write-Host ""

# Nombre base de la regla del firewall
$ruleNameBase = "Bloquear FC26 Internet"

# Primero eliminar reglas anteriores
Write-Host "Limpiando reglas anteriores..." -ForegroundColor Cyan
$existingRules = Get-NetFirewallRule -DisplayName "$ruleNameBase*" -ErrorAction SilentlyContinue
if ($existingRules) {
    foreach ($rule in $existingRules) {
        Remove-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue
    }
    Write-Host "[OK] Reglas anteriores eliminadas." -ForegroundColor Green
}

# Crear reglas para cada ejecutable encontrado
$counter = 0
foreach ($exePath in $foundPaths) {
    $counter++
    $ruleName = "$ruleNameBase - $counter"
    $exeName = Split-Path -Leaf $exePath
    
    Write-Host "Creando regla para: $exeName" -ForegroundColor Cyan
    
    try {
        # Bloquear conexiones salientes
        New-NetFirewallRule -DisplayName $ruleName `
            -Direction Outbound `
            -Program $exePath `
            -Action Block `
            -Profile Any `
            -Description "Bloquea conexiones de internet de $exeName" `
            -ErrorAction Stop | Out-Null
        
        Write-Host "[OK] Regla creada: $ruleName" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] No se pudo crear regla para $exeName : $_" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  BLOQUEO COMPLETADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Se crearon $counter regla(s) de firewall." -ForegroundColor Cyan
Write-Host "FC26 ahora esta bloqueado para conectarse a internet." -ForegroundColor Green
Write-Host ""
Write-Host "Para verificar las reglas:" -ForegroundColor Yellow
Write-Host "1. Abre 'Firewall de Windows Defender con seguridad avanzada'" -ForegroundColor Yellow
Write-Host "2. Ve a 'Reglas de salida'" -ForegroundColor Yellow
Write-Host "3. Busca reglas que empiecen con '$ruleNameBase'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para desbloquear, ejecuta 'Desbloquear_Internet_FC26.ps1'" -ForegroundColor Cyan
Write-Host ""
Read-Host "Presiona Enter para salir"
