-- ============================================
-- ELIMINAR USUARIO ADMIN DUPLICADO
-- ============================================
-- Mantener solo el usuario con ID fijo y eliminar duplicados
-- ============================================

-- Eliminar roles del usuario duplicado antes de eliminarlo
DELETE FROM user_roles 
WHERE user_id = '24e8864d-7bbf-4fdf-b59a-0cfa3b882386';

-- Eliminar el usuario duplicado (mantener el que tiene el ID fijo)
DELETE FROM users 
WHERE id = '24e8864d-7bbf-4fdf-b59a-0cfa3b882386'
  AND email = 'admin@panamatravelhub.com';

-- Verificar que solo quede un admin
SELECT 
    u.id,
    u.email,
    u.is_active,
    u.email_verified,
    r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email = 'admin@panamatravelhub.com';
