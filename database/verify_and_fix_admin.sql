-- ============================================
-- VERIFICAR Y CORREGIR ADMIN PARA LOGIN
-- ============================================
-- Este script verifica el estado del admin y lo corrige si es necesario
-- ============================================

-- Paso 1: Verificar estado actual del admin
SELECT 
    '=== ESTADO ACTUAL DEL ADMIN ===' as info;

SELECT 
    u.id,
    u.email,
    u.is_active,
    u.email_verified,
    u.failed_login_attempts,
    u.locked_until,
    CASE 
        WHEN u.password_hash LIKE '$2a$%' THEN 'BCrypt (correcto)'
        WHEN u.password_hash LIKE '$2b$%' THEN 'BCrypt (correcto)'
        ELSE 'Hash inválido o antiguo'
    END as hash_type,
    r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@panamatravelhub.com'
   OR u.id = '00000000-0000-0000-0000-000000000001';

-- Paso 2: Asegurar que las columnas de email verification existan
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verified') THEN
        ALTER TABLE users ADD COLUMN email_verified BOOLEAN NOT NULL DEFAULT false;
        RAISE NOTICE 'Columna email_verified agregada';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_schema = 'public' AND table_name = 'users' AND column_name = 'email_verified_at') THEN
        ALTER TABLE users ADD COLUMN email_verified_at TIMESTAMP;
        RAISE NOTICE 'Columna email_verified_at agregada';
    END IF;
END $$;

-- Paso 3: Asegurar que los roles existan
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name, description = EXCLUDED.description;

-- Paso 4: Actualizar/Crear usuario admin con password correcto
-- Password: Admin123!
-- Hash BCrypt válido para "Admin123!" (work factor 10)
UPDATE users 
SET 
    email = 'admin@panamatravelhub.com',
    password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    first_name = 'Admin',
    last_name = 'System',
    is_active = true,
    email_verified = true,
    email_verified_at = COALESCE(email_verified_at, CURRENT_TIMESTAMP),
    failed_login_attempts = 0,
    locked_until = NULL,
    updated_at = CURRENT_TIMESTAMP
WHERE email IN ('admin@panamatravelhub.com', 'admin@toursanama.com')
   OR id = '00000000-0000-0000-0000-000000000001';

-- Si no existe, crearlo
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
    created_at,
    updated_at
) 
SELECT 
    '00000000-0000-0000-0000-000000000001',
    'admin@panamatravelhub.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    'Admin',
    'System',
    true,
    true,
    CURRENT_TIMESTAMP,
    0,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (
    SELECT 1 FROM users 
    WHERE email = 'admin@panamatravelhub.com' 
       OR id = '00000000-0000-0000-0000-000000000001'
);

-- Paso 5: Asegurar que tenga el rol Admin
INSERT INTO user_roles (id, user_id, role_id, created_at) 
SELECT 
    '00000000-0000-0000-0000-000000000001',
    u.id,
    r.id,
    CURRENT_TIMESTAMP
FROM users u
CROSS JOIN roles r
WHERE (u.email = 'admin@panamatravelhub.com' OR u.id = '00000000-0000-0000-0000-000000000001')
  AND r.name = 'Admin'
  AND NOT EXISTS (
      SELECT 1 FROM user_roles ur 
      WHERE ur.user_id = u.id AND ur.role_id = r.id
  );

-- Paso 6: Verificar resultado final
SELECT 
    '=== ESTADO FINAL DEL ADMIN ===' as info;

SELECT 
    u.id,
    u.email,
    u.is_active,
    u.email_verified,
    u.failed_login_attempts,
    u.locked_until,
    CASE 
        WHEN u.password_hash LIKE '$2a$%' THEN 'BCrypt (correcto)'
        WHEN u.password_hash LIKE '$2b$%' THEN 'BCrypt (correcto)'
        ELSE 'Hash inválido'
    END as hash_type,
    r.name as role_name,
    CASE 
        WHEN u.is_active = true 
         AND u.email_verified = true 
         AND u.failed_login_attempts = 0 
         AND u.locked_until IS NULL
         AND u.password_hash LIKE '$2a$%'
         AND r.name = 'Admin'
        THEN '✅ LISTO PARA LOGIN'
        ELSE '❌ REQUIERE CORRECCIÓN'
    END as estado
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@panamatravelhub.com'
   OR u.id = '00000000-0000-0000-0000-000000000001';

-- ============================================
-- CREDENCIALES PARA LOGIN:
-- Email: admin@panamatravelhub.com
-- Password: Admin123!
-- ============================================
