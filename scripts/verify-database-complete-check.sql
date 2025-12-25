-- ============================================
-- VERIFICACION COMPLETA DE LA BASE DE DATOS
-- ============================================

\echo '========================================'
\echo 'VERIFICACION COMPLETA DE LA BASE DE DATOS'
\echo '========================================'
\echo ''

-- 1. VERIFICAR TODAS LAS TABLAS REQUERIDAS
\echo '1. VERIFICANDO TABLAS REQUERIDAS...'
\echo ''

SELECT 
    table_name as "Tabla",
    CASE 
        WHEN table_name IN (
            'users', 'roles', 'user_roles',
            'tours', 'tour_images', 'tour_dates',
            'bookings', 'booking_participants',
            'payments',
            'email_notifications',
            'sms_notifications',
            'audit_logs',
            'home_page_content',
            'refresh_tokens',
            'password_reset_tokens',
            'media_files',
            'pages',
            'countries',
            'data_protection_keys'
        ) THEN '✅ REQUERIDA'
        ELSE '⚠️ NO ESPERADA'
    END as "Estado"
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
ORDER BY 
    CASE 
        WHEN table_name IN (
            'users', 'roles', 'user_roles',
            'tours', 'tour_images', 'tour_dates',
            'bookings', 'booking_participants',
            'payments',
            'email_notifications',
            'sms_notifications',
            'audit_logs',
            'home_page_content',
            'refresh_tokens',
            'password_reset_tokens',
            'media_files',
            'pages',
            'countries',
            'data_protection_keys'
        ) THEN 0
        ELSE 1
    END,
    table_name;

\echo ''
\echo '2. VERIFICANDO CAMPOS ESPECÍFICOS...'
\echo ''

-- 2. VERIFICAR CAMPOS DE LOGO EN home_page_content
SELECT 
    'home_page_content - Logo fields' as "Verificación",
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'home_page_content' 
            AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social')
        ) THEN '✅ OK - Campos de logo presentes'
        ELSE '❌ FALTAN CAMPOS - Ejecutar: database/08_add_logo_fields.sql'
    END as "Estado"
UNION ALL
-- 3. VERIFICAR CAMPO country_id EN bookings
SELECT 
    'bookings - Country field' as "Verificación",
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'bookings' 
            AND column_name = 'country_id'
        ) THEN '✅ OK - Campo country_id presente'
        ELSE '❌ FALTA CAMPO - Ejecutar: database/09_add_countries_and_country_to_bookings.sql'
    END as "Estado"
UNION ALL
-- 4. VERIFICAR TABLA countries
SELECT 
    'Tabla countries' as "Verificación",
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'countries'
        ) THEN '✅ OK - Tabla countries existe'
        ELSE '❌ NO EXISTE - Ejecutar: database/09_add_countries_and_country_to_bookings.sql'
    END as "Estado"
UNION ALL
-- 5. VERIFICAR TABLA sms_notifications
SELECT 
    'Tabla sms_notifications' as "Verificación",
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'sms_notifications'
        ) THEN '✅ OK - Tabla sms_notifications existe'
        ELSE '❌ NO EXISTE - Ejecutar: database/10_create_sms_notifications_table.sql'
    END as "Estado";

\echo ''
\echo '3. CONTANDO REGISTROS EN TABLAS CLAVE...'
\echo ''

SELECT 
    'users' as "Tabla", 
    COUNT(*) as "Total Registros" 
FROM users
UNION ALL
SELECT 'roles', COUNT(*) FROM roles
UNION ALL
SELECT 'countries', COUNT(*) FROM countries
UNION ALL
SELECT 'tours', COUNT(*) FROM tours
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'pages', COUNT(*) FROM pages
UNION ALL
SELECT 'email_notifications', COUNT(*) FROM email_notifications
UNION ALL
SELECT 'sms_notifications', COUNT(*) FROM sms_notifications
ORDER BY "Tabla";

\echo ''
\echo '4. VERIFICANDO USUARIOS DE PRUEBA...'
\echo ''

SELECT 
    u.email as "Email",
    u.first_name || ' ' || u.last_name as "Nombre",
    COALESCE(STRING_AGG(r.name, ', '), 'Sin rol') as "Roles",
    CASE WHEN u.is_active THEN '✅ Activo' ELSE '❌ Inactivo' END as "Estado"
FROM users u
LEFT JOIN user_roles ur ON u.id = ur.user_id
LEFT JOIN roles r ON ur.role_id = r.id
GROUP BY u.id, u.email, u.first_name, u.last_name, u.is_active
ORDER BY u.email;

\echo ''
\echo '5. VERIFICANDO DATOS EN COUNTRIES...'
\echo ''

SELECT 
    COUNT(*) as "Total Países",
    COUNT(*) FILTER (WHERE is_active = true) as "Países Activos"
FROM countries;

SELECT code as "Código", name as "País", 
    CASE WHEN is_active THEN '✅' ELSE '❌' END as "Activo"
FROM countries
ORDER BY display_order, name
LIMIT 10;

\echo ''
\echo '6. VERIFICANDO ESTRUCTURA DE TABLAS CLAVE...'
\echo ''

-- Verificar estructura de bookings
SELECT 
    column_name as "Columna",
    data_type as "Tipo",
    is_nullable as "Nullable"
FROM information_schema.columns
WHERE table_name = 'bookings'
    AND column_name IN ('id', 'user_id', 'tour_id', 'country_id', 'status', 'total_amount')
ORDER BY ordinal_position;

\echo ''
\echo '7. VERIFICANDO ÍNDICES IMPORTANTES...'
\echo ''

SELECT 
    tablename as "Tabla",
    indexname as "Índice"
FROM pg_indexes
WHERE schemaname = 'public'
    AND (
        indexname LIKE 'idx_countries%' OR
        indexname LIKE 'idx_bookings_country%' OR
        indexname LIKE 'idx_sms_notifications%' OR
        indexname LIKE 'idx_home_page_content%'
    )
ORDER BY tablename, indexname;

\echo ''
\echo '========================================'
\echo 'VERIFICACION COMPLETA'
\echo '========================================'

