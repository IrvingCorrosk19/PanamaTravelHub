# ============================================
# Script PowerShell: Sincronización Completa Local → Render
# ============================================
# Este script sincroniza TANTO la estructura como los datos
# desde la base de datos local hacia Render
# ============================================

$ErrorActionPreference = "Stop"

# Configuración de PostgreSQL local
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$pgDumpPath = "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe"

# Configuración LOCAL
$localHost = "localhost"
$localPort = "5432"
$localDatabase = "PanamaTravelHub"
$localUser = "postgres"
$localPassword = "Panama2020$"

# Configuración RENDER
$renderHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub"
$renderUser = "panamatravelhub_user"
$renderPassword = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"

# Construir cadenas de conexión
$localConnectionString = "Host=$localHost;Port=$localPort;Database=$localDatabase;Username=$localUser;Password=$localPassword"
$renderConnectionString = "Host=$renderHost;Port=$renderPort;Database=$renderDatabase;Username=$renderUser;Password=$renderPassword;SSL Mode=Require;Trust Server Certificate=true"

# Archivos temporales
$tempDir = Join-Path $PSScriptRoot "temp_sync"
$structureFile = Join-Path $tempDir "structure.sql"
$dataFile = Join-Path $tempDir "data.sql"
$fullBackupFile = Join-Path $tempDir "full_backup.sql"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "SINCRONIZACIÓN COMPLETA: Local → Render" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que psql y pg_dump existan
if (-not (Test-Path $psqlPath)) {
    Write-Host "ERROR: No se encuentra psql.exe en: $psqlPath" -ForegroundColor Red
    Write-Host "Por favor, verifica la ruta de PostgreSQL" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $pgDumpPath)) {
    Write-Host "ERROR: No se encuentra pg_dump.exe en: $pgDumpPath" -ForegroundColor Red
    Write-Host "Por favor, verifica la ruta de PostgreSQL" -ForegroundColor Red
    exit 1
}

# Crear directorio temporal
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    Write-Host "✓ Directorio temporal creado: $tempDir" -ForegroundColor Green
}

Write-Host "PASO 1: Exportando estructura desde LOCAL..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $localPassword
    
    # Exportar SOLO estructura (sin datos)
    & $pgDumpPath `
        -h $localHost `
        -p $localPort `
        -U $localUser `
        -d $localDatabase `
        --schema-only `
        --no-owner `
        --no-privileges `
        -f $structureFile `
        2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Estructura exportada correctamente" -ForegroundColor Green
    } else {
        throw "Error al exportar estructura (código: $LASTEXITCODE)"
    }
} catch {
    Write-Host "ERROR al exportar estructura: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "PASO 2: Exportando datos desde LOCAL..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $localPassword
    
    # Exportar SOLO datos (sin estructura)
    & $pgDumpPath `
        -h $localHost `
        -p $localPort `
        -U $localUser `
        -d $localDatabase `
        --data-only `
        --no-owner `
        --no-privileges `
        --disable-triggers `
        -f $dataFile `
        2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Datos exportados correctamente" -ForegroundColor Green
    } else {
        throw "Error al exportar datos (código: $LASTEXITCODE)"
    }
} catch {
    Write-Host "ERROR al exportar datos: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "PASO 3: Aplicando estructura en RENDER..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    
    # Aplicar estructura en Render
    & $psqlPath $renderConnectionString -f $structureFile 2>&1 | ForEach-Object {
        if ($_ -match "ERROR|error") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -match "NOTICE|notice") {
            Write-Host $_ -ForegroundColor Cyan
        } else {
            Write-Host $_
        }
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Estructura aplicada correctamente en Render" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Advertencia: Algunos errores pueden ser normales (tablas/columnas ya existentes)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR al aplicar estructura: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "⚠️ Continuando con datos..." -ForegroundColor Yellow
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "PASO 4: Aplicando datos en RENDER..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    
    # Aplicar datos en Render
    & $psqlPath $renderConnectionString -f $dataFile 2>&1 | ForEach-Object {
        if ($_ -match "ERROR|error") {
            Write-Host $_ -ForegroundColor Red
        } elseif ($_ -match "NOTICE|notice") {
            Write-Host $_ -ForegroundColor Cyan
        } else {
            Write-Host $_
        }
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Datos aplicados correctamente en Render" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Advertencia: Algunos errores pueden ser normales (registros duplicados)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR al aplicar datos: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "PASO 5: Verificando sincronización..." -ForegroundColor Yellow
Write-Host ""

try {
    $env:PGPASSWORD = $renderPassword
    
    # Verificar conteos en Render
    $verificationQuery = @"
SELECT 
    'tours' as tabla, COUNT(*) as total FROM tours
UNION ALL
SELECT 'tour_images', COUNT(*) FROM tour_images
UNION ALL
SELECT 'tour_dates', COUNT(*) FROM tour_dates
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'countries', COUNT(*) FROM countries
UNION ALL
SELECT 'home_page_content', COUNT(*) FROM home_page_content
ORDER BY tabla;
"@
    
    Write-Host "Conteos en RENDER:" -ForegroundColor Cyan
    & $psqlPath $renderConnectionString -c $verificationQuery 2>&1 | ForEach-Object {
        Write-Host $_
    }
    
} catch {
    Write-Host "⚠️ No se pudo verificar (no crítico): $($_.Exception.Message)" -ForegroundColor Yellow
} finally {
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "SINCRONIZACIÓN COMPLETA FINALIZADA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Archivos temporales guardados en: $tempDir" -ForegroundColor Cyan
Write-Host "Puedes revisarlos o eliminarlos después de verificar." -ForegroundColor Cyan
Write-Host ""

