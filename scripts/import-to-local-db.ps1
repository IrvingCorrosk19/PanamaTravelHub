# Script para importar el dump de Render a la base de datos local
# Uso: .\scripts\import-to-local-db.ps1 [archivo.sql]

param(
    [string]$dumpFile = ""
)

$localDbHost = "localhost"
$localDbPort = "5432"
$localDbName = "PanamaTravelHub"
$localDbUser = "postgres"
$localDbPassword = "Panama2020$"

$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$createdbPath = "C:\Program Files\PostgreSQL\18\bin\createdb.exe"
$dropdbPath = "C:\Program Files\PostgreSQL\18\bin\dropdb.exe"

Write-Host "=== Importando base de datos a local ===" -ForegroundColor Cyan
Write-Host ""

# Si no se especificó archivo, buscar el más reciente
if ([string]::IsNullOrWhiteSpace($dumpFile)) {
    $latestDump = Get-ChildItem -Path "database" -Filter "render-backup-*.sql" | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    
    if ($latestDump) {
        $dumpFile = $latestDump.FullName
        Write-Host "Usando dump más reciente: $dumpFile" -ForegroundColor Yellow
    } else {
        Write-Host "❌ No se encontró ningún archivo de dump" -ForegroundColor Red
        Write-Host "Ejecuta primero: .\scripts\export-render-db.ps1" -ForegroundColor Yellow
        exit 1
    }
}

if (-not (Test-Path $dumpFile)) {
    Write-Host "❌ El archivo no existe: $dumpFile" -ForegroundColor Red
    exit 1
}

$env:PGPASSWORD = $localDbPassword

Write-Host "Base de datos local: $localDbName" -ForegroundColor Yellow
Write-Host "Usuario: $localDbUser" -ForegroundColor Yellow
Write-Host "Archivo: $dumpFile" -ForegroundColor Yellow
Write-Host ""

# Verificar si la base de datos existe
Write-Host "Verificando si la base de datos existe..." -ForegroundColor Yellow
$dbExists = & $psqlPath -h $localDbHost -p $localDbPort -U $localDbUser -d postgres -t -c "SELECT 1 FROM pg_database WHERE datname='$localDbName';" 2>&1

if ($dbExists -match "1") {
    Write-Host "⚠️  La base de datos ya existe" -ForegroundColor Yellow
    $response = Read-Host "¿Deseas eliminarla y recrearla? (s/N)"
    if ($response -eq "s" -or $response -eq "S") {
        Write-Host "Eliminando base de datos existente..." -ForegroundColor Yellow
        & $dropdbPath -h $localDbHost -p $localDbPort -U $localDbUser $localDbName 2>&1 | Out-Null
    } else {
        Write-Host "Cancelado por el usuario" -ForegroundColor Yellow
        exit 0
    }
}

# Crear la base de datos si no existe
if (-not ($dbExists -match "1")) {
    Write-Host "Creando base de datos..." -ForegroundColor Yellow
    & $createdbPath -h $localDbHost -p $localDbPort -U $localDbUser $localDbName 2>&1 | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al crear la base de datos" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Base de datos creada" -ForegroundColor Green
}

# Habilitar extensiones necesarias
Write-Host "Habilitando extensiones necesarias..." -ForegroundColor Yellow
& $psqlPath -h $localDbHost -p $localDbPort -U $localDbUser -d $localDbName -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" 2>&1 | Out-Null

# Importar el dump
Write-Host "Importando datos (esto puede tardar varios minutos)..." -ForegroundColor Yellow
& $psqlPath -h $localDbHost -p $localDbPort -U $localDbUser -d $localDbName -f $dumpFile 2>&1 | Tee-Object -Variable output

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Importación completada exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "Base de datos local lista para usar:" -ForegroundColor Cyan
    Write-Host "  Host: $localDbHost" -ForegroundColor White
    Write-Host "  Port: $localDbPort" -ForegroundColor White
    Write-Host "  Database: $localDbName" -ForegroundColor White
    Write-Host "  Username: $localDbUser" -ForegroundColor White
    Write-Host "  Connection String: Host=$localDbHost;Port=$localDbPort;Database=$localDbName;Username=$localDbUser;Password=$localDbPassword" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Error en la importación" -ForegroundColor Red
    $output | Select-String -Pattern "ERROR" | Select-Object -First 10 | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
}

