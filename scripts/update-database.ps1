# Script para aplicar migraciones a la base de datos
param(
    [string]$MigrationName = ""
)

if ($MigrationName -eq "") {
    Write-Host "Aplicando todas las migraciones pendientes..." -ForegroundColor Green
    dotnet ef database update `
        --project src/PanamaTravelHub.Infrastructure `
        --startup-project src/PanamaTravelHub.API
} else {
    Write-Host "Aplicando migración hasta: $MigrationName" -ForegroundColor Green
    dotnet ef database update $MigrationName `
        --project src/PanamaTravelHub.Infrastructure `
        --startup-project src/PanamaTravelHub.API
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Base de datos actualizada exitosamente!" -ForegroundColor Green
} else {
    Write-Host "Error al actualizar la base de datos" -ForegroundColor Red
    exit 1
}
