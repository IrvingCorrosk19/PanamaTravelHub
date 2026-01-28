# Script rápido para verificar estado del despliegue
$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

Write-Host "Verificando estado de contenedores..." -ForegroundColor Cyan
$cmd = "docker ps --filter name=panamatravelhub --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
$result = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd 2>&1
Write-Host $result
Write-Host ""

Write-Host "Verificando logs recientes..." -ForegroundColor Cyan
$cmdLogs = "docker logs --tail 20 panamatravelhub_web 2>&1"
$resultLogs = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdLogs 2>&1
Write-Host $resultLogs
