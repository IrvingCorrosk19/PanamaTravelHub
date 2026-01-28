# Script para arreglar login de administrador y verificar blog
$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

$dbName = "panamatravelhub_db"
$dbUser = "panamatravelhub_user"
$container = "panamatravelhub_postgres"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ARREGLAR ADMIN Y VERIFICAR BLOG" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# PASO 1: Verificar usuarios existentes
Write-Host "PASO 1: Verificando usuarios en la base de datos..." -ForegroundColor Yellow
$cmdUsers = "docker exec $container psql -U $dbUser -d $dbName -c 'SELECT u.id, u.email, u.first_name, u.last_name, u.is_active, r.name as role FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id ORDER BY u.created_at;' 2>&1"
$resultUsers = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdUsers 2>&1
Write-Host $resultUsers
Write-Host ""

# PASO 2: Verificar si existe el usuario admin
Write-Host "PASO 2: Verificando usuario admin@panamatravelhub.com..." -ForegroundColor Yellow
$cmdCheckAdmin = "docker exec $container psql -U $dbUser -d $dbName -t -A -c 'SELECT COUNT(*) FROM users u INNER JOIN user_roles ur ON u.id = ur.user_id INNER JOIN roles r ON ur.role_id = r.id WHERE u.email = ''admin@panamatravelhub.com'' AND r.name = ''Admin'';' 2>&1"
$resultCheckAdmin = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdCheckAdmin 2>&1
$adminExists = [int]($resultCheckAdmin -replace '\s', '')

if ($adminExists -eq 0) {
    Write-Host "⚠️  Usuario admin no encontrado o sin rol Admin. Creando/actualizando..." -ForegroundColor Yellow
    
    # Script SQL para crear/actualizar admin
    $adminSQL = @"
-- Verificar/crear usuario admin
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, email_verified, created_at, updated_at)
VALUES (
    '24e8864d-7bbf-4fdf-b59a-0cfa3b882386',
    'admin@panamatravelhub.com',
    '\$2a\$12\$gpmcPqtakrNDl29T9mDeqOjzeVjACvG/RRyjAdxH3.u58TZG6g8yS', -- Password: Admin123!
    'Administrador',
    'Sistema',
    true,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = true,
    email_verified = true,
    updated_at = CURRENT_TIMESTAMP;

-- Asignar rol Admin
INSERT INTO user_roles (id, user_id, role_id, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    '24e8864d-7bbf-4fdf-b59a-0cfa3b882386',
    r.id,
    CURRENT_TIMESTAMP,
    NULL
FROM roles r
WHERE r.name = 'Admin'
ON CONFLICT (user_id, role_id) DO UPDATE SET
    updated_at = CURRENT_TIMESTAMP;

-- Asegurar que el usuario tenga solo el rol Admin (eliminar otros roles si existen)
DELETE FROM user_roles 
WHERE user_id = '24e8864d-7bbf-4fdf-b59a-0cfa3b882386' 
  AND role_id NOT IN (SELECT id FROM roles WHERE name = 'Admin');
"@

    # Copiar script al servidor
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($adminSQL)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $tempScript = "fix_admin_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
    $remoteScriptPath = "/tmp/$tempScript"

    $cmdCopy = "echo '$base64' | base64 -d > $remoteScriptPath"
    $resultCopy = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdCopy 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Script copiado al servidor" -ForegroundColor Green
        
        # Ejecutar script
        $cmdExec = "docker exec -i $container psql -U $dbUser -d $dbName < $remoteScriptPath 2>&1"
        $resultExec = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdExec 2>&1
        Write-Host $resultExec
        
        # Limpiar
        $cmdClean = "rm -f $remoteScriptPath"
        & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdClean 2>&1 | Out-Null
        
        Write-Host "✅ Usuario admin creado/actualizado" -ForegroundColor Green
    } else {
        Write-Host "❌ Error al copiar script" -ForegroundColor Red
    }
} else {
    Write-Host "✅ Usuario admin ya existe con rol Admin" -ForegroundColor Green
}
Write-Host ""

# PASO 3: Verificar credenciales del admin
Write-Host "PASO 3: Verificando credenciales del admin..." -ForegroundColor Yellow
Write-Host "Email: admin@panamatravelhub.com" -ForegroundColor White
Write-Host "Password: Admin123!" -ForegroundColor White
Write-Host ""

# PASO 4: Verificar blog - contar posts
Write-Host "PASO 4: Verificando posts de blog..." -ForegroundColor Yellow
$cmdBlogCount = "docker exec $container psql -U $dbUser -d $dbName -t -A -c 'SELECT COUNT(*) FROM pages WHERE (template = ''Blog'' OR template = ''blog'' OR template IS NULL) AND is_published = true AND published_at IS NOT NULL AND published_at <= NOW();' 2>&1"
$resultBlogCount = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdBlogCount 2>&1
$blogCount = [int]($resultBlogCount -replace '\s', '')

Write-Host "Posts de blog publicados: $blogCount" -ForegroundColor Cyan

if ($blogCount -eq 0) {
    Write-Host "⚠️  No hay posts de blog publicados" -ForegroundColor Yellow
    Write-Host "   El blog necesita posts en la tabla 'pages' con:" -ForegroundColor Gray
    Write-Host "   - template = 'Blog' o NULL" -ForegroundColor Gray
    Write-Host "   - is_published = true" -ForegroundColor Gray
    Write-Host "   - published_at <= NOW()" -ForegroundColor Gray
    Write-Host ""
    
    # Verificar si hay posts sin publicar
    $cmdUnpublished = "docker exec $container psql -U $dbUser -d $dbName -t -A -c 'SELECT COUNT(*) FROM pages WHERE (template = ''Blog'' OR template = ''blog'' OR template IS NULL);' 2>&1"
    $resultUnpublished = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdUnpublished 2>&1
    $totalPosts = [int]($resultUnpublished -replace '\s', '')
    
    if ($totalPosts -gt 0) {
        Write-Host "   Se encontraron $totalPosts posts pero no están publicados" -ForegroundColor Yellow
        Write-Host "   Necesitas publicarlos desde el panel de administración" -ForegroundColor Gray
    } else {
        Write-Host "   No hay posts de blog en la base de datos" -ForegroundColor Yellow
        Write-Host "   Necesitas crear posts desde el panel de administración" -ForegroundColor Gray
    }
} else {
    Write-Host "✅ Hay $blogCount posts de blog publicados" -ForegroundColor Green
    
    # Mostrar algunos posts
    $cmdBlogPosts = "docker exec $container psql -U $dbUser -d $dbName -c 'SELECT id, title, slug, is_published, published_at FROM pages WHERE (template = ''Blog'' OR template = ''blog'' OR template IS NULL) AND is_published = true ORDER BY published_at DESC LIMIT 5;' 2>&1"
    $resultBlogPosts = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdBlogPosts 2>&1
    Write-Host ""
    Write-Host "Últimos posts:" -ForegroundColor Cyan
    Write-Host $resultBlogPosts
}
Write-Host ""

# PASO 5: Verificar estructura de la tabla pages
Write-Host "PASO 5: Verificando estructura de la tabla pages..." -ForegroundColor Yellow
$cmdTable = "docker exec $container psql -U $dbUser -d $dbName -c '\d pages' 2>&1"
$resultTable = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdTable 2>&1
if ($resultTable -match "template|is_published|published_at") {
    Write-Host "✅ Tabla pages tiene las columnas necesarias" -ForegroundColor Green
} else {
    Write-Host "⚠️  Verificando columnas de la tabla pages..." -ForegroundColor Yellow
    Write-Host $resultTable
}
Write-Host ""

# PASO 6: Verificar roles
Write-Host "PASO 6: Verificando roles en la base de datos..." -ForegroundColor Yellow
$cmdRoles = "docker exec $container psql -U $dbUser -d $dbName -c 'SELECT id, name, description FROM roles;' 2>&1"
$resultRoles = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdRoles 2>&1
Write-Host $resultRoles
Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para iniciar sesión como administrador:" -ForegroundColor Green
Write-Host "  Email: admin@panamatravelhub.com" -ForegroundColor White
Write-Host "  Password: Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "URLs:" -ForegroundColor Green
Write-Host "  - Login: https://travel.autonomousflow.lat/login.html" -ForegroundColor White
Write-Host "  - Admin: https://travel.autonomousflow.lat/admin.html" -ForegroundColor White
Write-Host "  - Blog: https://travel.autonomousflow.lat/blog.html" -ForegroundColor White
Write-Host ""
Write-Host "Si el blog no funciona:" -ForegroundColor Yellow
Write-Host "  1. Inicia sesión como admin" -ForegroundColor Gray
Write-Host "  2. Ve al panel de administración" -ForegroundColor Gray
Write-Host "  3. Crea posts de blog y publícalos" -ForegroundColor Gray
Write-Host ""
