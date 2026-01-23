# ============================================
# Script PowerShell para Verificar Sincronización
# ============================================

$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

# Credenciales de Localhost
$localhostHost = "localhost"
$localhostPort = "5432"
$localhostDatabase = "PanamaTravelHub"
$localhostUser = "postgres"
$localhostPassword = "Panama2020$"

# Credenciales de Render
$renderHost = "dpg-d5efvg7pm1nc73a63qqg-a.virginia-postgres.render.com"
$renderPort = "5432"
$renderDatabase = "panamatravelhub_2juu"
$renderUser = "panamatravelhub_2juu_user"
$renderPassword = "BhC1OtUf9WBxSKUrWksobwH8jwNYAmKT"

# Construir cadenas de conexión
$localhostConn = "Host=$localhostHost;Port=$localhostPort;Database=$localhostDatabase;Username=$localhostUser;Password=$localhostPassword"
$renderConn = "Host=$renderHost;Port=$renderPort;Database=$renderDatabase;Username=$renderUser;Password=$renderPassword;SSL Mode=Require;Trust Server Certificate=true"

# Query para obtener conteos
$countQuery = @"
SELECT 
    'tours' as tabla, COUNT(*) as total,
    COUNT(*) FILTER (WHERE is_active = true) as activos
FROM tours
UNION ALL
SELECT 
    'tour_images', COUNT(*), COUNT(*) FILTER (WHERE is_primary = true)
FROM tour_images
UNION ALL
SELECT 
    'tour_dates', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM tour_dates
UNION ALL
SELECT 
    'bookings', COUNT(*), COUNT(*) FILTER (WHERE status = 2)
FROM bookings
UNION ALL
SELECT 
    'users', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM users
UNION ALL
SELECT 
    'countries', COUNT(*), COUNT(*) FILTER (WHERE is_active = true)
FROM countries
ORDER BY tabla;
"@

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Verificando Sincronización" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Obtener conteos de localhost
Write-Host "Obteniendo conteos de Localhost..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD = $localhostPassword
    $localhostResults = & $psqlPath $localhostConn -t -A -F "|" -c $countQuery
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
} catch {
    Write-Host "ERROR al conectar a localhost: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Obtener conteos de Render
Write-Host "Obteniendo conteos de Render..." -ForegroundColor Yellow
try {
    $env:PGPASSWORD = $renderPassword
    $renderResults = & $psqlPath $renderConn -t -A -F "|" -c $countQuery
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
} catch {
    Write-Host "ERROR al conectar a Render: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Comparar resultados
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Comparación de Conteos" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host ("{0,-20} {1,-15} {2,-15} {3,-15}" -f "Tabla", "Localhost", "Render", "Estado")
Write-Host ("-" * 65)

$allMatch = $true
$localhostLines = $localhostResults | Where-Object { $_.Trim() -ne "" }
$renderLines = $renderResults | Where-Object { $_.Trim() -ne "" }

foreach ($line in $localhostLines) {
    $parts = $line -split '\|'
    $tabla = $parts[0].Trim()
    $localhostTotal = $parts[1].Trim()
    
    $renderLine = $renderLines | Where-Object { $_ -like "$tabla*" }
    if ($renderLine) {
        $renderParts = $renderLine -split '\|'
        $renderTotal = $renderParts[1].Trim()
        
        if ($localhostTotal -eq $renderTotal) {
            Write-Host ("{0,-20} {1,-15} {2,-15} {3}" -f $tabla, $localhostTotal, $renderTotal, "[OK]") -ForegroundColor Green
        } else {
            Write-Host ("{0,-20} {1,-15} {2,-15} {3}" -f $tabla, $localhostTotal, $renderTotal, "[DIFERENTE]") -ForegroundColor Red
            $allMatch = $false
        }
    } else {
        Write-Host ("{0,-20} {1,-15} {2,-15} {3}" -f $tabla, $localhostTotal, "NO ENCONTRADO", "[ERROR]") -ForegroundColor Red
        $allMatch = $false
    }
}

Write-Host ""
if ($allMatch) {
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "[OK] Todas las tablas estan sincronizadas!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
} else {
    Write-Host "============================================" -ForegroundColor Red
    Write-Host "[ERROR] Hay diferencias entre las bases de datos" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Red
}

