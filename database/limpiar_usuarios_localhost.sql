-- ============================================
-- Script: Limpiar usuarios en localhost, dejar solo admin
-- ============================================

-- Ver usuarios actuales
SELECT 'ANTES DE LIMPIAR' as estado;
SELECT u.id, u.email, u.first_name, u.last_name, r.name as role_name 
FROM users u 
LEFT JOIN user_roles ur ON u.id = ur.user_id 
LEFT JOIN roles r ON ur.role_id = r.id 
ORDER BY u.created_at;

-- Identificar el usuario admin
-- El admin debería tener el email admin@panamatravelhub.com o admin@toursanama.com
-- y tener el rol Admin

-- Eliminar relaciones de user_roles para usuarios que NO son admin
DELETE FROM user_roles 
WHERE user_id NOT IN (
    SELECT u.id 
    FROM users u 
    INNER JOIN user_roles ur ON u.id = ur.user_id 
    INNER JOIN roles r ON ur.role_id = r.id 
    WHERE r.name = 'Admin'
);

-- Eliminar usuarios que NO son admin
-- Primero verificar que no tengan reservas o datos relacionados
DELETE FROM users 
WHERE id NOT IN (
    SELECT u.id 
    FROM users u 
    INNER JOIN user_roles ur ON u.id = ur.user_id 
    INNER JOIN roles r ON ur.role_id = r.id 
    WHERE r.name = 'Admin'
);

-- Ver usuarios después de limpiar
SELECT 'DESPUES DE LIMPIAR' as estado;
SELECT u.id, u.email, u.first_name, u.last_name, r.name as role_name 
FROM users u 
LEFT JOIN user_roles ur ON u.id = ur.user_id 
LEFT JOIN roles r ON ur.role_id = r.id 
ORDER BY u.created_at;

-- Verificar conteos finales
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM user_roles) as total_user_roles,
    (SELECT COUNT(*) FROM roles) as total_roles;

