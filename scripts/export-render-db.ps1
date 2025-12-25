# Script para exportar la base de datos de Render a un archivo SQL
# Uso: .\scripts\export-render-db.ps1

$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
$pgDumpPath = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"
$dbHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$dbUser = "panamatravelhub_user"
$dbName = "panamatravelhub"
$outputFile = "database/render-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql"

Write-Host "=== Exportando base de datos de Render ===" -ForegroundColor Cyan
Write-Host ""

# Crear directorio database si no existe
if (-not (Test-Path "database")) {
    New-Item -ItemType Directory -Path "database" | Out-Null
}

Write-Host "Exportando a: $outputFile" -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos..." -ForegroundColor Yellow

try {
    # Usar pg_dump en lugar de psql para exportar
    $pgDumpPath = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"
    
    & $pgDumpPath -h $dbHost -U $dbUser -d $dbName `
        --no-owner --no-privileges --clean --if-exists `
        --format=plain --verbose `
        -f $outputFile 2>&1 | Tee-Object -Variable output

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Exportación completada exitosamente" -ForegroundColor Green
        Write-Host "Archivo: $outputFile" -ForegroundColor Green
        
        $fileSize = (Get-Item $outputFile).Length / 1MB
        Write-Host "Tamaño: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
        
        return $outputFile
    } else {
        Write-Host ""
        Write-Host "❌ Error en la exportación" -ForegroundColor Red
        $output | Select-String -Pattern "ERROR" | ForEach-Object { Write-Host $_ -ForegroundColor Red }
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Error al ejecutar pg_dump: $_" -ForegroundColor Red
    exit 1
}

