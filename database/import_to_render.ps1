# ============================================
# Script PowerShell para Importar Datos a Render
# ============================================

$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$importPath = Join-Path $PSScriptRoot "export_business_data.sql"

# Credenciales de Render
$renderHost = "dpg-d5efvg7pm1nc73a63qqg-a.virginia-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub_2juu"
$renderUser = "panamatravelhub_2juu_user"
$renderPassword = "BhC1OtUf9WBxSKUrWksobwH8jwNYAmKT"

# Construir cadena de conexión
$connectionString = "Host=$renderHost;Port=$renderPort;Database=$renderDatabase;Username=$renderUser;Password=$renderPassword;SSL Mode=Require;Trust Server Certificate=true"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Importando Datos a Render" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Archivo: $importPath" -ForegroundColor Yellow
Write-Host "Base de datos: $renderDatabase" -ForegroundColor Yellow
Write-Host ""

# Verificar que el archivo existe
if (-not (Test-Path $importPath)) {
    Write-Host "ERROR: No se encuentra el archivo $importPath" -ForegroundColor Red
    Write-Host "Primero ejecuta export_localhost_data.ps1" -ForegroundColor Yellow
    exit 1
}

$fileSize = (Get-Item $importPath).Length / 1MB
Write-Host "Tamaño del archivo: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
Write-Host ""

# Confirmar antes de importar
$confirm = Read-Host "¿Deseas continuar con la importación? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s" -and $confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Importación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Importando datos..." -ForegroundColor Green
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    & $psqlPath $connectionString -f $importPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "Importación completada exitosamente!" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Siguiente paso: Verificar datos con verify_sync.ps1" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "ERROR: La importación falló con código $LASTEXITCODE" -ForegroundColor Red
        Write-Host "Revisa los errores arriba para más detalles." -ForegroundColor Yellow
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

