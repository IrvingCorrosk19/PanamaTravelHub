# Script para desplegar PanamaTravelHub en Docker en el servidor VPS
# Multi-aplicación: No afecta CarnetQR que está en /opt/apps/aspnet
$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE PANAMATRAVELHUB - DOCKER" -ForegroundColor Cyan
Write-Host "  Multi-aplicación (sin afectar CarnetQR)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que CarnetQR sigue funcionando
Write-Host "Verificando aplicación existente (CarnetQR)..." -ForegroundColor Yellow
$cmdCheck = "docker ps --filter name=carnetqr --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
$resultCheck = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdCheck 2>&1
Write-Host $resultCheck
Write-Host ""

# PASO 0: Crear directorio si no existe
Write-Host "PASO 0: Verificando directorio /opt/apps/panamatravelhub..." -ForegroundColor Yellow
$cmd0 = "mkdir -p /opt/apps/panamatravelhub && cd /opt/apps/panamatravelhub && pwd"
Write-Host "Ejecutando: $cmd0" -ForegroundColor Gray
$result0 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd0 2>&1
Write-Host $result0
Write-Host ""

# PASO 1: Actualizar el repositorio
Write-Host "PASO 1: Actualizando repositorio..." -ForegroundColor Yellow
$cmd1 = "cd /opt/apps/panamatravelhub && if [ -d .git ]; then git pull; else echo 'No es un repositorio Git. Clonar manualmente primero.'; fi"
Write-Host "Ejecutando: $cmd1" -ForegroundColor Gray
$result1 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd1 2>&1
Write-Host $result1
Write-Host ""

# PASO 2: Verificar que existen Dockerfile y docker-compose.yml
Write-Host "PASO 2: Verificando archivos Docker..." -ForegroundColor Yellow
$cmd2 = "cd /opt/apps/panamatravelhub && ls -la Dockerfile docker-compose.yml"
Write-Host "Ejecutando: $cmd2" -ForegroundColor Gray
$result2 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd2 2>&1
Write-Host $result2
Write-Host ""

# PASO 3: Crear archivo .env si no existe
Write-Host "PASO 3: Creando archivo .env..." -ForegroundColor Yellow
$envContent = @"
POSTGRES_DB=panamatravelhub_db
POSTGRES_USER=panamatravelhub_user
POSTGRES_PASSWORD=PanamaTravel2024!Secure

ASPNETCORE_ENVIRONMENT=Production
"@

$cmd3 = "cd /opt/apps/panamatravelhub && cat > .env << 'EOF'
POSTGRES_DB=panamatravelhub_db
POSTGRES_USER=panamatravelhub_user
POSTGRES_PASSWORD=PanamaTravel2024!Secure

ASPNETCORE_ENVIRONMENT=Production
EOF
"
Write-Host "Ejecutando: Creando .env..." -ForegroundColor Gray
$result3 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd3 2>&1
Write-Host $result3
Write-Host ""

# Verificar que .env se creó
Write-Host "Verificando .env..." -ForegroundColor Yellow
$cmd3b = "cd /opt/apps/panamatravelhub && cat .env"
$result3b = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd3b 2>&1
Write-Host $result3b
Write-Host ""

# PASO 4: Construir y levantar contenedores
Write-Host "PASO 4: Construyendo y levantando contenedores..." -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos en la primera ejecución..." -ForegroundColor Gray
Write-Host "Puerto: 8082 (no afecta CarnetQR en 8081)" -ForegroundColor Gray
$cmd4 = "cd /opt/apps/panamatravelhub && docker compose up -d --build"
Write-Host "Ejecutando: $cmd4" -ForegroundColor Gray
$result4 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd4 2>&1
Write-Host $result4
Write-Host ""

# PASO 5: Verificar contenedores (todos para comparar)
Write-Host "PASO 5: Verificando contenedores..." -ForegroundColor Yellow
Write-Host "Contenedores en el servidor (CarnetQR + PanamaTravelHub):" -ForegroundColor Cyan
$cmd5 = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
Write-Host "Ejecutando: $cmd5" -ForegroundColor Gray
$result5 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd5 2>&1
Write-Host $result5
Write-Host ""

# PASO 6: Ver logs de PanamaTravelHub
Write-Host "PASO 6: Últimas 30 líneas de logs de PanamaTravelHub..." -ForegroundColor Yellow
$cmd6 = "docker logs --tail 30 panamatravelhub_web 2>&1 || echo 'Contenedor aún no disponible, espera unos segundos...'"
Write-Host "Ejecutando: $cmd6" -ForegroundColor Gray
$result6 = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd6 2>&1
Write-Host $result6
Write-Host ""

# PASO 7: Verificar salud de ambas aplicaciones
Write-Host "PASO 7: Estado de aplicaciones..." -ForegroundColor Yellow
Write-Host ""
Write-Host "CarnetQR:" -ForegroundColor Cyan
$cmd7a = "docker ps --filter name=carnetqr --format '{{.Names}}: {{.Status}}'"
$result7a = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd7a 2>&1
Write-Host $result7a
Write-Host ""
Write-Host "PanamaTravelHub:" -ForegroundColor Cyan
$cmd7b = "docker ps --filter name=panamatravelhub --format '{{.Names}}: {{.Status}}'"
$result7b = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmd7b 2>&1
Write-Host $result7b
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Aplicaciones disponibles:" -ForegroundColor Green
Write-Host "  - CarnetQR:      http://164.68.99.83:8081 (no afectada)" -ForegroundColor Green
Write-Host "  - PanamaTravelHub: http://164.68.99.83:8082" -ForegroundColor Green
Write-Host ""
Write-Host "Comandos útiles:" -ForegroundColor Yellow
Write-Host "  Ver logs PanamaTravelHub:" -ForegroundColor Gray
Write-Host "    docker logs -f panamatravelhub_web" -ForegroundColor White
Write-Host ""
Write-Host "  Ver logs CarnetQR (verificar que sigue funcionando):" -ForegroundColor Gray
Write-Host "    docker logs -f carnetqr_web" -ForegroundColor White
Write-Host ""
Write-Host "  Detener PanamaTravelHub:" -ForegroundColor Gray
Write-Host "    cd /opt/apps/panamatravelhub && docker compose down" -ForegroundColor White
Write-Host ""
Write-Host "  Reiniciar PanamaTravelHub:" -ForegroundColor Gray
Write-Host "    cd /opt/apps/panamatravelhub && docker compose restart" -ForegroundColor White
Write-Host ""
