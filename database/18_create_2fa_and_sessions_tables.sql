-- ============================================
-- TABLAS: user_two_factor, login_history
-- Sistema de 2FA y Historial de Logins
-- ============================================

-- Tabla de 2FA
CREATE TABLE IF NOT EXISTS user_two_factor (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    secret_key VARCHAR(100),
    is_enabled BOOLEAN NOT NULL DEFAULT false,
    backup_codes VARCHAR(2000), -- JSON array de códigos hasheados
    phone_number VARCHAR(20),
    is_sms_enabled BOOLEAN NOT NULL DEFAULT false,
    enabled_at TIMESTAMP,
    last_used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Tabla de historial de logins
CREATE TABLE IF NOT EXISTS login_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ip_address VARCHAR(45) NOT NULL, -- IPv6 compatible
    user_agent VARCHAR(500),
    is_successful BOOLEAN NOT NULL,
    failure_reason VARCHAR(200),
    location VARCHAR(200), -- País/ciudad (opcional)
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Agregar columnas de verificación de email a users
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMP,
ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR(100);

-- Índices para user_two_factor
CREATE INDEX IF NOT EXISTS idx_user_two_factor_user_id ON user_two_factor(user_id);
CREATE INDEX IF NOT EXISTS idx_user_two_factor_is_enabled ON user_two_factor(is_enabled);

-- Índices para login_history
CREATE INDEX IF NOT EXISTS idx_login_history_user_id ON login_history(user_id);
CREATE INDEX IF NOT EXISTS idx_login_history_ip_address ON login_history(ip_address);
CREATE INDEX IF NOT EXISTS idx_login_history_created_at ON login_history(created_at);
CREATE INDEX IF NOT EXISTS idx_login_history_is_successful ON login_history(is_successful);
CREATE INDEX IF NOT EXISTS idx_login_history_user_created ON login_history(user_id, created_at);

-- Índice para email_verification_token
CREATE INDEX IF NOT EXISTS idx_users_email_verification_token ON users(email_verification_token);

-- Comentarios
COMMENT ON TABLE user_two_factor IS 'Configuración de autenticación de dos factores (2FA)';
COMMENT ON COLUMN user_two_factor.secret_key IS 'Clave secreta para TOTP (Google Authenticator)';
COMMENT ON COLUMN user_two_factor.backup_codes IS 'Códigos de respaldo hasheados (JSON array)';
COMMENT ON TABLE login_history IS 'Historial de intentos de login (exitosos y fallidos)';
COMMENT ON COLUMN users.email_verified IS 'Indica si el email del usuario ha sido verificado';
COMMENT ON COLUMN users.email_verification_token IS 'Token único para verificación de email';
