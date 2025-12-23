# ============================================
# Script para crear tabla refresh_tokens en Render
# Ejecutar desde PowerShell: .\scripts\crear-refresh-tokens.ps1
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Crear tabla refresh_tokens en Render" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuración de conexión
$env:PGPASSWORD = 'YFxc28DdPtabZS11XfVxywP5SnS53yZP'
$dbHost = 'dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com'
$dbUser = 'panamatravelhub_user'
$dbName = 'panamatravelhub'
$psqlPath = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'

# Verificar que psql existe
if (-not (Test-Path $psqlPath)) {
    Write-Host "❌ ERROR: No se encontró psql.exe en: $psqlPath" -ForegroundColor Red
    Write-Host "Por favor, verifica la ruta de instalación de PostgreSQL" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ psql encontrado: $psqlPath" -ForegroundColor Green
Write-Host ""

# Paso 1: Verificar si la tabla ya existe
Write-Host "Paso 1: Verificando si la tabla ya existe..." -ForegroundColor Yellow
$checkSql = "SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'refresh_tokens') THEN 'EXISTS' ELSE 'NOT_EXISTS' END;"
$checkResult = $checkSql | & $psqlPath -h $dbHost -U $dbUser -d $dbName -t -A 2>&1

if ($checkResult -match 'EXISTS') {
    Write-Host "⚠️  La tabla refresh_tokens ya existe" -ForegroundColor Yellow
    $response = Read-Host "¿Deseas eliminarla y recrearla? (S/N)"
    if ($response -eq 'S' -or $response -eq 's') {
        Write-Host "Eliminando tabla existente..." -ForegroundColor Yellow
        $dropSql = "DROP TABLE IF EXISTS refresh_tokens CASCADE;"
        $dropResult = $dropSql | & $psqlPath -h $dbHost -U $dbUser -d $dbName 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Tabla eliminada" -ForegroundColor Green
        } else {
            Write-Host "❌ Error al eliminar tabla: $dropResult" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "Operación cancelada" -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "✅ La tabla no existe, procediendo a crearla..." -ForegroundColor Green
}
Write-Host ""

# Paso 2: Crear la tabla
Write-Host "Paso 2: Creando tabla refresh_tokens..." -ForegroundColor Yellow
$createTableSql = @"
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    is_revoked BOOLEAN NOT NULL DEFAULT false,
    revoked_at TIMESTAMP,
    replaced_by_token VARCHAR(500),
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT chk_expires_at_future CHECK (expires_at > created_at)
);
"@

$createResult = $createTableSql | & $psqlPath -h $dbHost -U $dbUser -d $dbName 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Tabla creada exitosamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al crear tabla:" -ForegroundColor Red
    Write-Host $createResult -ForegroundColor Red
    exit 1
}
Write-Host ""

# Paso 3: Crear índices
Write-Host "Paso 3: Creando índices..." -ForegroundColor Yellow
$indexesSql = @"
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_active ON refresh_tokens(user_id, is_revoked, expires_at);
"@

$indexResult = $indexesSql | & $psqlPath -h $dbHost -U $dbUser -d $dbName 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Índices creados exitosamente" -ForegroundColor Green
} else {
    Write-Host "⚠️  Advertencia al crear índices:" -ForegroundColor Yellow
    Write-Host $indexResult -ForegroundColor Yellow
}
Write-Host ""

# Paso 4: Verificar creación
Write-Host "Paso 4: Verificando creación..." -ForegroundColor Yellow
$verifySql = @"
SELECT 
    'refresh_tokens' as table_name,
    COUNT(*) as column_count,
    (SELECT COUNT(*) FROM pg_indexes WHERE tablename = 'refresh_tokens') as index_count
FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'refresh_tokens';
"@

$verifyResult = $verifySql | & $psqlPath -h $dbHost -U $dbUser -d $dbName -t -A 2>&1

if ($verifyResult -match 'refresh_tokens') {
    Write-Host "✅ Verificación exitosa" -ForegroundColor Green
    Write-Host "Resultado: $verifyResult" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  No se pudo verificar la creación" -ForegroundColor Yellow
    Write-Host "Resultado: $verifyResult" -ForegroundColor Yellow
}
Write-Host ""

# Resumen final
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ PROCESO COMPLETADO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "La tabla refresh_tokens ha sido creada en la base de datos de Render" -ForegroundColor Green
Write-Host ""

