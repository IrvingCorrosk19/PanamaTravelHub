$env:PGPASSWORD = 'YFxc28DdPtabZS11XfVxywP5SnS53yZP'
$psql = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$conn = "-h dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com -U panamatravelhub_user -d panamatravelhub"

Write-Host "Conectando a la base de datos..." -ForegroundColor Yellow

# Obtener lista de tablas
$query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE' ORDER BY table_name;"
$result = & $psql $conn -t -A -c $query 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: $result" -ForegroundColor Red
    exit 1
}

$tablas = $result | Where-Object { $_.Trim() -ne '' } | ForEach-Object { $_.Trim() }

Write-Host "`nTablas encontradas ($($tablas.Count)):" -ForegroundColor Green
foreach ($t in $tablas) {
    Write-Host "  - $t" -ForegroundColor White
}

# Verificar tablas esperadas
$esperadas = @('users','roles','user_roles','tours','tour_images','tour_dates','bookings','booking_participants','payments','email_notifications','audit_logs','home_page_content','refresh_tokens')

Write-Host "`nVerificando tablas esperadas:" -ForegroundColor Yellow
$faltantes = @()
foreach ($e in $esperadas) {
    if ($tablas -contains $e) {
        Write-Host "  ✓ $e" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $e - FALTA" -ForegroundColor Red
        $faltantes += $e
    }
}

if ($faltantes.Count -eq 0) {
    Write-Host "`n✓ Todas las tablas están migradas!" -ForegroundColor Green
} else {
    Write-Host "`n✗ Faltan $($faltantes.Count) tablas" -ForegroundColor Red
}

