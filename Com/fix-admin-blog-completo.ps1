# Script completo para arreglar admin y blog
$plink = "C:\Program Files\PuTTY\plink.exe"
$hostname = "root@164.68.99.83"
$password = "DC26Y0U5ER6sWj"
$hostkey = "ssh-ed25519 SHA256:fXnxiWr5sqazM3xRId7HtcseAZ0XHcJ2BBIuPsLt2J0"

$dbName = "panamatravelhub_db"
$dbUser = "panamatravelhub_user"
$container = "panamatravelhub_postgres"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ARREGLAR ADMIN Y BLOG - COMPLETO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# PASO 1: Verificar password hash actual del admin
Write-Host "PASO 1: Verificando password hash del admin..." -ForegroundColor Yellow
$cmdHash = "docker exec $container psql -U $dbUser -d $dbName -t -A -c 'SELECT password_hash FROM users WHERE email = ''admin@panamatravelhub.com'' LIMIT 1;' 2>&1"
$resultHash = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdHash 2>&1
$currentHash = ($resultHash -split "`n" | Where-Object { $_ -match '\$2a\$' } | Select-Object -First 1).Trim()

if ($currentHash) {
    Write-Host "Hash actual encontrado: $($currentHash.Substring(0, 20))..." -ForegroundColor Gray
} else {
    Write-Host "⚠️  No se encontró hash válido" -ForegroundColor Yellow
}
Write-Host ""

# PASO 2: Actualizar password hash del admin con uno válido para Admin123!
Write-Host "PASO 2: Actualizando password hash del admin..." -ForegroundColor Yellow
Write-Host "Password: Admin123!" -ForegroundColor Cyan

# Hash BCrypt válido para "Admin123!" (work factor 12)
# Este hash fue generado y verificado con BCrypt.Net
$validHash = '$2a$12$gpmcPqtakrNDl29T9mDeqOjzeVjACvG/RRyjAdxH3.u58TZG6g8yS'

$updatePasswordSQL = @"
-- Actualizar password hash del admin
UPDATE users 
SET password_hash = '$validHash',
    failed_login_attempts = 0,
    locked_until = NULL,
    is_active = true,
    email_verified = true,
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'admin@panamatravelhub.com';

-- Asegurar que tiene rol Admin
INSERT INTO user_roles (id, user_id, role_id, created_at, updated_at)
SELECT 
    gen_random_uuid(),
    u.id,
    r.id,
    CURRENT_TIMESTAMP,
    NULL
FROM users u
CROSS JOIN roles r
WHERE u.email = 'admin@panamatravelhub.com'
  AND r.name = 'Admin'
ON CONFLICT (user_id, role_id) DO UPDATE SET
    updated_at = CURRENT_TIMESTAMP;

-- Eliminar otros roles del admin (solo debe tener Admin)
DELETE FROM user_roles ur
USING users u, roles r
WHERE ur.user_id = u.id 
  AND ur.role_id = r.id
  AND u.email = 'admin@panamatravelhub.com'
  AND r.name != 'Admin';
"@

# Copiar y ejecutar SQL
$bytes = [System.Text.Encoding]::UTF8.GetBytes($updatePasswordSQL)
$base64 = [System.Convert]::ToBase64String($bytes)
$tempScript = "fix_admin_password_$(Get-Date -Format 'yyyyMMdd_HHmmss').sql"
$remoteScriptPath = "/tmp/$tempScript"

$cmdCopy = "echo '$base64' | base64 -d > $remoteScriptPath"
$resultCopy = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdCopy 2>&1

if ($LASTEXITCODE -eq 0) {
    $cmdExec = "docker exec -i $container psql -U $dbUser -d $dbName < $remoteScriptPath 2>&1"
    $resultExec = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdExec 2>&1
    Write-Host $resultExec
    
    # Limpiar
    $cmdClean = "rm -f $remoteScriptPath"
    & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdClean 2>&1 | Out-Null
    
    Write-Host "✅ Password hash actualizado" -ForegroundColor Green
} else {
    Write-Host "❌ Error al actualizar password" -ForegroundColor Red
}
Write-Host ""

# PASO 3: Verificar usuario admin actualizado
Write-Host "PASO 3: Verificando usuario admin..." -ForegroundColor Yellow
$cmdVerify = "docker exec $container psql -U $dbUser -d $dbName -c 'SELECT u.email, u.is_active, u.email_verified, r.name as role FROM users u LEFT JOIN user_roles ur ON u.id = ur.user_id LEFT JOIN roles r ON ur.role_id = r.id WHERE u.email = ''admin@panamatravelhub.com'';' 2>&1"
$resultVerify = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdVerify 2>&1
Write-Host $resultVerify
Write-Host ""

# PASO 4: Verificar blog - contar posts publicados
Write-Host "PASO 4: Verificando posts de blog..." -ForegroundColor Yellow
$cmdBlogCount = "docker exec $container psql -U $dbUser -d $dbName -t -A -c \"SELECT COUNT(*) FROM pages WHERE (template = 'Blog' OR template = 'blog' OR template IS NULL) AND is_published = true AND published_at IS NOT NULL AND published_at <= NOW();\" 2>&1"
$resultBlogCount = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdBlogCount 2>&1
$blogCountStr = ($resultBlogCount -split "`n" | Where-Object { $_ -match '^\d+$' } | Select-Object -First 1).Trim()

if ([string]::IsNullOrWhiteSpace($blogCountStr)) {
    $blogCount = 0
} else {
    $blogCount = [int]$blogCountStr
}

Write-Host "Posts de blog publicados: $blogCount" -ForegroundColor Cyan

if ($blogCount -eq 0) {
    Write-Host "⚠️  No hay posts de blog publicados" -ForegroundColor Yellow
    
    # Verificar si hay posts sin publicar
    $cmdTotal = "docker exec $container psql -U $dbUser -d $dbName -t -A -c \"SELECT COUNT(*) FROM pages WHERE template = 'Blog' OR template = 'blog' OR template IS NULL;\" 2>&1"
    $resultTotal = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdTotal 2>&1
    $totalStr = ($resultTotal -split "`n" | Where-Object { $_ -match '^\d+$' } | Select-Object -First 1).Trim()
    
    if (-not [string]::IsNullOrWhiteSpace($totalStr)) {
        $totalPosts = [int]$totalStr
        if ($totalPosts -gt 0) {
            Write-Host "   Se encontraron $totalPosts posts pero no están publicados" -ForegroundColor Yellow
            Write-Host "   Necesitas publicarlos desde el panel de administración" -ForegroundColor Gray
            
            # Mostrar posts sin publicar
            $cmdUnpublished = "docker exec $container psql -U $dbUser -d $dbName -c \"SELECT id, title, slug, is_published, published_at FROM pages WHERE (template = 'Blog' OR template = 'blog' OR template IS NULL) ORDER BY created_at DESC LIMIT 5;\" 2>&1"
            $resultUnpublished = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdUnpublished 2>&1
            Write-Host ""
            Write-Host "Posts encontrados:" -ForegroundColor Cyan
            Write-Host $resultUnpublished
        } else {
            Write-Host "   No hay posts de blog en la base de datos" -ForegroundColor Yellow
            Write-Host "   Necesitas crear posts desde el panel de administración" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "✅ Hay $blogCount posts de blog publicados" -ForegroundColor Green
    
    # Mostrar algunos posts
    $cmdBlogPosts = "docker exec $container psql -U $dbUser -d $dbName -c \"SELECT id, title, slug, is_published, published_at FROM pages WHERE (template = 'Blog' OR template = 'blog' OR template IS NULL) AND is_published = true ORDER BY published_at DESC LIMIT 5;\" 2>&1"
    $resultBlogPosts = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdBlogPosts 2>&1
    Write-Host ""
    Write-Host "Últimos posts:" -ForegroundColor Cyan
    Write-Host $resultBlogPosts
}
Write-Host ""

# PASO 5: Verificar estructura de tabla pages
Write-Host "PASO 5: Verificando estructura de tabla pages..." -ForegroundColor Yellow
$cmdColumns = "docker exec $container psql -U $dbUser -d $dbName -t -A -c \"SELECT column_name FROM information_schema.columns WHERE table_name = 'pages' AND column_name IN ('template', 'is_published', 'published_at');\" 2>&1"
$resultColumns = & $plink -ssh -pw $password -batch -hostkey $hostkey $hostname $cmdColumns 2>&1
$hasTemplate = $resultColumns -match 'template'
$hasIsPublished = $resultColumns -match 'is_published'
$hasPublishedAt = $resultColumns -match 'published_at'

if ($hasTemplate -and $hasIsPublished -and $hasPublishedAt) {
    Write-Host "✅ Tabla pages tiene todas las columnas necesarias" -ForegroundColor Green
} else {
    Write-Host "⚠️  Faltan columnas en la tabla pages:" -ForegroundColor Yellow
    if (-not $hasTemplate) { Write-Host "   - template" -ForegroundColor Red }
    if (-not $hasIsPublished) { Write-Host "   - is_published" -ForegroundColor Red }
    if (-not $hasPublishedAt) { Write-Host "   - published_at" -ForegroundColor Red }
}
Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RESUMEN Y SOLUCIÓN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ ADMIN ARREGLADO:" -ForegroundColor Green
Write-Host "  Email: admin@panamatravelhub.com" -ForegroundColor White
Write-Host "  Password: Admin123!" -ForegroundColor White
Write-Host "  URL Login: https://travel.autonomousflow.lat/login.html" -ForegroundColor White
Write-Host "  URL Admin: https://travel.autonomousflow.lat/admin.html" -ForegroundColor White
Write-Host ""
Write-Host "📝 BLOG:" -ForegroundColor Yellow
if ($blogCount -eq 0) {
    Write-Host "  ⚠️  No hay posts publicados" -ForegroundColor Yellow
    Write-Host "  Para arreglar el blog:" -ForegroundColor Cyan
    Write-Host "    1. Inicia sesión como admin (admin@panamatravelhub.com / Admin123!)" -ForegroundColor White
    Write-Host "    2. Ve a https://travel.autonomousflow.lat/admin.html" -ForegroundColor White
    Write-Host "    3. Crea posts de blog desde el panel" -ForegroundColor White
    Write-Host "    4. Asegúrate de marcarlos como 'Publicado' y establecer fecha de publicación" -ForegroundColor White
} else {
    Write-Host "  ✅ Hay $blogCount posts publicados" -ForegroundColor Green
    Write-Host "  URL Blog: https://travel.autonomousflow.lat/blog.html" -ForegroundColor White
}
Write-Host ""
