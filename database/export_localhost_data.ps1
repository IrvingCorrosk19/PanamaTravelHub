# ============================================
# Script PowerShell para Exportar Datos de Localhost
# ============================================

$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$pgDumpPath = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"
$exportPath = Join-Path $PSScriptRoot "export_business_data.sql"

# Credenciales de Localhost
$localhostHost = "localhost"
$localhostPort = "5432"
$localhostDatabase = "PanamaTravelHub"
$localhostUser = "postgres"
$localhostPassword = "Panama2020$"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Exportando Datos desde Localhost" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Base de datos: $localhostDatabase" -ForegroundColor Yellow
Write-Host "Archivo de salida: $exportPath" -ForegroundColor Yellow
Write-Host ""

# Verificar que pg_dump existe
if (-not (Test-Path $pgDumpPath)) {
    Write-Host "ERROR: No se encuentra pg_dump en $pgDumpPath" -ForegroundColor Red
    exit 1
}

# Tablas a exportar
$tables = @(
    "tours",
    "tour_images",
    "tour_dates",
    "bookings",
    "booking_participants",
    "payments",
    "email_notifications",
    "sms_notifications",
    "home_page_content",
    "media_files",
    "pages"
)

Write-Host "Tablas a exportar:" -ForegroundColor Green
foreach ($table in $tables) {
    Write-Host "  - $table" -ForegroundColor Gray
}
Write-Host ""

# Construir comando pg_dump
$tableArgs = $tables | ForEach-Object { "--table=$_" }
$dumpCommand = @(
    "-h", $localhostHost,
    "-p", $localhostPort,
    "-U", $localhostUser,
    "-d", $localhostDatabase,
    "--data-only",
    "--no-owner",
    "--no-privileges"
) + $tableArgs + @(
    "-f", $exportPath
)

try {
    $env:PGPASSWORD = $localhostPassword
    Write-Host "Exportando datos..." -ForegroundColor Green
    Write-Host ""
    
    & $pgDumpPath $dumpCommand
    
    if ($LASTEXITCODE -eq 0) {
        $fileSize = (Get-Item $exportPath).Length / 1MB
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "Exportación completada exitosamente!" -ForegroundColor Green
        Write-Host "Archivo: $exportPath" -ForegroundColor Green
        Write-Host "Tamaño: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Siguiente paso: Ejecutar import_to_render.ps1" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "ERROR: La exportación falló con código $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

