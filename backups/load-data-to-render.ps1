# Script para cargar solo datos a Render (sin esquema)
# Primero limpia las tablas y luego inserta los datos

$dataBackupFile = "PanamaTravelHub_data_only_20251225_105613.sql"
$dataBackupPath = Join-Path $PSScriptRoot $dataBackupFile

# Datos de conexión a Render
$renderHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub"
$renderUser = "panamatravelhub_user"
$renderPassword = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"

Write-Host "=== Cargar Datos a Render ===" -ForegroundColor Cyan
Write-Host "Archivo: $dataBackupFile" -ForegroundColor Yellow
Write-Host "Destino: Render PostgreSQL" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  ADVERTENCIA: Esto eliminará TODOS los datos existentes en Render y los reemplazará con los datos locales." -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "¿Estás seguro que quieres continuar? (escribe 'SI' para confirmar)"
if ($confirm -ne "SI") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit
}

# Buscar psql.exe
$psqlPath = Get-ChildItem "C:\Program Files\PostgreSQL" -Recurse -Filter "psql.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if (-not $psqlPath) {
    $psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
    if (-not (Test-Path $psqlPath)) {
        $psqlPath = Get-ChildItem "C:\Program Files\PostgreSQL" -Recurse -Filter "psql.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    }
}

if (-not $psqlPath -or -not (Test-Path $psqlPath)) {
    Write-Host "❌ No se encontró psql.exe." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dataBackupPath)) {
    Write-Host "❌ No se encontró el archivo: $dataBackupPath" -ForegroundColor Red
    exit 1
}

Write-Host "`nUsando: $psqlPath" -ForegroundColor Gray
$env:PGPASSWORD = $renderPassword

# Script SQL para limpiar las tablas (TRUNCATE CASCADE elimina los datos respetando las foreign keys)
$truncateScript = @"
SET session_replication_role = 'replica';
TRUNCATE TABLE booking_participants CASCADE;
TRUNCATE TABLE payments CASCADE;
TRUNCATE TABLE bookings CASCADE;
TRUNCATE TABLE tour_dates CASCADE;
TRUNCATE TABLE tour_images CASCADE;
TRUNCATE TABLE tours CASCADE;
TRUNCATE TABLE pages CASCADE;
TRUNCATE TABLE media_files CASCADE;
TRUNCATE TABLE email_notifications CASCADE;
TRUNCATE TABLE sms_notifications CASCADE;
TRUNCATE TABLE audit_logs CASCADE;
TRUNCATE TABLE refresh_tokens CASCADE;
TRUNCATE TABLE password_reset_tokens CASCADE;
TRUNCATE TABLE user_roles CASCADE;
TRUNCATE TABLE users CASCADE;
TRUNCATE TABLE home_page_content CASCADE;
SET session_replication_role = 'origin';
"@

Write-Host "Limpiando tablas en Render..." -ForegroundColor Yellow
try {
    $truncateScript | & $psqlPath `
        -h $renderHost `
        -p $renderPort `
        -U $renderUser `
        -d $renderDatabase `
        --set=sslmode=require
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️  Advertencia al limpiar tablas (Código: $LASTEXITCODE)" -ForegroundColor Yellow
        Write-Host "Continuando con la carga de datos..." -ForegroundColor Yellow
    } else {
        Write-Host "✅ Tablas limpiadas exitosamente" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠️  Error al limpiar: $_" -ForegroundColor Yellow
    Write-Host "Continuando con la carga de datos..." -ForegroundColor Yellow
}

Write-Host "`nCargando datos..." -ForegroundColor Yellow
try {
    Get-Content $dataBackupPath | & $psqlPath `
        -h $renderHost `
        -p $renderPort `
        -U $renderUser `
        -d $renderDatabase `
        --set=sslmode=require
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Datos cargados exitosamente a Render!" -ForegroundColor Green
    } else {
        Write-Host "`n❌ Error al cargar datos (Código: $LASTEXITCODE)" -ForegroundColor Red
    }
} catch {
    Write-Host "`n❌ Error: $_" -ForegroundColor Red
}

Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

