-- ============================================
-- VERIFICACION COMPLETA DE LA BASE DE DATOS
-- ============================================

-- 1. LISTAR TODAS LAS TABLAS
SELECT 'TABLAS EXISTENTES:' as info;
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. VERIFICAR TABLAS REQUERIDAS
SELECT 'TABLAS REQUERIDAS:' as info;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN 'OK - users'
        ELSE 'FALTA - users'
    END as estado
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles') THEN 'OK - roles' ELSE 'FALTA - roles' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_roles') THEN 'OK - user_roles' ELSE 'FALTA - user_roles' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tours') THEN 'OK - tours' ELSE 'FALTA - tours' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') THEN 'OK - bookings' ELSE 'FALTA - bookings' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'countries') THEN 'OK - countries' ELSE 'FALTA - countries (EJECUTAR: 09_add_countries_and_country_to_bookings.sql)' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sms_notifications') THEN 'OK - sms_notifications' ELSE 'FALTA - sms_notifications (EJECUTAR: 10_create_sms_notifications_table.sql)' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'home_page_content') THEN 'OK - home_page_content' ELSE 'FALTA - home_page_content' END
UNION ALL SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages') THEN 'OK - pages' ELSE 'FALTA - pages' END;

-- 3. VERIFICAR CAMPOS DE LOGO
SELECT 'CAMPOS DE LOGO EN home_page_content:' as info;
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'home_page_content' 
    AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social');

-- 4. VERIFICAR CAMPO country_id EN bookings
SELECT 'CAMPO country_id EN bookings:' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'bookings' 
    AND column_name = 'country_id';

-- 5. CONTAR REGISTROS
SELECT 'CONTEO DE REGISTROS:' as info;
SELECT 'users' as tabla, COUNT(*) as total FROM users
UNION ALL SELECT 'roles', COUNT(*) FROM roles
UNION ALL SELECT 'tours', COUNT(*) FROM tours
UNION ALL SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL SELECT 'pages', COUNT(*) FROM pages
UNION ALL SELECT 'email_notifications', COUNT(*) FROM email_notifications;

-- 6. USUARIOS Y ROLES
SELECT 'USUARIOS Y ROLES:' as info;
SELECT 
    u.email,
    u.first_name || ' ' || u.last_name as nombre,
    COALESCE(STRING_AGG(r.name, ', '), 'Sin rol') as roles,
    u.is_active
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.email, u.first_name, u.last_name, u.is_active
ORDER BY u.email;

-- 7. VERIFICAR COUNTRIES (si existe)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'countries') THEN
        RAISE NOTICE 'COUNTRIES: Tabla existe';
        PERFORM 1 FROM countries LIMIT 1;
        IF FOUND THEN
            RAISE NOTICE 'COUNTRIES: Tiene registros';
        ELSE
            RAISE NOTICE 'COUNTRIES: Tabla vacia';
        END IF;
    ELSE
        RAISE NOTICE 'COUNTRIES: Tabla NO existe - Ejecutar: 09_add_countries_and_country_to_bookings.sql';
    END IF;
END $$;

-- 8. VERIFICAR SMS_NOTIFICATIONS (si existe)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sms_notifications') THEN
        RAISE NOTICE 'SMS_NOTIFICATIONS: Tabla existe';
    ELSE
        RAISE NOTICE 'SMS_NOTIFICATIONS: Tabla NO existe - Ejecutar: 10_create_sms_notifications_table.sql';
    END IF;
END $$;

