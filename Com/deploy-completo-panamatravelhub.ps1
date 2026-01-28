# Script completo para desplegar PanamaTravelHub con base de datos
# Analiza cambios, actualiza repo, sincroniza DB y redespliega
# Solo afecta PanamaTravelHub, no toca otros contenedores

param(
    [switch]$SkipDB,
    [switch]$Force
)

$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

# Directorio del proyecto
$projectRoot = Split-Path -Parent $PSScriptRoot
$comDir = $PSScriptRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE COMPLETO PANAMATRAVELHUB" -ForegroundColor Cyan
Write-Host "  https://travel.autonomousflow.lat/" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# PASO 0: Verificar estado de Git local
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 0: ANALIZANDO CAMBIOS LOCALES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

Push-Location $projectRoot

# Verificar si hay cambios sin commitear
$gitStatus = git status --porcelain 2>&1
$hasChanges = $gitStatus -and ($gitStatus -notmatch "^\s*$")

if ($hasChanges) {
    Write-Host "⚠️  Se detectaron cambios sin commitear:" -ForegroundColor Yellow
    git status --short | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    Write-Host ""
    
    if (-not $Force) {
        $commit = Read-Host "¿Deseas hacer commit y push de estos cambios? (S/N)"
        if ($commit -eq "S" -or $commit -eq "s") {
            $commitMsg = Read-Host "Mensaje de commit (o presiona Enter para usar mensaje automático)"
            if ([string]::IsNullOrWhiteSpace($commitMsg)) {
                $commitMsg = "Actualización: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            }
            
            Write-Host "Haciendo commit..." -ForegroundColor Cyan
            git add -A
            git commit -m $commitMsg
            
            Write-Host "Haciendo push..." -ForegroundColor Cyan
            git push
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Cambios subidos a Git exitosamente" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Error al hacer push. Continuando con el despliegue..." -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠️  Continuando sin commit. Los cambios locales no se subirán." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Modo forzado: Haciendo commit automático..." -ForegroundColor Yellow
        $commitMsg = "Auto-deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        git add -A
        git commit -m $commitMsg
        git push
    }
} else {
    Write-Host "✅ No hay cambios sin commitear" -ForegroundColor Green
}

# Verificar última commit
$lastCommit = git log -1 --oneline 2>&1
Write-Host "Último commit: $lastCommit" -ForegroundColor Gray
Write-Host ""

Pop-Location

# PASO 1: Verificar estado de TODOS los contenedores (protección)
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 1: VERIFICACION PRE-DEPLOY" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Verificando estado de TODOS los contenedores..." -ForegroundColor Yellow
$cmdCheckAll = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
$resultCheckAll = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdCheckAll 2>&1
Write-Host $resultCheckAll
Write-Host ""
Write-Host "IMPORTANTE: Solo se afectará PanamaTravelHub" -ForegroundColor Cyan
Write-Host "  - Puerto web: 8082 (único)" -ForegroundColor Gray
Write-Host "  - Puerto DB: 5433 (único)" -ForegroundColor Gray
Write-Host "  - Contenedores: panamatravelhub_* (nombres únicos)" -ForegroundColor Gray
Write-Host "  - Red: panamatravelhub_net (aislada)" -ForegroundColor Gray
Write-Host ""

# PASO 2: Actualizar repositorio en el servidor
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 2: ACTUALIZANDO REPOSITORIO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Verificar que el directorio existe
Write-Host "Verificando directorio /opt/apps/panamatravelhub..." -ForegroundColor Cyan
$cmdDir = "mkdir -p /opt/apps/panamatravelhub && cd /opt/apps/panamatravelhub && pwd"
$resultDir = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdDir 2>&1
Write-Host $resultDir
Write-Host ""

# Actualizar repositorio
Write-Host "Actualizando repositorio (git pull)..." -ForegroundColor Cyan
$cmdPull = "cd /opt/apps/panamatravelhub && if [ -d .git ]; then git pull; else echo 'No es un repositorio Git. Clonar manualmente primero.'; exit 1; fi"
$resultPull = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdPull 2>&1
Write-Host $resultPull

if ($LASTEXITCODE -ne 0 -and $resultPull -match "Clonar manualmente") {
    Write-Host "⚠️  El repositorio no existe en el servidor. Clonando..." -ForegroundColor Yellow
    $cmdClone = "cd /opt/apps && git clone https://github.com/IrvingCorrosk19/PanamaTravelHub.git panamatravelhub || echo 'Error al clonar. Verificar URL del repositorio.'"
    $resultClone = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdClone 2>&1
    Write-Host $resultClone
    Write-Host ""
}

# Verificar archivos Docker
Write-Host ""
Write-Host "Verificando archivos Docker..." -ForegroundColor Cyan
$cmdFiles = "cd /opt/apps/panamatravelhub && ls -la Dockerfile docker-compose.yml 2>&1"
$resultFiles = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdFiles 2>&1
Write-Host $resultFiles
Write-Host ""

# PASO 3: Sincronizar base de datos (si no se omite)
if (-not $SkipDB) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  PASO 3: SINCRONIZANDO BASE DE DATOS" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ejecutando script de sincronización de DB..." -ForegroundColor Cyan
    
    $syncScript = Join-Path $comDir "sync-db-local-to-server.ps1"
    if (Test-Path $syncScript) {
        if ($Force) {
            & $syncScript -Force
        } else {
            & $syncScript
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Base de datos sincronizada exitosamente" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Hubo problemas al sincronizar la DB. Continuando con el despliegue..." -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Script de sincronización no encontrado. Omitiendo sincronización de DB." -ForegroundColor Yellow
        Write-Host "   Ruta esperada: $syncScript" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  PASO 3: OMITIENDO SINCRONIZACION DB" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Sincronización de DB omitida (parámetro -SkipDB)" -ForegroundColor Gray
    Write-Host ""
}

# PASO 4: Verificar/Crear archivo .env
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 4: CONFIGURANDO VARIABLES DE ENTORNO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

$envContent = @"
POSTGRES_DB=panamatravelhub_db
POSTGRES_USER=panamatravelhub_user
POSTGRES_PASSWORD=PanamaTravel2024!Secure

ASPNETCORE_ENVIRONMENT=Production
"@

$cmdEnv = "cd /opt/apps/panamatravelhub && cat > .env << 'EOF'
POSTGRES_DB=panamatravelhub_db
POSTGRES_USER=panamatravelhub_user
POSTGRES_PASSWORD=PanamaTravel2024!Secure

ASPNETCORE_ENVIRONMENT=Production
EOF
"
Write-Host "Creando/actualizando archivo .env..." -ForegroundColor Cyan
$resultEnv = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdEnv 2>&1
Write-Host "✅ Archivo .env configurado" -ForegroundColor Green
Write-Host ""

# PASO 5: Detener contenedores existentes (solo PanamaTravelHub)
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 5: DETENIENDO CONTENEDORES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Deteniendo contenedores de PanamaTravelHub..." -ForegroundColor Cyan
$cmdDown = "cd /opt/apps/panamatravelhub && docker compose down"
$resultDown = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdDown 2>&1
Write-Host $resultDown
Write-Host "✅ Contenedores detenidos" -ForegroundColor Green
Write-Host ""

# PASO 6: Reconstruir y levantar contenedores
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 6: RECONSTRUYENDO Y DESPLEGANDO" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos..." -ForegroundColor Gray
Write-Host "Construyendo imágenes y levantando contenedores..." -ForegroundColor Cyan
$cmdUp = "cd /opt/apps/panamatravelhub && docker compose up -d --build"
$resultUp = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdUp 2>&1
Write-Host $resultUp
Write-Host ""

# Esperar unos segundos para que los contenedores inicien
Write-Host "Esperando 10 segundos para que los contenedores inicien..." -ForegroundColor Gray
Start-Sleep -Seconds 10
Write-Host ""

# PASO 7: Verificar contenedores
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 7: VERIFICANDO CONTENEDORES" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Estado de TODOS los contenedores:" -ForegroundColor Cyan
$cmdPs = "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
$resultPs = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdPs 2>&1
Write-Host $resultPs
Write-Host ""

# Verificar específicamente PanamaTravelHub
Write-Host "Verificando contenedores de PanamaTravelHub:" -ForegroundColor Cyan
$cmdCheck = "docker ps --filter name=panamatravelhub --format '{{.Names}}: {{.Status}}'"
$resultCheck = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdCheck 2>&1
if ($resultCheck -and $resultCheck -notmatch "^\s*$") {
    Write-Host "✅ Contenedores de PanamaTravelHub:" -ForegroundColor Green
    $resultCheck -split "`n" | ForEach-Object {
        if ($_ -and $_ -notmatch "^\s*$") {
            Write-Host "  $_" -ForegroundColor White
        }
    }
} else {
    Write-Host "⚠️  No se encontraron contenedores de PanamaTravelHub corriendo" -ForegroundColor Yellow
}
Write-Host ""

# PASO 8: Ver logs de la aplicación
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 8: LOGS DE LA APLICACION" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "Últimas 30 líneas de logs:" -ForegroundColor Cyan
$cmdLogs = "docker logs --tail 30 panamatravelhub_web 2>&1 || echo 'Contenedor aún no disponible, espera unos segundos...'"
$resultLogs = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdLogs 2>&1
Write-Host $resultLogs
Write-Host ""

# PASO 9: Verificar salud de la aplicación
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  PASO 9: VERIFICACION FINAL" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# Verificar que el contenedor web está corriendo
$cmdHealth = "docker ps --filter name=panamatravelhub_web --filter status=running --format '{{.Names}}'"
$resultHealth = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdHealth 2>&1

if ($resultHealth -match "panamatravelhub_web") {
    Write-Host "✅ Contenedor web está corriendo" -ForegroundColor Green
} else {
    Write-Host "⚠️  El contenedor web no está corriendo. Revisa los logs." -ForegroundColor Yellow
}

# Verificar que el contenedor DB está corriendo
$cmdHealthDB = "docker ps --filter name=panamatravelhub_postgres --filter status=running --format '{{.Names}}'"
$resultHealthDB = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdHealthDB 2>&1

if ($resultHealthDB -match "panamatravelhub_postgres") {
    Write-Host "✅ Contenedor de base de datos está corriendo" -ForegroundColor Green
} else {
    Write-Host "⚠️  El contenedor de base de datos no está corriendo." -ForegroundColor Yellow
}

Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Aplicación disponible en:" -ForegroundColor Green
Write-Host "  - URL: https://travel.autonomousflow.lat/" -ForegroundColor White
Write-Host "  - IP Directa: http://164.68.99.83:8082" -ForegroundColor White
Write-Host ""
Write-Host "Comandos útiles:" -ForegroundColor Yellow
Write-Host "  Ver logs en tiempo real:" -ForegroundColor Gray
Write-Host "    docker logs -f panamatravelhub_web" -ForegroundColor White
Write-Host ""
Write-Host "  Ver logs de base de datos:" -ForegroundColor Gray
Write-Host "    docker logs -f panamatravelhub_postgres" -ForegroundColor White
Write-Host ""
Write-Host "  Reiniciar aplicación:" -ForegroundColor Gray
Write-Host "    cd /opt/apps/panamatravelhub && docker compose restart" -ForegroundColor White
Write-Host ""
Write-Host "  Detener aplicación:" -ForegroundColor Gray
Write-Host "    cd /opt/apps/panamatravelhub && docker compose down" -ForegroundColor White
Write-Host ""
Write-Host "  Sincronizar DB nuevamente:" -ForegroundColor Gray
Write-Host "    .\sync-db-local-to-server.ps1" -ForegroundColor White
Write-Host ""
