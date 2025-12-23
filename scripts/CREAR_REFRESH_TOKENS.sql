-- ============================================
-- SCRIPT PARA CREAR TABLA refresh_tokens
-- Ejecutar en la base de datos de Render
-- ============================================

-- Paso 1: Crear la tabla
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

-- Paso 2: Crear índices
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_active ON refresh_tokens(user_id, is_revoked, expires_at);

-- Paso 3: Verificar creación
SELECT 
    'Tabla creada exitosamente' as status,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'refresh_tokens') as column_count
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name = 'refresh_tokens';

