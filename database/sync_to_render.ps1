# ============================================
# Script PowerShell para Sincronizar Render
# ============================================

$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$scriptPath = Join-Path $PSScriptRoot "12_sync_render_database.sql"

# Credenciales de Render
$renderHost = "dpg-d5efvg7pm1nc73a63qqg-a.virginia-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub_2juu"
$renderUser = "panamatravelhub_2juu_user"
$renderPassword = "BhC1OtUf9WBxSKUrWksobwH8jwNYAmKT"

# Construir cadena de conexión
$connectionString = "Host=$renderHost;Port=$renderPort;Database=$renderDatabase;Username=$renderUser;Password=$renderPassword;SSL Mode=Require;Trust Server Certificate=true"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Sincronizando Esquema de Render" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Script: $scriptPath" -ForegroundColor Yellow
Write-Host "Base de datos: $renderDatabase" -ForegroundColor Yellow
Write-Host ""

# Verificar que el script existe
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: No se encuentra el script $scriptPath" -ForegroundColor Red
    exit 1
}

# Ejecutar script
Write-Host "Ejecutando script de sincronización..." -ForegroundColor Green
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    & $psqlPath $connectionString -f $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "Sincronización completada exitosamente!" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "ERROR: La sincronización falló con código $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

