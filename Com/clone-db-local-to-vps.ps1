# Script para CLONAR la base de datos local en el VPS (esquema + datos completos)
# La DB del VPS quedara identica a la local.
# Uso: .\clone-db-local-to-vps.ps1 [-Force]

param(
    [switch]$Force
)

$plink = "C:\Program Files\PuTTY\plink.exe"
$pscp = "C:\Program Files\PuTTY\pscp.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

$localHost = "localhost"
$localPort = "5432"
$localDatabase = "PanamaTravelHub"
$localUser = "postgres"
$localPassword = "Panama2020$"

$serverContainer = "panamatravelhub_postgres"
$serverDatabase = "panamatravelhub_db"
$serverUser = "panamatravelhub_user"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CLON DB LOCAL -> VPS (esquema + datos)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "ADVERTENCIA: La base de datos del VPS sera REEMPLAZADA por una copia exacta de la local." -ForegroundColor Red
Write-Host ""

if (-not $Force) {
    try {
        $confirm = Read-Host "Continuar? (escribe 'SI' para confirmar)"
        if ($confirm -ne "SI") { Write-Host "Cancelado." -ForegroundColor Yellow; exit }
    } catch {
        Write-Host "Modo no interactivo. Continuando..." -ForegroundColor Yellow
    }
} else {
    Write-Host "Modo forzado. Continuando..." -ForegroundColor Yellow
}

$backupsDir = Join-Path $PSScriptRoot "..\backups"
if (-not (Test-Path $backupsDir)) { New-Item -ItemType Directory -Path $backupsDir -Force | Out-Null }

$pgDumpPath = Get-ChildItem "C:\Program Files\PostgreSQL" -Recurse -Filter "pg_dump.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
if (-not $pgDumpPath) { $pgDumpPath = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" }
if (-not $pgDumpPath -or -not (Test-Path $pgDumpPath)) {
    Write-Host "No se encontro pg_dump.exe." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $pscp)) {
    Write-Host "No se encontro pscp.exe (PuTTY)." -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "PanamaTravelHub_full_$timestamp.sql"
$backupPath = Join-Path $backupsDir $backupFile

# PASO 1: Dump COMPLETO (esquema + datos, con --clean para poder restaurar sobre DB existente)
Write-Host ""
Write-Host "PASO 1: Creando dump completo de la base local (esquema + datos)..." -ForegroundColor Yellow
$env:PGPASSWORD = $localPassword
& $pgDumpPath -h $localHost -p $localPort -U $localUser -d $localDatabase -F p --clean --if-exists --no-owner --no-acl -f $backupPath
Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al crear dump (codigo $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}
$fileInfo = Get-Item $backupPath
Write-Host "Dump creado: $backupFile ($([math]::Round($fileInfo.Length/1MB,2)) MB)" -ForegroundColor Green

# PASO 2: Transferir al VPS
Write-Host ""
Write-Host "PASO 2: Transfiriendo al VPS..." -ForegroundColor Yellow
$serverBackupPath = "/tmp/$backupFile"
$pscpCmd = "& `"$pscp`" -pw `"$password`" -hostkey `"$hostkey`" `"$backupPath`" `"${hostname}:$serverBackupPath`""
Invoke-Expression $pscpCmd
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al transferir." -ForegroundColor Red
    exit 1
}
Write-Host "Transferido." -ForegroundColor Green

# PASO 3: Restaurar en el contenedor (reemplaza esquema y datos)
# Usamos sed para reemplazar \connect a la DB local por la del servidor (por si el dump lo incluye)
Write-Host ""
Write-Host "PASO 3: Restaurando en la base del VPS (puede tardar)..." -ForegroundColor Yellow
$restoreCmd = "sed 's/\\\\connect $localDatabase/\\\\connect $serverDatabase/g' $serverBackupPath | docker exec -i $serverContainer psql -U $serverUser -d $serverDatabase -v ON_ERROR_STOP=0 2>&1"
$restoreResult = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $restoreCmd 2>&1
$hasErrors = $restoreResult -match "ERROR|FATAL"
if ($hasErrors) {
    Write-Host "Algunos avisos/errores durante la restauracion (pueden ser normales con --clean):" -ForegroundColor Yellow
    $restoreResult | Select-String -Pattern "ERROR|FATAL" | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "Restauracion finalizada." -ForegroundColor Green
}

# PASO 4: Limpiar temporal en VPS
Write-Host ""
Write-Host "PASO 4: Limpiando archivo temporal en VPS..." -ForegroundColor Yellow
& $plink -ssh -pw $password -batch -hostkey $hostkey $hostname "rm -f $serverBackupPath" 2>&1 | Out-Null
Write-Host "Listo." -ForegroundColor Green

# PASO 5: Verificar
Write-Host ""
Write-Host "PASO 5: Verificando..." -ForegroundColor Yellow
$serverCountCmd = "docker exec $serverContainer psql -U $serverUser -d $serverDatabase -t -A -c 'SELECT (SELECT COUNT(*) FROM users) || chr(124) || (SELECT COUNT(*) FROM tours) || chr(124) || (SELECT COUNT(*) FROM bookings) || chr(124) || (SELECT COUNT(*) FROM payments);'"
$serverCountResult = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $serverCountCmd 2>&1
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  CLON COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Conteo en VPS (users|tours|bookings|payments): $serverCountResult" -ForegroundColor White
Write-Host "La base del VPS es ahora un clon de la local." -ForegroundColor Green
Write-Host ""
