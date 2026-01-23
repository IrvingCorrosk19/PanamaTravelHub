-- ============================================
-- ACTUALIZACIÓN: Tabla users
-- Agregar columnas de verificación de email
-- ============================================

-- Agregar columnas si no existen
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'email_verified') THEN
        ALTER TABLE users 
        ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT false;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'email_verified_at') THEN
        ALTER TABLE users 
        ADD COLUMN email_verified_at TIMESTAMP;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'email_verification_token') THEN
        ALTER TABLE users 
        ADD COLUMN email_verification_token VARCHAR(100);
    END IF;
END $$;

-- Crear índice para email_verification_token si no existe
CREATE INDEX IF NOT EXISTS idx_users_email_verification_token ON users(email_verification_token);

-- Comentarios
COMMENT ON COLUMN users.email_verified IS 'Indica si el email del usuario ha sido verificado';
COMMENT ON COLUMN users.email_verified_at IS 'Fecha y hora en que se verificó el email';
COMMENT ON COLUMN users.email_verification_token IS 'Token único para verificación de email';
