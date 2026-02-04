# ============================================
# Asignar rol Admin al usuario admin@panamatravelhub.com
# ============================================
# Ejecutar desde la raíz del proyecto: .\database\fix-admin-role.ps1
# ============================================

$dbHost = "localhost"
$dbPort = "5432"
$dbName = "PanamaTravelHub"
$dbUser = "postgres"
$dbPass = "Panama2020$"

$sql = @"
-- Asegurar que exista el rol Admin
INSERT INTO roles (id, name, description, created_at) 
VALUES ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET name = 'Admin';

-- Asignar rol Admin al usuario admin@panamatravelhub.com
INSERT INTO user_roles (id, user_id, role_id, created_at) 
SELECT 
    gen_random_uuid(),
    u.id,
    r.id,
    CURRENT_TIMESTAMP
FROM users u
CROSS JOIN roles r
WHERE u.email = 'admin@panamatravelhub.com'
  AND r.name = 'Admin'
  AND NOT EXISTS (
    SELECT 1 FROM user_roles ur 
    WHERE ur.user_id = u.id AND ur.role_id = r.id
  );

-- Verificar resultado
SELECT u.email, r.name as rol 
FROM users u 
LEFT JOIN user_roles ur ON u.id = ur.user_id 
LEFT JOIN roles r ON ur.role_id = r.id 
WHERE u.email = 'admin@panamatravelhub.com';
"@

Write-Host "Asignando rol Admin a admin@panamatravelhub.com..." -ForegroundColor Cyan
$env:PGPASSWORD = $dbPass
$psql = "psql"
if (Test-Path "C:\Program Files\PostgreSQL\18\bin\psql.exe") { $psql = "C:\Program Files\PostgreSQL\18\bin\psql.exe" }
elseif (Test-Path "C:\Program Files\PostgreSQL\16\bin\psql.exe") { $psql = "C:\Program Files\PostgreSQL\16\bin\psql.exe" }
elseif (Test-Path "C:\Program Files\PostgreSQL\15\bin\psql.exe") { $psql = "C:\Program Files\PostgreSQL\15\bin\psql.exe" }

try {
    $sql | & $psql -h $dbHost -p $dbPort -U $dbUser -d $dbName 2>&1
    Write-Host "`nListo. Cierra sesion, vuelve a iniciar sesion con admin@panamatravelhub.com / Admin123! y entra a /admin.html" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "`nEjecuta manualmente el SQL en pgAdmin o psql:" -ForegroundColor Yellow
    Write-Host $sql
}
