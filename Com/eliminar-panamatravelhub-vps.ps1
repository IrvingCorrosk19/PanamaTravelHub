# Elimina SOLO los contenedores y la base de datos de PanamaTravelHub (travel.autonomousflow.lat)
# No toca CarnetQR, n8n ni otras aplicaciones del VPS

$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ELIMINAR PanamaTravelHub (contenedor + DB)" -ForegroundColor Cyan
Write-Host "  https://travel.autonomousflow.lat/" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se eliminaran:" -ForegroundColor Yellow
Write-Host "  - Contenedor panamatravelhub_web" -ForegroundColor Gray
Write-Host "  - Contenedor panamatravelhub_postgres" -ForegroundColor Gray
Write-Host "  - Volumenes (base de datos y datos de la app)" -ForegroundColor Gray
Write-Host ""
Write-Host "NO se tocan: CarnetQR, n8n ni otros contenedores." -ForegroundColor Green
Write-Host ""

# Paso 1: Ir al directorio y bajar contenedores + volúmenes
Write-Host "PASO 1: Deteniendo y eliminando contenedores y volúmenes..." -ForegroundColor Yellow
$cmdDown = "cd /opt/apps/panamatravelhub && docker compose down -v"
$resultDown = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdDown 2>&1
Write-Host $resultDown
Write-Host ""

# Paso 2: Verificar que ya no existan
Write-Host "PASO 2: Verificando que los contenedores fueron eliminados..." -ForegroundColor Yellow
$cmdPs = "docker ps -a --filter name=panamatravelhub --format 'table {{.Names}}\t{{.Status}}'"
$resultPs = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdPs 2>&1
Write-Host $resultPs
Write-Host ""

# Listar volúmenes (opcional: ver si quedan volúmenes huérfanos con nombre panamatravelhub)
$cmdVol = "docker volume ls --filter name=panamatravelhub"
$resultVol = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdVol 2>&1
Write-Host "Volúmenes restantes con nombre panamatravelhub:" -ForegroundColor Gray
Write-Host $resultVol
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "  PanamaTravelHub eliminado" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "El codigo en /opt/apps/panamatravelhub sigue en el servidor." -ForegroundColor Gray
Write-Host "Para volver a instalar: ejecuta .\deploy-completo-panamatravelhub.ps1 -Force" -ForegroundColor Gray
Write-Host ""
