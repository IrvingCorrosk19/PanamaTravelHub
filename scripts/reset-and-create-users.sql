-- ============================================
-- SCRIPT: Resetear y crear usuarios de prueba
-- ============================================
-- Este script:
-- 1. Elimina todos los usuarios existentes (y sus relaciones en cascada)
-- 2. Crea los roles Customer y Admin si no existen
-- 3. Crea 4 usuarios: 1 Admin, 1 Cliente, 2 usuarios de prueba

BEGIN;

-- ============================================
-- PASO 1: Eliminar todos los usuarios existentes
-- ============================================
-- Esto eliminará automáticamente:
-- - user_roles (ON DELETE CASCADE)
-- - bookings (si hay referencias)
-- - refresh_tokens (si hay referencias)
-- - password_reset_tokens (si hay referencias)
-- - audit_logs (si hay referencias)

DELETE FROM users;
ALTER SEQUENCE IF EXISTS users_id_seq RESTART;

-- ============================================
-- PASO 2: Crear roles si no existen
-- ============================================
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (name) DO UPDATE 
SET description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- ============================================
-- PASO 3: Crear usuarios
-- ============================================

-- Usuario 1: Admin
-- Email: admin@panamatravelhub.com
-- Password: Admin123!
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, failed_login_attempts, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     'admin@panamatravelhub.com',
     '$2a$12$Vxi3i.xYmbQAIsty5Zk0re.eLjbLtWtgUXt1DVo0hVNQMyHNykKvm', -- Admin123!
     'Administrador',
     'Sistema',
     true,
     0,
     CURRENT_TIMESTAMP);

-- Usuario 2: Cliente
-- Email: cliente@panamatravelhub.com
-- Password: Cliente123!
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, failed_login_attempts, created_at) VALUES
    ('00000000-0000-0000-0000-000000000002',
     'cliente@panamatravelhub.com',
     '$2a$12$1M7YN9qO/IP/AhBpR.al/eE7ivyyyhZnaYro81AE4Iw1lRtISB8ji', -- Cliente123!
     'Cliente',
     'Ejemplo',
     true,
     0,
     CURRENT_TIMESTAMP);

-- Usuario 3: Usuario de prueba 1
-- Email: test1@panamatravelhub.com
-- Password: Test123!
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, failed_login_attempts, created_at) VALUES
    ('00000000-0000-0000-0000-000000000003',
     'test1@panamatravelhub.com',
     '$2a$12$hlT8YCO3HeDJMGBkQjBMf.C66PhNALse0ZTUItM2bCRfXG6KKW.jq', -- Test123!
     'Test',
     'Usuario Uno',
     true,
     0,
     CURRENT_TIMESTAMP);

-- Usuario 4: Usuario de prueba 2
-- Email: test2@panamatravelhub.com
-- Password: Prueba123!
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, failed_login_attempts, created_at) VALUES
    ('00000000-0000-0000-0000-000000000004',
     'test2@panamatravelhub.com',
     '$2a$12$XRp3/rIMKoFfKZhpG9gkyuvGAwLADba7JWiZSZdKqC1DJxRaXeTl.', -- Prueba123!
     'Test',
     'Usuario Dos',
     true,
     0,
     CURRENT_TIMESTAMP);

-- ============================================
-- PASO 4: Asignar roles a los usuarios
-- ============================================

-- Asignar rol Admin al usuario admin
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001',
     '00000000-0000-0000-0000-000000000001', -- admin@panamatravelhub.com
     '00000000-0000-0000-0000-000000000002', -- Admin
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Asignar rol Customer al usuario cliente
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000002',
     '00000000-0000-0000-0000-000000000002', -- cliente@panamatravelhub.com
     '00000000-0000-0000-0000-000000000001', -- Customer
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Asignar rol Customer al usuario test1
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000003',
     '00000000-0000-0000-0000-000000000003', -- test1@panamatravelhub.com
     '00000000-0000-0000-0000-000000000001', -- Customer
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- Asignar rol Customer al usuario test2
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000004',
     '00000000-0000-0000-0000-000000000004', -- test2@panamatravelhub.com
     '00000000-0000-0000-0000-000000000001', -- Customer
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================
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
ORDER BY u.email;

