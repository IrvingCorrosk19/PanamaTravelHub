# Script para verificar el estado de la sincronización
$env:PGPASSWORD="BhC1OtUf9WBxSKUrWksobwH8jwNYAmKT"
$psql = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$connArgs = @("-h", "dpg-d5efvg7pm1nc73a63qqg-a.virginia-postgres.render.com", "-p", "5432", "-U", "panamatravelhub_2juu_user", "-d", "panamatravelhub_2juu")

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Verificando Sincronización de Render" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verificar tablas
Write-Host "Tablas nuevas:" -ForegroundColor Yellow
& $psql $connArgs -t -A -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('media_files', 'pages', 'countries', 'sms_notifications') ORDER BY table_name;" | ForEach-Object { if ($_.Trim()) { Write-Host "  [OK] $_" -ForegroundColor Green } }

Write-Host ""

# Verificar columnas en tours
Write-Host "Columnas en tours:" -ForegroundColor Yellow
& $psql $connArgs -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_name = 'tours' AND column_name IN ('tour_date', 'includes') ORDER BY column_name;" | ForEach-Object { if ($_.Trim()) { Write-Host "  [OK] $_" -ForegroundColor Green } }

Write-Host ""

# Verificar columnas en home_page_content
Write-Host "Columnas en home_page_content:" -ForegroundColor Yellow
& $psql $connArgs -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_name = 'home_page_content' AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social', 'hero_image_url') ORDER BY column_name;" | ForEach-Object { if ($_.Trim()) { Write-Host "  [OK] $_" -ForegroundColor Green } }

Write-Host ""

# Verificar columna en bookings
Write-Host "Columnas en bookings:" -ForegroundColor Yellow
& $psql $connArgs -t -A -c "SELECT column_name FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'country_id';" | ForEach-Object { if ($_.Trim()) { Write-Host "  [OK] $_" -ForegroundColor Green } }

Write-Host ""

# Verificar países
Write-Host "Países insertados:" -ForegroundColor Yellow
$count = & $psql $connArgs -t -A -c "SELECT COUNT(*) FROM countries;"
if ($count -and [int]$count.Trim() -gt 0) {
    Write-Host "  [OK] $($count.Trim()) paises" -ForegroundColor Green
} else {
    Write-Host "  [ERROR] No hay paises" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Verificación completada" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue

