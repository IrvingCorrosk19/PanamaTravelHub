-- Script para verificar todas las tablas en la base de datos
SELECT 
    table_name,
    CASE 
        WHEN table_name IN (
            'users', 'roles', 'user_roles', 'tours', 'tour_images', 
            'tour_dates', 'bookings', 'booking_participants', 
            'payments', 'email_notifications', 'audit_logs', 
            'home_page_content', 'refresh_tokens'
        ) THEN '✅ EXISTE'
        ELSE '❌ FALTA'
    END as estado
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Lista de tablas esperadas
SELECT 'TABLAS ESPERADAS:' as info;
SELECT unnest(ARRAY[
    'users',
    'roles', 
    'user_roles',
    'tours',
    'tour_images',
    'tour_dates',
    'bookings',
    'booking_participants',
    'payments',
    'email_notifications',
    'audit_logs',
    'home_page_content',
    'refresh_tokens'
]) as tabla_esperada;

