# Script para crear migraciones de Entity Framework Core
param(
    [Parameter(Mandatory=$true)]
    [string]$MigrationName
)

Write-Host "Creando migración: $MigrationName" -ForegroundColor Green

dotnet ef migrations add $MigrationName `
    --project src/PanamaTravelHub.Infrastructure `
    --startup-project src/PanamaTravelHub.API `
    --output-dir Migrations

if ($LASTEXITCODE -eq 0) {
    Write-Host "Migración creada exitosamente!" -ForegroundColor Green
} else {
    Write-Host "Error al crear la migración" -ForegroundColor Red
    exit 1
}
