# Script para cargar backup local a Render PostgreSQL
# Uso: .\load-to-render.ps1

$backupFile = "PanamaTravelHub_backup_20251225_105337.sql"
$backupPath = Join-Path $PSScriptRoot $backupFile

# Datos de conexión a Render
$renderHost = "dpg-d5efvg7pm1nc73a63qqg-a.virginia-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub_2juu"
$renderUser = "panamatravelhub_2juu_user"
$renderPassword = "BhC1OtUf9WBxSKUrWksobwH8jwNYAmKT"

Write-Host "=== Cargar Backup a Render ===" -ForegroundColor Cyan
Write-Host "Archivo: $backupFile" -ForegroundColor Yellow
Write-Host "Destino: Render PostgreSQL" -ForegroundColor Yellow
Write-Host "Host: $renderHost" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  ADVERTENCIA: Esto reemplazará TODOS los datos en Render con los datos locales." -ForegroundColor Red
Write-Host "⚠️  Esto es irreversible." -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "¿Estás seguro que quieres continuar? (escribe 'SI' para confirmar)"
if ($confirm -ne "SI") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit
}

# Buscar psql.exe
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlPath) {
    $psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
    if (-not (Test-Path $psqlPath)) {
        $psqlPath = "C:\Program Files\PostgreSQL\16\bin\psql.exe"
        if (-not (Test-Path $psqlPath)) {
            $psqlPath = "C:\Program Files\PostgreSQL\15\bin\psql.exe"
            if (-not (Test-Path $psqlPath)) {
                $psqlPath = Get-ChildItem "C:\Program Files\PostgreSQL" -Recurse -Filter "psql.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
            }
        }
    }
}

if (-not $psqlPath -or -not (Test-Path $psqlPath)) {
    Write-Host "❌ No se encontró psql.exe. Instala PostgreSQL o agrégalo al PATH." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $backupPath)) {
    Write-Host "❌ No se encontró el archivo de backup: $backupPath" -ForegroundColor Red
    exit 1
}

Write-Host "`nUsando: $psqlPath" -ForegroundColor Gray
Write-Host "Cargando backup..." -ForegroundColor Yellow
Write-Host ""

# Configurar contraseña
$env:PGPASSWORD = $renderPassword

# Ejecutar psql con el archivo SQL
try {
    # Ejecutar el script SQL contra Render
    Get-Content $backupPath | & $psqlPath `
        -h $renderHost `
        -p $renderPort `
        -U $renderUser `
        -d $renderDatabase `
        --set=sslmode=require
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Backup cargado exitosamente a Render!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Error al cargar backup (Código: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "Revisa los mensajes de error arriba." -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

# Limpiar variable de entorno
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

