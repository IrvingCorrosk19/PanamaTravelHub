# Script para crear tabla refresh_tokens en Render
$env:PGPASSWORD = 'YFxc28DdPtabZS11XfVxywP5SnS53yZP'
$host = 'dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com'
$user = 'panamatravelhub_user'
$database = 'panamatravelhub'
$psqlPath = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'

Write-Host "Creando tabla refresh_tokens..." -ForegroundColor Green

$sql = @"
CREATE TABLE IF NOT EXISTS refresh_tokens (
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

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_active ON refresh_tokens(user_id, is_revoked, expires_at);
"@

$sql | & $psqlPath -h $host -U $user -d $database

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Tabla refresh_tokens creada exitosamente!" -ForegroundColor Green
    
    # Verificar que se creó
    Write-Host "Verificando creación..." -ForegroundColor Yellow
    $checkSql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'refresh_tokens';"
    $result = $checkSql | & $psqlPath -h $host -U $user -d $database -t -A
    
    if ($result -match 'refresh_tokens') {
        Write-Host "✅ Verificación exitosa: tabla existe" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Advertencia: No se pudo verificar la creación" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Error al crear la tabla" -ForegroundColor Red
    exit 1
}

