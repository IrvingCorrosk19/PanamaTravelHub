# Ver logs del contenedor PanamaTravelHub en el VPS
# Uso: .\verificar-logs-panamatravelhub.ps1 [--tail 200]
param([int]$Tail = 150)

$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  LOGS PANAMATRAVELHUB (ultimas $Tail lineas)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$cmd = "docker logs --tail $Tail panamatravelhub_web 2>&1"
$result = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd 2>&1
Write-Host $result
Write-Host ""
Write-Host "Para ver logs en tiempo real: docker logs -f panamatravelhub_web" -ForegroundColor Gray
