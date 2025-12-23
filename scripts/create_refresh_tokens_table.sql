-- Script para crear la tabla refresh_tokens
-- Ejecutar este script en la base de datos PostgreSQL

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

-- Índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_active ON refresh_tokens(user_id, is_revoked, expires_at);

-- Comentarios
COMMENT ON TABLE refresh_tokens IS 'Almacena refresh tokens para autenticación JWT';
COMMENT ON COLUMN refresh_tokens.token IS 'Token único de refresh';
COMMENT ON COLUMN refresh_tokens.expires_at IS 'Fecha de expiración del token';
COMMENT ON COLUMN refresh_tokens.is_revoked IS 'Indica si el token ha sido revocado';
COMMENT ON COLUMN refresh_tokens.replaced_by_token IS 'Token que reemplazó a este (rotación de tokens)';

