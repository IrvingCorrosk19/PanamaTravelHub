-- Migration: AddPasswordResetTokens
-- Description: Crea la tabla password_reset_tokens para el sistema de recuperación de contraseña
-- Execute this script directly in your Render PostgreSQL database

-- Crear tabla password_reset_tokens
CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    token VARCHAR(500) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT false,
    used_at TIMESTAMP,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_password_reset_tokens_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) 
        ON DELETE CASCADE
);

-- Crear índices para optimizar búsquedas
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id 
    ON password_reset_tokens(user_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_password_reset_tokens_token 
    ON password_reset_tokens(token);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_valid 
    ON password_reset_tokens(token, is_used, expires_at);

-- Comentarios para documentación
COMMENT ON TABLE password_reset_tokens IS 'Tokens para recuperación de contraseña. Expiran en 15 minutos y son de un solo uso.';
COMMENT ON COLUMN password_reset_tokens.token IS 'Token único (UUID sin guiones) para resetear contraseña';
COMMENT ON COLUMN password_reset_tokens.expires_at IS 'Fecha y hora de expiración del token (15 minutos desde creación)';
COMMENT ON COLUMN password_reset_tokens.is_used IS 'Indica si el token ya fue utilizado (un solo uso)';
COMMENT ON COLUMN password_reset_tokens.used_at IS 'Fecha y hora en que se utilizó el token';
