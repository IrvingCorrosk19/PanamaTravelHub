# ============================================
# Script PowerShell: Copiar DB Local a Render (Nueva Instancia)
# ============================================
# Este script crea un backup completo de la DB local
# y lo restaura en la nueva instancia de Render
# ============================================

$ErrorActionPreference = "Stop"

# Configuración de PostgreSQL
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$pgDumpPath = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"

# Configuración LOCAL
$localHost = "localhost"
$localPort = "5432"
$localDatabase = "PanamaTravelHub"
$localUser = "postgres"
$localPassword = "Panama2020$"

# Configuración RENDER (Nueva Instancia)
$renderHost = "dpg-d5efvg7pm1nc73a63qqg-a.virginia-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub_2juu"
$renderUser = "panamatravelhub_2juu_user"
$renderPassword = "BhC1OtUf9WBxSKUrWksobwH8jwNYAmKT"

# Archivo de backup temporal
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "PanamaTravelHub_backup_$timestamp.sql"
$backupPath = Join-Path $PSScriptRoot $backupFile

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "COPIA COMPLETA: Local -> Render (Nueva DB)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Origen:" -ForegroundColor Yellow
Write-Host "  Host: $localHost" -ForegroundColor Gray
Write-Host "  Database: $localDatabase" -ForegroundColor Gray
Write-Host ""
Write-Host "Destino:" -ForegroundColor Yellow
Write-Host "  Host: $renderHost" -ForegroundColor Gray
Write-Host "  Database: $renderDatabase" -ForegroundColor Gray
Write-Host ""
Write-Host "[ADVERTENCIA] Esto reemplazara TODOS los datos en Render." -ForegroundColor Red
Write-Host "[ADVERTENCIA] Esto es irreversible." -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "¿Estás seguro que quieres continuar? (escribe 'SI' para confirmar)"
if ($confirm -ne "SI") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Verificar que las herramientas de PostgreSQL existan
if (-not (Test-Path $psqlPath)) {
    Write-Host "ERROR: No se encuentra psql.exe en: $psqlPath" -ForegroundColor Red
    Write-Host "Verifica que PostgreSQL 18 esté instalado" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $pgDumpPath)) {
    Write-Host "ERROR: No se encuentra pg_dump.exe en: $pgDumpPath" -ForegroundColor Red
    Write-Host "Verifica que PostgreSQL 18 esté instalado" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Herramientas de PostgreSQL encontradas" -ForegroundColor Green
Write-Host ""

# PASO 1: Crear backup completo de la DB local
Write-Host "PASO 1: Creando backup completo de la base de datos local..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $localPassword
    
    & $pgDumpPath `
        -h $localHost `
        -p $localPort `
        -U $localUser `
        -d $localDatabase `
        -F p `
        --clean `
        --if-exists `
        --no-owner `
        --no-privileges `
        -f $backupPath `
        2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        throw "Error al crear backup (código: $LASTEXITCODE)"
    }
    
    $fileInfo = Get-Item $backupPath
    $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
    
    Write-Host "[OK] Backup creado exitosamente" -ForegroundColor Green
    Write-Host "  Archivo: $backupFile" -ForegroundColor Gray
    Write-Host "  Tamano: $fileSizeMB MB" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-Host "ERROR al crear backup: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# PASO 2: Verificar conexión con Render
Write-Host "PASO 2: Verificando conexión con Render..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    
    $testQuery = "SELECT version();"
    $result = & $psqlPath `
        -h $renderHost `
        -p $renderPort `
        -U $renderUser `
        -d $renderDatabase `
        -c $testQuery `
        --set=sslmode=require `
        2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Conexion con Render establecida correctamente" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "[ADVERTENCIA] Hubo problemas al verificar conexion" -ForegroundColor Yellow
        Write-Host "Continuando de todas formas..." -ForegroundColor Yellow
        Write-Host ""
    }
} catch {
    Write-Host "[ADVERTENCIA] No se pudo verificar conexion: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Continuando de todas formas..." -ForegroundColor Yellow
    Write-Host ""
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# PASO 3: Restaurar backup en Render
Write-Host "PASO 3: Restaurando backup en Render..." -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos dependiendo del tamaño de la base de datos..." -ForegroundColor Cyan
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    
    # Leer el backup y restaurarlo en Render
    # Usamos Get-Content para evitar problemas con archivos grandes
    Get-Content $backupPath -Raw | & $psqlPath `
        -h $renderHost `
        -p $renderPort `
        -U $renderUser `
        -d $renderDatabase `
        --set=sslmode=require `
        2>&1 | ForEach-Object {
            # Filtrar mensajes según su tipo
            if ($_ -match "ERROR|error") {
                Write-Host $_ -ForegroundColor Red
            } elseif ($_ -match "NOTICE|notice|already exists|does not exist") {
                # Ignorar notices comunes que son normales
                if ($_ -match "already exists|does not exist") {
                    Write-Host $_ -ForegroundColor DarkGray
                } else {
                    Write-Host $_ -ForegroundColor Cyan
                }
            } elseif ($_ -match "COPY|INSERT|CREATE|ALTER|DROP") {
                Write-Host $_ -ForegroundColor Green
            } else {
                Write-Host $_
            }
        }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[OK] Backup restaurado exitosamente en Render" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "[ADVERTENCIA] El proceso completo con codigo $LASTEXITCODE" -ForegroundColor Yellow
        Write-Host "Algunos errores pueden ser normales (objetos ya existentes)" -ForegroundColor Yellow
        Write-Host ""
    }
    
} catch {
    Write-Host ""
    Write-Host "ERROR al restaurar backup: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# PASO 4: Verificar datos en Render
Write-Host "PASO 4: Verificando datos en Render..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    
    Write-Host "Conteos en RENDER:" -ForegroundColor Cyan
    
    # Verificar algunas tablas principales
    $tables = @("tours", "bookings", "users", "countries", "destinations")
    
    foreach ($table in $tables) {
        $query = "SELECT COUNT(*) as count FROM $table;"
        $result = & $psqlPath `
            -h $renderHost `
            -p $renderPort `
            -U $renderUser `
            -d $renderDatabase `
            -c $query `
            --set=sslmode=require `
            --tuples-only `
            2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $count = ($result | Where-Object { $_ -match "^\s*\d+\s*$" }) -replace '\s', ''
            if ($count) {
                Write-Host "  $table : $count registros" -ForegroundColor Green
            }
        }
    }
    
    Write-Host ""
    
} catch {
    Write-Host "[ADVERTENCIA] No se pudo verificar datos (no critico): $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ""
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

# Resumen final
Write-Host "============================================" -ForegroundColor Green
Write-Host "COPIA COMPLETA FINALIZADA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Backup guardado en: $backupPath" -ForegroundColor Cyan
Write-Host "Puedes conservarlo como respaldo o eliminarlo despues de verificar." -ForegroundColor Cyan
Write-Host ""
Write-Host "Base de datos Render:" -ForegroundColor Cyan
Write-Host "  Host: $renderHost" -ForegroundColor Gray
Write-Host "  Database: $renderDatabase" -ForegroundColor Gray
Write-Host ""
Write-Host "Para conectarte manualmente:" -ForegroundColor Cyan
Write-Host "  PGPASSWORD=$renderPassword psql -h $renderHost -U $renderUser -d $renderDatabase" -ForegroundColor Gray
Write-Host ""

