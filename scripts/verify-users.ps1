# Script para verificar usuarios en la base de datos
$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$dbHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$dbUser = "panamatravelhub_user"
$database = "panamatravelhub"

Write-Host "`n=== ROLES ===" -ForegroundColor Cyan
& $psqlPath -h $dbHost -U $dbUser -d $database -c "SELECT id, name, description FROM roles ORDER BY name;"

Write-Host "`n=== USUARIOS ===" -ForegroundColor Cyan
& $psqlPath -h $dbHost -U $dbUser -d $database -c "SELECT u.id, u.email, u.first_name, u.last_name, u.is_active, r.name as role_name FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id ORDER BY u.email;"

Write-Host "`n=== RESUMEN DE USUARIOS ===" -ForegroundColor Green
& $psqlPath -h $dbHost -U $dbUser -d $database -c "SELECT COUNT(*) as total_usuarios FROM users;"

Read-Host "`nPresiona Enter para continuar"

