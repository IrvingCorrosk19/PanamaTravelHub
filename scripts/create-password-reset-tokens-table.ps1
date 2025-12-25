# Script PowerShell para crear la tabla password_reset_tokens en Render PostgreSQL
# Ejecutar desde la raíz del proyecto

$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$host = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$user = "panamatravelhub_user"
$database = "panamatravelhub"
$scriptPath = "src\PanamaTravelHub.Infrastructure\Migrations\AddPasswordResetTokens.sql"

Write-Host "Conectando a Render PostgreSQL..." -ForegroundColor Cyan
Write-Host ""

& $psqlPath -h $host -U $user -d $database -f $scriptPath

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Tabla password_reset_tokens creada exitosamente!" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host "Error al ejecutar el script SQL" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Red
}

Read-Host "Presiona Enter para continuar"
