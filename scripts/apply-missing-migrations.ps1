# Script para aplicar las migraciones faltantes en la base de datos
# Uso: .\scripts\apply-missing-migrations.ps1

$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$dbHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$dbUser = "panamatravelhub_user"
$dbName = "panamatravelhub"

$scripts = @(
    @{
        File = "database/08_add_logo_fields.sql"
        Description = "Agregar campos de logo a home_page_content"
    },
    @{
        File = "database/09_add_countries_and_country_to_bookings.sql"
        Description = "Crear tabla countries y agregar country_id a bookings"
    },
    @{
        File = "database/10_create_sms_notifications_table.sql"
        Description = "Crear tabla sms_notifications"
    }
)

Write-Host "`n=== APLICANDO MIGRACIONES FALTANTES ===" -ForegroundColor Cyan
Write-Host ""

foreach ($script in $scripts) {
    if (Test-Path $script.File) {
        Write-Host "Ejecutando: $($script.Description)..." -ForegroundColor Yellow
        Write-Host "  Archivo: $($script.File)" -ForegroundColor Gray
        
        $result = & $psqlPath -h $dbHost -U $dbUser -d $dbName -f $script.File 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  OK - Ejecutado correctamente" -ForegroundColor Green
        } else {
            Write-Host "  ERROR - Hubo problemas" -ForegroundColor Red
            $result | Select-String -Pattern "ERROR" | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        }
        Write-Host ""
    } else {
        Write-Host "  ADVERTENCIA: No se encuentra el archivo $($script.File)" -ForegroundColor Yellow
        Write-Host ""
    }
}

Write-Host "=== VERIFICANDO RESULTADO ===" -ForegroundColor Cyan
& $psqlPath -h $dbHost -U $dbUser -d $dbName -f scripts/verify-db-simple.sql

Write-Host "`n=== COMPLETADO ===" -ForegroundColor Green

