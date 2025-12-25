# Script PowerShell para verificar tablas y usuarios en PostgreSQL
# Uso: .\scripts\verify-all-tables-and-users.ps1

$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
$dbHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$dbUser = "panamatravelhub_user"
$dbName = "panamatravelhub"
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

Write-Host "=== Verificando Tablas y Usuarios ===" -ForegroundColor Cyan
Write-Host ""

# Verificar tablas requeridas
Write-Host "1. Verificando tablas requeridas..." -ForegroundColor Yellow
$query = @"
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND table_name IN (
        'users', 'roles', 'user_roles',
        'tours', 'tour_images', 'tour_dates',
        'bookings', 'booking_participants',
        'payments',
        'email_notifications',
        'sms_notifications',
        'audit_logs',
        'home_page_content',
        'refresh_tokens',
        'password_reset_tokens',
        'media_files',
        'pages',
        'countries',
        'data_protection_keys'
    )
ORDER BY table_name;
"@

$tables = & $psqlPath -h $dbHost -U $dbUser -d $dbName -t -c $query
Write-Host $tables

# Verificar campos de logo
Write-Host "`n2. Verificando campos de logo..." -ForegroundColor Yellow
$logoQuery = @"
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'home_page_content' 
    AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social');
"@
$logoFields = & $psqlPath -h $dbHost -U $dbUser -d $dbName -t -c $logoQuery
Write-Host $logoFields

# Verificar campo country_id en bookings
Write-Host "`n3. Verificando campo country_id en bookings..." -ForegroundColor Yellow
$countryQuery = @"
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'bookings' AND column_name = 'country_id';
"@
$countryField = & $psqlPath -h $dbHost -U $dbUser -d $dbName -t -c $countryQuery
Write-Host $countryField

# Verificar usuarios
Write-Host "`n4. Verificando usuarios de prueba..." -ForegroundColor Yellow
$usersQuery = @"
SELECT 
    u.email,
    u.first_name || ' ' || u.last_name as nombre,
    STRING_AGG(r.name, ', ') as roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.email, u.first_name, u.last_name
ORDER BY u.email;
"@
$users = & $psqlPath -h $dbHost -U $dbUser -d $dbName -c $usersQuery
Write-Host $users

# Contar registros en tablas clave
Write-Host "`n5. Contando registros..." -ForegroundColor Yellow
$countQuery = @"
SELECT 'users' as tabla, COUNT(*) as total FROM users
UNION ALL SELECT 'countries', COUNT(*) FROM countries
UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL SELECT 'pages', COUNT(*) FROM pages;
"@
$counts = & $psqlPath -h $dbHost -U $dbUser -d $dbName -c $countQuery
Write-Host $counts

Write-Host "`n=== Verificación Completa ===" -ForegroundColor Green

