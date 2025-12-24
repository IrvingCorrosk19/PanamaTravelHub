# Script para verificar tablas en la base de datos de Render
$env:PGPASSWORD = 'YFxc28DdPtabZS11XfVxywP5SnS53yZP'
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$host = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$user = "panamatravelhub_user"
$database = "panamatravelhub"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verificando tablas en la base de datos" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Lista de tablas esperadas
$tablasEsperadas = @(
    'users',
    'roles',
    'user_roles',
    'tours',
    'tour_images',
    'tour_dates',
    'bookings',
    'booking_participants',
    'payments',
    'email_notifications',
    'audit_logs',
    'home_page_content',
    'refresh_tokens'
)

# Obtener tablas existentes
$query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;"
$tablasExistentes = & $psqlPath -h $host -U $user -d $database -t -A -c $query

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al conectar con la base de datos" -ForegroundColor Red
    exit 1
}

$tablasArray = $tablasExistentes -split "`n" | Where-Object { $_.Trim() -ne '' } | ForEach-Object { $_.Trim() }

Write-Host "Tablas encontradas en la base de datos:" -ForegroundColor Green
foreach ($tabla in $tablasArray) {
    Write-Host "  ✅ $tabla" -ForegroundColor Green
}

Write-Host ""
Write-Host "Verificando tablas esperadas:" -ForegroundColor Yellow
Write-Host ""

$faltantes = @()
$existentes = @()

foreach ($tablaEsperada in $tablasEsperadas) {
    if ($tablasArray -contains $tablaEsperada) {
        Write-Host "  ✅ $tablaEsperada - EXISTE" -ForegroundColor Green
        $existentes += $tablaEsperada
    } else {
        Write-Host "  ❌ $tablaEsperada - FALTA" -ForegroundColor Red
        $faltantes += $tablaEsperada
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Resumen:" -ForegroundColor Cyan
Write-Host "  Total esperadas: $($tablasEsperadas.Count)" -ForegroundColor White
Write-Host "  Existentes: $($existentes.Count)" -ForegroundColor Green
Write-Host "  Faltantes: $($faltantes.Count)" -ForegroundColor $(if ($faltantes.Count -eq 0) { "Green" } else { "Red" })
Write-Host "========================================" -ForegroundColor Cyan

if ($faltantes.Count -gt 0) {
    Write-Host ""
    Write-Host "Tablas que faltan:" -ForegroundColor Red
    foreach ($tabla in $faltantes) {
        Write-Host "  - $tabla" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host ""
    Write-Host "✅ Todas las tablas están migradas correctamente!" -ForegroundColor Green
    exit 0
}

