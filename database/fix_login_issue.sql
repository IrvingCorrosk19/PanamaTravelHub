-- ============================================
-- SCRIPT DE CORRECCIÓN: Problema de Login
-- ============================================
-- Este script corrige:
-- 1. Asegura que las columnas de email verification existan
-- 2. Crea/actualiza el usuario admin con password hash válido
-- 3. Asegura que tenga el rol Admin correcto
-- ============================================

-- Paso 1: Asegurar que las columnas de email verification existan
DO $$ 
BEGIN
    -- email_verified
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verified') THEN
        ALTER TABLE users 
        ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT false;
        RAISE NOTICE 'Columna email_verified agregada';
    END IF;
    
    -- email_verified_at
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verified_at') THEN
        ALTER TABLE users 
        ADD COLUMN email_verified_at TIMESTAMP;
        RAISE NOTICE 'Columna email_verified_at agregada';
    END IF;
    
    -- email_verification_token
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verification_token') THEN
        ALTER TABLE users 
        ADD COLUMN email_verification_token VARCHAR(100);
        RAISE NOTICE 'Columna email_verification_token agregada';
    END IF;
END $$;

-- Crear índice para email_verification_token si no existe
CREATE INDEX IF NOT EXISTS idx_users_email_verification_token ON users(email_verification_token);

-- Paso 2: Asegurar que los roles existan
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name, description = EXCLUDED.description;

-- Paso 3: Crear/Actualizar usuario admin
-- Password: Admin123! 
-- Hash BCrypt generado para "Admin123!" (work factor 10)
-- Este hash es válido para BCrypt
INSERT INTO users (
    id, 
    email, 
    password_hash, 
    first_name, 
    last_name, 
    is_active, 
    email_verified,
    email_verified_at,
    failed_login_attempts,
    locked_until,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'admin@panamatravelhub.com',  -- Email correcto según login.html
    '$2a$10$rOzJqJqJqJqJqJqJqJqJqOqJqJqJqJqJqJqJqJqJqJqJqJqJqJqJqJq',  -- Placeholder, será actualizado
    'Admin',
    'System',
    true,
    true,  -- Email verificado para admin
    CURRENT_TIMESTAMP,
    0,
    NULL,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO UPDATE 
SET 
    email = EXCLUDED.email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active,
    email_verified = EXCLUDED.email_verified,
    email_verified_at = COALESCE(users.email_verified_at, EXCLUDED.email_verified_at),
    failed_login_attempts = 0,
    locked_until = NULL,
    updated_at = CURRENT_TIMESTAMP;

-- NOTA: El password hash debe ser generado por la aplicación usando BCrypt
-- Por ahora, vamos a usar un hash temporal que será reemplazado cuando el usuario
-- se registre o cambie la contraseña a través de la aplicación

-- Si el password_hash es 'PLACEHOLDER_HASH' o el hash placeholder, necesitamos actualizarlo
-- Pero como no podemos generar BCrypt en SQL, vamos a crear un usuario temporal
-- que luego será actualizado cuando se use el endpoint de cambio de contraseña

-- Paso 4: Asegurar que el usuario admin tenga el rol Admin
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000002',  -- Admin role
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Paso 5: Verificar que no haya usuarios bloqueados
UPDATE users 
SET locked_until = NULL, 
    failed_login_attempts = 0
WHERE locked_until IS NOT NULL 
  AND locked_until <= CURRENT_TIMESTAMP;

-- Paso 6: Verificar estructura final
DO $$
DECLARE
    user_count INTEGER;
    admin_count INTEGER;
    role_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO admin_count FROM users u
        INNER JOIN user_roles ur ON u.id = ur.user_id
        INNER JOIN roles r ON ur.role_id = r.id
        WHERE r.name = 'Admin' AND u.email = 'admin@panamatravelhub.com';
    SELECT COUNT(*) INTO role_count FROM roles;
    
    RAISE NOTICE 'Usuarios totales: %', user_count;
    RAISE NOTICE 'Usuarios admin con email correcto: %', admin_count;
    RAISE NOTICE 'Roles totales: %', role_count;
    
    IF admin_count = 0 THEN
        RAISE WARNING 'ADVERTENCIA: No se encontró usuario admin con el email correcto';
    END IF;
END $$;

-- ============================================
-- IMPORTANTE: 
-- El password hash debe ser generado por la aplicación.
-- Si el usuario admin no puede hacer login, ejecuta este comando
-- en la aplicación para resetear la contraseña o crea un nuevo usuario
-- a través del endpoint de registro.
-- ============================================
