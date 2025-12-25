-- ============================================
-- Script: Verificar que todas las tablas estén implementadas
-- Fecha: 2025-01-XX
-- Descripción: Verifica la existencia de todas las tablas necesarias
-- ============================================

-- Listar todas las tablas del esquema public
SELECT 
    table_name,
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
    END as estado
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

-- Verificar columnas específicas de tablas importantes
SELECT 'home_page_content - Logo fields' as verificacion,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'home_page_content' 
            AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social')
        ) THEN '✅ OK'
        ELSE '❌ FALTAN CAMPOS'
    END as estado;

SELECT 'bookings - Country field' as verificacion,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'bookings' 
            AND column_name = 'country_id'
        ) THEN '✅ OK'
        ELSE '❌ FALTA CAMPO'
    END as estado;

SELECT 'countries table' as verificacion,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'countries'
        ) THEN '✅ OK'
        ELSE '❌ NO EXISTE'
    END as estado;

SELECT 'sms_notifications table' as verificacion,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_name = 'sms_notifications'
        ) THEN '✅ OK'
        ELSE '❌ NO EXISTE'
    END as estado;

-- Contar registros en tablas clave
SELECT 'Registros en tablas' as info;
SELECT 'users' as tabla, COUNT(*) as total FROM users
UNION ALL
SELECT 'roles', COUNT(*) FROM roles
UNION ALL
SELECT 'tours', COUNT(*) FROM tours
UNION ALL
SELECT 'countries', COUNT(*) FROM countries
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'pages', COUNT(*) FROM pages
ORDER BY tabla;

