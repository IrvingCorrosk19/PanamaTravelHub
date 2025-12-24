-- Listar todos los usuarios en la base de datos
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.is_active,
    STRING_AGG(r.name, ', ') as roles,
    u.created_at
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.email, u.first_name, u.last_name, u.is_active, u.created_at
ORDER BY u.created_at DESC;

