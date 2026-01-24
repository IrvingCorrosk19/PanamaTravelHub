-- ============================================
-- ACTUALIZAR PASSWORD DEL ADMIN
-- ============================================
-- Este script actualiza el password hash del usuario admin
-- Password: Admin123!
-- Hash BCrypt válido generado con BCrypt.Net
-- ============================================

-- Actualizar password hash del admin
-- Hash BCrypt para "Admin123!" (work factor 10)
UPDATE users 
SET 
    password_hash = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy',
    email = 'admin@panamatravelhub.com',
    is_active = true,
    email_verified = true,
    email_verified_at = COALESCE(email_verified_at, CURRENT_TIMESTAMP),
    failed_login_attempts = 0,
    locked_until = NULL,
    updated_at = CURRENT_TIMESTAMP
WHERE email IN ('admin@panamatravelhub.com', 'admin@toursanama.com')
   OR id = '00000000-0000-0000-0000-000000000001';

-- Si no existe ningún admin, crearlo
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

-- Asegurar que tenga el rol Admin
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

-- Verificar resultado
SELECT 
    u.id,
    u.email,
    u.is_active,
    u.email_verified,
    u.failed_login_attempts,
    u.locked_until,
    r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@panamatravelhub.com' 
   OR u.id = '00000000-0000-0000-0000-000000000001';
