-- Script para limpiar registros huérfanos en user_roles
-- Elimina registros que apuntan a usuarios que no existen

-- Eliminar registros huérfanos (user_id que no existe en users)
DELETE FROM user_roles 
WHERE user_id NOT IN (SELECT id FROM users);

-- Verificar resultado
SELECT 
    ur.id,
    ur.user_id,
    ur.role_id,
    u.email,
    r.name as role_name
FROM user_roles ur
INNER JOIN users u ON ur.user_id = u.id
INNER JOIN roles r ON ur.role_id = r.id
ORDER BY u.email;

-- Contar registros restantes
SELECT COUNT(*) as total_registros_user_roles FROM user_roles;

