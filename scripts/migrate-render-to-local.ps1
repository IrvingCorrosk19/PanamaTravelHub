# Script completo para migrar la BD de Render a local
# Uso: .\scripts\migrate-render-to-local.ps1

Write-Host "=== MIGRACIÓN DE BASE DE DATOS: RENDER → LOCAL ===" -ForegroundColor Cyan
Write-Host ""

# Paso 1: Exportar de Render
Write-Host "PASO 1: Exportando base de datos de Render..." -ForegroundColor Yellow
Write-Host ""
$dumpFile = .\scripts\export-render-db.ps1

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Error en la exportación. Abortando migración." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Gray
Write-Host ""

# Paso 2: Importar a local
Write-Host "PASO 2: Importando a base de datos local..." -ForegroundColor Yellow
Write-Host ""
.\scripts\import-to-local-db.ps1 -dumpFile $dumpFile

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Error en la importación." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Gray
Write-Host ""
Write-Host "✅ MIGRACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Actualizar appsettings.Development.json con la cadena de conexión local" -ForegroundColor White
Write-Host "2. Verificar que la aplicación funcione correctamente" -ForegroundColor White

