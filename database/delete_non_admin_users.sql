-- Script para eliminar todos los usuarios excepto el admin
-- Mantiene las tablas roles y user_roles intactas

DO $$
DECLARE
    admin_user_id UUID;
BEGIN
    -- Identificar el usuario admin por su rol
    SELECT u.id INTO admin_user_id
    FROM users u
    INNER JOIN user_roles ur ON u.id = ur.user_id
    INNER JOIN roles r ON ur.role_id = r.id
    WHERE r.name = 'Admin'
    LIMIT 1;
    
    IF admin_user_id IS NULL THEN
        RAISE EXCEPTION 'No se encontró usuario admin. Abortando operación.';
    END IF;
    
    RAISE NOTICE 'Usuario admin encontrado: %', admin_user_id;
    
    -- Eliminar todos los usuarios que NO sean el admin
    -- Las relaciones en user_roles se eliminarán automáticamente por CASCADE
    DELETE FROM users
    WHERE id != admin_user_id;
    
    RAISE NOTICE 'Usuarios no-admin eliminados exitosamente';
    
    -- Limpiar registros huérfanos en user_roles (por si no se eliminaron por CASCADE)
    DELETE FROM user_roles 
    WHERE user_id NOT IN (SELECT id FROM users);
    
    RAISE NOTICE 'Registros huérfanos en user_roles limpiados';
END $$;

-- Verificar resultado final
SELECT 
    u.id,
    u.email,
    r.name as role_name
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
ORDER BY u.email;

-- Contar usuarios restantes
SELECT 
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN r.name = 'Admin' THEN 1 END) as admins,
    COUNT(CASE WHEN r.name = 'Customer' THEN 1 END) as customers
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id;
