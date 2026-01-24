# Script para corregir la BD y luego probar el flujo completo
$ErrorActionPreference = 'Continue'

Write-Host "=== CORRECCION DE BASE DE DATOS Y PRUEBA ===" -ForegroundColor Cyan
Write-Host ""

# Verificar si psql está disponible
$psqlPath = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlPath) {
    Write-Host "psql no encontrado en PATH." -ForegroundColor Yellow
    Write-Host "Opciones:" -ForegroundColor Yellow
    Write-Host "1. Instalar PostgreSQL y agregar a PATH" -ForegroundColor Gray
    Write-Host "2. Ejecutar manualmente:" -ForegroundColor Gray
    Write-Host "   psql -h localhost -U postgres -d PanamaTravelHub -f database\fix_missing_tour_columns.sql" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. O usar pgAdmin/DBeaver para ejecutar el SQL" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "Ejecutando fix_missing_tour_columns.sql..." -ForegroundColor Yellow
    $env:PGPASSWORD = 'Panama2020$'
    try {
        $output = & psql -h localhost -p 5432 -U postgres -d PanamaTravelHub -f database\fix_missing_tour_columns.sql 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Base de datos corregida exitosamente" -ForegroundColor Green
        } else {
            Write-Host "  Error al ejecutar SQL. Verifica la conexion." -ForegroundColor Red
            Write-Host $output -ForegroundColor Gray
        }
    } catch {
        Write-Host "  Error: $_" -ForegroundColor Red
    }
    $env:PGPASSWORD = $null
}

Write-Host ""
Write-Host "Ejecutando pruebas del flujo..." -ForegroundColor Yellow
Write-Host ""
& "$PSScriptRoot\test-frontend-flow.ps1"
