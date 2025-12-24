-- ============================================
-- INSERTAR USUARIO DE PRUEBA
-- ============================================
-- Email: prueba@correo.com
-- Contraseña: 123456
-- ============================================

-- Asegurar que los roles existan
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Insertar usuario de prueba
-- Hash BCrypt para contraseña "123456": $2a$11$4/T43PpF.hoGfrg01UH7deYkMR4sEL2WK0bsf./VFPrQqSrfG44o6
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, created_at) VALUES
    (
        gen_random_uuid(),
        'prueba@correo.com',
        '$2a$11$4/T43PpF.hoGfrg01UH7deYkMR4sEL2WK0bsf./VFPrQqSrfG44o6', -- Hash BCrypt para "123456"
        'Usuario',
        'Prueba',
        true,
        CURRENT_TIMESTAMP
    )
ON CONFLICT (email) DO UPDATE
SET 
    password_hash = EXCLUDED.password_hash,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active,
    updated_at = CURRENT_TIMESTAMP;

-- Asignar rol Customer al usuario de prueba
-- Primero obtener el ID del usuario y del rol Customer
INSERT INTO user_roles (id, user_id, role_id, created_at)
SELECT 
    gen_random_uuid(),
    u.id,
    r.id,
    CURRENT_TIMESTAMP
FROM users u
CROSS JOIN roles r
WHERE u.email = 'prueba@correo.com'
  AND r.name = 'Customer'
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Verificar que el usuario fue insertado correctamente
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.is_active,
    r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'prueba@correo.com';

