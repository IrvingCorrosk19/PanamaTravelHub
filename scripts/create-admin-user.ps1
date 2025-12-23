# Script para crear usuario admin en la base de datos de Render
# Genera el hash SHA256 de la contraseña y crea el usuario

Write-Host "Generando hash de contraseña..." -ForegroundColor Green

# Contraseña del admin
$password = "Admin123!"

# Generar hash SHA256 en Base64 (igual que en AuthController)
Add-Type -AssemblyName System.Security
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($password)
$hash = $sha256.ComputeHash($bytes)
$hashBase64 = [Convert]::ToBase64String($hash)

Write-Host "Hash generado: $hashBase64" -ForegroundColor Yellow

# Credenciales de Render
$env:PGPASSWORD = "YFxc28DdPtabZS11XfVxywP5SnS53yZP"
$dbHost = "dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com"
$dbUser = "panamatravelhub_user"
$dbName = "panamatravelhub"
$psqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"

Write-Host "`nVerificando roles..." -ForegroundColor Green
& $psqlPath -h $dbHost -U $dbUser -d $dbName -c "SELECT id, name FROM roles;"

Write-Host "`nCreando usuario admin..." -ForegroundColor Green

# SQL para crear el usuario admin
$sql = @"
-- Insertar roles si no existen
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Crear usuario admin
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@toursanama.com', 
     '$hashBase64',
     'Admin', 'System', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE 
SET password_hash = '$hashBase64',
    is_active = true;

-- Asignar rol Admin
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000002', 
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Verificar que se creó
SELECT u.id, u.email, u.first_name, u.last_name, u.is_active, r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@toursanama.com';
"@

# Ejecutar SQL
$sql | & $psqlPath -h $dbHost -U $dbUser -d $dbName

Write-Host "`nUsuario admin creado/actualizado exitosamente!" -ForegroundColor Green
Write-Host "Credenciales:" -ForegroundColor Yellow
Write-Host "  Email: admin@toursanama.com" -ForegroundColor Cyan
Write-Host "  Password: Admin123!" -ForegroundColor Cyan

