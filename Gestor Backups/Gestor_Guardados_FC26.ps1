# ============================================================
# GESTOR AUTOMATICO DE GUARDADOS FC26
# ============================================================
# 
# DEFINICIONES IMPORTANTES:
# - CARPETA NATIVA DEL JUEGO: Donde FC26 guarda las partidas
#   Ubicacion: C:\Users\[Usuario]\AppData\Local\EA SPORTS FC 26\settings
#
# - CARPETA DE BACKUPS: Donde este sistema guarda copias de seguridad
#   Ubicacion: LTA MOD 26 V1\Backups Guardados\
#
# ============================================================

param(
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status,
    [switch]$Config
)

# ============================================================
# CONFIGURACION DE RUTAS
# ============================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModBaseDir = Split-Path -Parent $ScriptDir
$ConfigFile = Join-Path $ScriptDir "Gestor_Guardados_Config.json"
$LogFile = Join-Path $ScriptDir "Gestor_Guardados_Log.txt"

# CARPETA DE BACKUPS (donde guardamos copias de seguridad)
$BackupBaseDir = Join-Path $ModBaseDir "Backups Guardados"

# CARPETA NATIVA DEL JUEGO (donde FC26 guarda las partidas)
# Ubicacion principal: AppData\Local\EA SPORTS FC 26\settings
$APPDATA_LOCAL = "$env:LOCALAPPDATA"

# Nombres posibles de la carpeta del juego
$GAME_FOLDERS = @("EA SPORTS FC 26", "EA Sports FC 26", "FC 26")

# Identificacion de la PC
$PC_NAME = $env:COMPUTERNAME
if ([string]::IsNullOrEmpty($PC_NAME)) {
    $PC_NAME = "PC-UNKNOWN"
}

# ============================================================
# FUNCIONES
# ============================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logMessage
    Write-Host $logMessage
}

# Busca la CARPETA NATIVA donde FC26 guarda las partidas
function Find-GameSaveFolder {
    Write-Log "Buscando CARPETA NATIVA del juego (donde FC26 guarda las partidas)..."
    
    # UBICACION PRINCIPAL: AppData\Local\EA SPORTS FC 26\settings
    # Esta es la ubicacion NATIVA donde FC26 guarda las partidas
    foreach ($folder in $GAME_FOLDERS) {
        $path = Join-Path $APPDATA_LOCAL $folder
        $settingsPath = Join-Path $path "settings"
        if (Test-Path $settingsPath) {
            Write-Log "[OK] Encontrado en: $settingsPath" "SUCCESS"
            return $path
        }
    }
    
    Write-Log "[ERROR] No se encontro la carpeta nativa del juego" "ERROR"
    Write-Log "Ruta esperada: $APPDATA_LOCAL\EA SPORTS FC 26\settings" "ERROR"
    return $null
}

function Load-Config {
    if (Test-Path $ConfigFile) {
        try {
            $config = Get-Content $ConfigFile | ConvertFrom-Json
            return $config
        } catch {
            Write-Log "Error al cargar configuracion: $_" "ERROR"
        }
    }
    
    # Configuracion por defecto
    $defaultConfig = @{
        # CARPETA NATIVA: donde FC26 guarda las partidas
        GameSaveFolder = ""
        # CARPETA DE BACKUPS: donde guardamos copias de seguridad
        BackupFolder = $BackupBaseDir
        MonitorInterval = 5
        AutoBackup = $true
        # Archivos a respaldar
        FilePatterns = @("CmMgrC*", "Settings*", "Squads*", "overrideAutodetect.lua")
    }
    
    # Buscar carpeta nativa del juego
    $gameSaveFolder = Find-GameSaveFolder
    if ($gameSaveFolder) {
        $defaultConfig.GameSaveFolder = $gameSaveFolder
    }
    
    Save-Config $defaultConfig
    return $defaultConfig
}

function Save-Config {
    param($Config)
    try {
        $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigFile
        Write-Log "Configuracion guardada"
    } catch {
        Write-Log "Error al guardar configuracion: $_" "ERROR"
    }
}

# Crea un BACKUP (copia de seguridad) de los archivos del juego
function Create-Backup {
    param(
        [string]$GameSaveFolder,
        [string]$BackupFolder,
        [string]$PCName,
        [string[]]$ChangedFiles = @()
    )
    
    # Verificar carpeta nativa del juego
    $settingsFolder = Join-Path $GameSaveFolder "settings"
    if (-not (Test-Path $settingsFolder)) {
        Write-Log "[ERROR] Carpeta nativa del juego no existe: $settingsFolder" "ERROR"
        return $false
    }
    
    # Crear estructura: Backups Guardados\[PC]\[Fecha]\[Hora]
    $date = Get-Date
    $dateFolder = $date.ToString("yyyy-MM-dd")
    $timeFolder = $date.ToString("HH-mm-ss")
    
    $backupPath = Join-Path $BackupFolder $PCName
    $backupPath = Join-Path $backupPath $dateFolder
    $backupPath = Join-Path $backupPath $timeFolder
    
    try {
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
        Write-Log "Creando BACKUP en: $backupPath"
        
        if ($ChangedFiles.Count -gt 0) {
            Write-Log "Copiando archivos modificados: $($ChangedFiles -join ', ')"
            foreach ($file in $ChangedFiles) {
                $sourceFile = Join-Path $settingsFolder $file
                if (Test-Path $sourceFile) {
                    Copy-Item -Path $sourceFile -Destination $backupPath -Force
                    Write-Log "  [OK] Copiado: $file"
                }
            }
        } else {
            Write-Log "Copiando todos los archivos de partidas..."
            $config = Load-Config
            
            foreach ($pattern in $config.FilePatterns) {
                if ($pattern -eq "overrideAutodetect.lua") {
                    $sourceFile = Join-Path $settingsFolder $pattern
                    if (Test-Path $sourceFile) {
                        Copy-Item -Path $sourceFile -Destination $backupPath -Force
                        Write-Log "  [OK] Copiado: $pattern"
                    }
                } else {
                    $files = Get-ChildItem -Path $settingsFolder -Filter $pattern -File -ErrorAction SilentlyContinue
                    foreach ($file in $files) {
                        Copy-Item -Path $file.FullName -Destination $backupPath -Force
                        Write-Log "  [OK] Copiado: $($file.Name)"
                    }
                }
            }
        }
        
        # Crear archivo de informacion
        $infoFile = Join-Path $backupPath "_BACKUP_INFO.txt"
        $info = @"
BACKUP DE PARTIDAS FC26
=======================
Fecha y Hora: $($date.ToString("yyyy-MM-dd HH:mm:ss"))
PC de origen: $PCName

ORIGEN (Carpeta nativa del juego):
$settingsFolder

DESTINO (Este backup):
$backupPath

ARCHIVOS INCLUIDOS:
- CmMgrC* = Partidas de Modo Carrera
- Settings* = Configuraciones de perfil (persistentes)
- Squads* = Personajes creados (persistentes)
- overrideAutodetect.lua = Configuracion del juego
"@
        Set-Content -Path $infoFile -Value $info
        
        Write-Log "[OK] BACKUP creado exitosamente" "SUCCESS"
        return $true
    } catch {
        Write-Log "[ERROR] Error al crear backup: $_" "ERROR"
        return $false
    }
}

function Start-Monitoring {
    $config = Load-Config
    
    if ([string]::IsNullOrEmpty($config.GameSaveFolder)) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "  ERROR: NO HAY CONFIGURACION" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "No se ha configurado la carpeta nativa del juego."
        Write-Host "Ejecuta primero la opcion [1] Configurar rutas."
        Write-Host ""
        Write-Log "[ERROR] No se ha configurado la carpeta nativa del juego" "ERROR"
        Read-Host "Presiona Enter para continuar"
        return
    }
    
    $settingsFolder = Join-Path $config.GameSaveFolder "settings"
    if (-not (Test-Path $settingsFolder)) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "  ERROR: CARPETA NO ENCONTRADA" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "La carpeta de partidas no existe:"
        Write-Host "  $settingsFolder"
        Write-Host ""
        Write-Host "Verifica que FC26 este instalado correctamente."
        Write-Host ""
        Write-Log "[ERROR] La carpeta nativa del juego no existe: $settingsFolder" "ERROR"
        Read-Host "Presiona Enter para continuar"
        return
    }
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  MONITOREO ACTIVO"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "PC: $PC_NAME"
    Write-Host ""
    Write-Host "CARPETA NATIVA DEL JUEGO (origen):"
    Write-Host "  $settingsFolder"
    Write-Host ""
    Write-Host "CARPETA DE BACKUPS (destino):"
    Write-Host "  $($config.BackupFolder)"
    Write-Host ""
    Write-Host "PATRONES DE ARCHIVOS A MONITOREAR:"
    Write-Host "  - CmMgrC* (Modos Carrera)"
    Write-Host "  - Settings* (Configuraciones)"
    Write-Host "  - Squads* (Personajes creados)"
    Write-Host "  - overrideAutodetect.lua"
    Write-Host ""
    Write-Host "Presiona Ctrl+C para detener..."
    Write-Host "========================================"
    Write-Host ""
    
    Write-Log "Iniciando monitoreo de: $settingsFolder"
    
    # Usar archivo temporal para comunicar entre el evento y el loop principal
    $queueFile = Join-Path $ScriptDir "pending_files.tmp"
    if (Test-Path $queueFile) { Remove-Item $queueFile -Force }
    
    # Patrones de archivos
    $filePatterns = $config.FilePatterns
    $backupDelay = 5  # Segundos de espera antes de hacer backup
    
    # Crear FileSystemWatcher
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $settingsFolder
    $watcher.Filter = "*"
    $watcher.IncludeSubdirectories = $false
    $watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::CreationTime
    
    # Action que escribe a archivo temporal
    $action = {
        $file = $Event.SourceEventArgs.Name
        $changeType = $Event.SourceEventArgs.ChangeType
        $queuePath = $Event.MessageData.QueueFile
        $patterns = $Event.MessageData.Patterns
        $logPath = $Event.MessageData.LogFile
        
        # EXCLUIR archivos del sistema de backup y temporales
        if ($file -like "_*" -or $file -like "*.tmp" -or $file -like "*.temp" -or $file -like "pending_*") {
            return
        }
        
        # Verificar si el archivo coincide con los patrones
        $isSaveFile = $false
        foreach ($pattern in $patterns) {
            if ($pattern -eq "overrideAutodetect.lua") {
                if ($file -eq $pattern) { $isSaveFile = $true; break }
            } else {
                if ($file -like $pattern) { $isSaveFile = $true; break }
            }
        }
        
        if ($isSaveFile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logMsg = "[$timestamp] [INFO] Archivo detectado: $file ($changeType)"
            Add-Content -Path $logPath -Value $logMsg
            Write-Host $logMsg
            
            # Escribir al archivo de cola
            $entry = "$file|$(Get-Date -Format 'o')"
            Add-Content -Path $queuePath -Value $entry
        }
    }
    
    # Datos para pasar al action
    $messageData = @{
        QueueFile = $queueFile
        Patterns = $filePatterns
        LogFile = $LogFile
    }
    
    Register-ObjectEvent -InputObject $watcher -EventName "Created" -Action $action -MessageData $messageData | Out-Null
    Register-ObjectEvent -InputObject $watcher -EventName "Changed" -Action $action -MessageData $messageData | Out-Null
    
    $watcher.EnableRaisingEvents = $true
    
    # Tabla de archivos pendientes
    $pendingFiles = @{}
    
    try {
        while ($true) {
            Start-Sleep -Seconds 2
            
            # Leer archivos pendientes del archivo de cola
            if (Test-Path $queueFile) {
                $lines = Get-Content $queueFile -ErrorAction SilentlyContinue
                # Limpiar archivo de cola
                Remove-Item $queueFile -Force -ErrorAction SilentlyContinue
                
                foreach ($line in $lines) {
                    if (-not [string]::IsNullOrWhiteSpace($line)) {
                        $parts = $line -split '\|'
                        if ($parts.Count -ge 2) {
                            $fileName = $parts[0]
                            try {
                                $fileTime = [DateTime]::Parse($parts[1])
                                $pendingFiles[$fileName] = $fileTime
                            } catch {
                                $pendingFiles[$fileName] = Get-Date
                            }
                        }
                    }
                }
            }
            
            # Verificar si hay archivos listos para backup
            $now = Get-Date
            $filesToBackup = @()
            $keysToRemove = @()
            
            foreach ($file in $pendingFiles.Keys) {
                $fileTime = $pendingFiles[$file]
                $elapsed = ($now - $fileTime).TotalSeconds
                
                if ($elapsed -ge $backupDelay) {
                    $filesToBackup += $file
                    $keysToRemove += $file
                }
            }
            
            # Remover archivos procesados
            foreach ($key in $keysToRemove) {
                $pendingFiles.Remove($key)
            }
            
            # Crear backup si hay archivos
            if ($filesToBackup.Count -gt 0) {
                Write-Host ""
                Write-Log "========================================" 
                Write-Log "CREANDO BACKUP DE $($filesToBackup.Count) ARCHIVO(S)..."
                Write-Log "Archivos: $($filesToBackup -join ', ')"
                
                $currentConfig = Load-Config
                $result = Create-Backup -GameSaveFolder $currentConfig.GameSaveFolder -BackupFolder $currentConfig.BackupFolder -PCName $PC_NAME -ChangedFiles $filesToBackup
                
                if ($result) {
                    Write-Host ""
                    Write-Host "[OK] BACKUP CREADO EXITOSAMENTE!" -ForegroundColor Green
                    Write-Host ""
                } else {
                    Write-Host ""
                    Write-Host "[ERROR] Fallo al crear backup" -ForegroundColor Red
                    Write-Host ""
                }
                Write-Log "========================================"
                Write-Host ""
            }
        }
    } finally {
        $watcher.EnableRaisingEvents = $false
        $watcher.Dispose()
        Get-EventSubscriber | Unregister-Event -ErrorAction SilentlyContinue
        if (Test-Path $queueFile) { Remove-Item $queueFile -Force -ErrorAction SilentlyContinue }
        Write-Log "Monitoreo detenido"
    }
}

function Set-Configuration {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  CONFIGURACION DEL GESTOR DE BACKUPS"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "Este sistema necesita conocer dos carpetas:"
    Write-Host ""
    Write-Host "1. CARPETA NATIVA DEL JUEGO"
    Write-Host "   Donde FC26 guarda las partidas de forma nativa"
    Write-Host "   Ubicacion esperada: AppData\Local\EA SPORTS FC 26\settings"
    Write-Host ""
    Write-Host "2. CARPETA DE BACKUPS"
    Write-Host "   Donde este sistema guardara copias de seguridad"
    Write-Host "   Ubicacion: LTA MOD 26 V1\Backups Guardados\"
    Write-Host ""
    Write-Host "========================================"
    Write-Host ""
    
    $config = Load-Config
    
    # Buscar carpeta nativa del juego
    if ([string]::IsNullOrEmpty($config.GameSaveFolder) -or -not (Test-Path $config.GameSaveFolder)) {
        Write-Host "Buscando CARPETA NATIVA del juego..."
        Write-Host ""
        
        $gameSaveFolder = Find-GameSaveFolder
        
        if ($gameSaveFolder) {
            $config.GameSaveFolder = $gameSaveFolder
            Write-Host ""
            Write-Host "[OK] Carpeta nativa encontrada!" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "[!] No se encontro automaticamente." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "La carpeta nativa de FC26 normalmente esta en:"
            Write-Host "  C:\Users\TuUsuario\AppData\Local\EA SPORTS FC 26"
            Write-Host ""
            Write-Host "Ingresa la ruta manualmente (sin \settings al final):"
            $manualPath = Read-Host "Ruta"
            
            $settingsPath = Join-Path $manualPath "settings"
            if (Test-Path $settingsPath) {
                $config.GameSaveFolder = $manualPath
                Write-Host "[OK] Carpeta configurada correctamente" -ForegroundColor Green
            } else {
                Write-Host ""
                Write-Host "[ERROR] No se encontro la subcarpeta 'settings' en esa ruta" -ForegroundColor Red
                Write-Host ""
                Read-Host "Presiona Enter para continuar"
                return
            }
        }
    }
    
    # Configurar carpeta de backups
    $config.BackupFolder = $BackupBaseDir
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  CONFIGURACION COMPLETADA"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "CARPETA NATIVA DEL JUEGO (origen):"
    Write-Host "  $($config.GameSaveFolder)\settings" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "CARPETA DE BACKUPS (destino):"
    Write-Host "  $($config.BackupFolder)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "PC: $PC_NAME"
    Write-Host ""
    
    Save-Config $config
    Write-Host "[OK] Configuracion guardada!" -ForegroundColor Green
    Write-Host ""
}

function Show-Status {
    $config = Load-Config
    
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  ESTADO DEL GESTOR DE BACKUPS"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "PC: $PC_NAME"
    Write-Host ""
    Write-Host "CARPETA NATIVA DEL JUEGO (origen):"
    if (-not [string]::IsNullOrEmpty($config.GameSaveFolder)) {
        $settingsPath = Join-Path $config.GameSaveFolder "settings"
        if (Test-Path $settingsPath) {
            Write-Host "  $settingsPath" -ForegroundColor Green
            Write-Host "  [OK] Existe" -ForegroundColor Green
        } else {
            Write-Host "  $settingsPath" -ForegroundColor Red
            Write-Host "  [ERROR] No existe" -ForegroundColor Red
        }
    } else {
        Write-Host "  [!] No configurada" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "CARPETA DE BACKUPS (destino):"
    Write-Host "  $($config.BackupFolder)"
    
    if (Test-Path $config.BackupFolder) {
        $backups = Get-ChildItem -Path $config.BackupFolder -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d{2}-\d{2}-\d{2}$" }
        Write-Host ""
        Write-Host "Backups encontrados: $($backups.Count)"
        
        $recentBackups = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 5
        if ($recentBackups.Count -gt 0) {
            Write-Host ""
            Write-Host "Ultimos 5 backups:"
            foreach ($backup in $recentBackups) {
                Write-Host "  - $($backup.FullName)"
            }
        }
    } else {
        Write-Host "  [!] No hay backups creados aun" -ForegroundColor Yellow
    }
    Write-Host ""
}

# ============================================================
# MENU PRINCIPAL
# ============================================================

if ($Config) {
    Set-Configuration
} elseif ($Status) {
    Show-Status
} elseif ($Start) {
    Start-Monitoring
} else {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  GESTOR AUTOMATICO DE BACKUPS FC26"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "DEFINICIONES:"
    Write-Host "  - CARPETA NATIVA: Donde FC26 guarda las partidas"
    Write-Host "    (AppData\Local\EA SPORTS FC 26\settings)"
    Write-Host ""
    Write-Host "  - CARPETA DE BACKUPS: Donde guardamos copias"
    Write-Host "    (LTA MOD 26 V1\Backups Guardados\)"
    Write-Host ""
    Write-Host "USO:"
    Write-Host "  .\Gestor_Guardados_FC26.ps1 -Config  : Configurar rutas"
    Write-Host "  .\Gestor_Guardados_FC26.ps1 -Start   : Iniciar monitoreo"
    Write-Host "  .\Gestor_Guardados_FC26.ps1 -Status  : Ver estado"
    Write-Host ""
    Write-Host "PASOS:"
    Write-Host "  1. Primero ejecuta -Config para configurar"
    Write-Host "  2. Luego ejecuta -Start para monitorear"
    Write-Host ""
}
