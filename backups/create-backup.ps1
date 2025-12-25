# Script para crear backup de la base de datos PanamaTravelHub
# Uso: .\create-backup.ps1

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "PanamaTravelHub_backup_$timestamp.sql"
$backupPath = Join-Path $PSScriptRoot $backupFile

Write-Host "=== Creando Backup de Base de Datos ===" -ForegroundColor Cyan
Write-Host "Base de datos: PanamaTravelHub" -ForegroundColor Yellow
Write-Host "Archivo: $backupFile" -ForegroundColor Yellow
Write-Host ""

# Configurar contraseña
$env:PGPASSWORD = "Panama2020$"

# Ejecutar pg_dump
try {
    pg_dump -h localhost -U postgres -d PanamaTravelHub -F p --clean --if-exists -f $backupPath
    
    if ($LASTEXITCODE -eq 0) {
        $fileInfo = Get-Item $backupPath
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        
        Write-Host ""
        Write-Host "✅ Backup creado exitosamente!" -ForegroundColor Green
        Write-Host "Archivo: $backupFile" -ForegroundColor White
        Write-Host "Tamaño: $fileSizeMB MB" -ForegroundColor White
        Write-Host "Ubicación: $backupPath" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Error al crear backup (Código: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "Verifica que PostgreSQL esté instalado y que pg_dump esté en el PATH" -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "Verifica que PostgreSQL esté instalado correctamente" -ForegroundColor Yellow
}

# Limpiar variable de entorno
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

