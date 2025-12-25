-- ============================================
-- Script: Obtener usuarios de prueba y contraseñas
-- Fecha: 2025-01-XX
-- Descripción: Muestra los usuarios de prueba creados
-- ============================================

-- Mostrar usuarios y sus roles
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.is_active,
    u.created_at,
    STRING_AGG(r.name, ', ') as roles
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.email, u.first_name, u.last_name, u.is_active, u.created_at
ORDER BY u.email;

-- Información de contraseñas (nota: solo se almacenan hashes)
SELECT 
    'IMPORTANTE: Las contraseñas están hasheadas con BCrypt' as nota,
    'No se pueden recuperar las contraseñas originales' as seguridad;

-- Mostrar usuarios de prueba específicos
SELECT 
    '=== USUARIOS DE PRUEBA ===' as seccion;

SELECT 
    u.email,
    u.first_name || ' ' || u.last_name as nombre_completo,
    STRING_AGG(r.name, ', ') as roles,
    'Ver script reset-and-create-users.sql para contraseñas' as nota_contraseña
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
WHERE u.email LIKE '%@panamatravelhub.com' OR u.email LIKE '%test%'
GROUP BY u.id, u.email, u.first_name, u.last_name
ORDER BY u.email;

