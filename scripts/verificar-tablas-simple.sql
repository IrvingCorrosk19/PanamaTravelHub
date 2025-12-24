-- ============================================
-- Script para verificar todas las tablas
-- ============================================

-- Mostrar todas las tablas existentes
\echo '========================================'
\echo 'TABLAS EXISTENTES EN LA BASE DE DATOS:'
\echo '========================================'
SELECT 
    table_name as "Tabla",
    CASE 
        WHEN table_name IN (
            'users', 'roles', 'user_roles', 'tours', 'tour_images', 
            'tour_dates', 'bookings', 'booking_participants', 
            'payments', 'email_notifications', 'audit_logs'
        ) THEN 'EXISTE'
        ELSE 'EXTRA'
    END as "Estado"
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
ORDER BY table_name;

\echo ''
\echo '========================================'
\echo 'VERIFICACION DE TABLAS ESPERADAS:'
\echo '========================================'

-- Verificar cada tabla esperada
SELECT 
    'users' as tabla,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN 'EXISTE' ELSE 'FALTA' END as estado
UNION ALL
SELECT 'roles', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'user_roles', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_roles') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'tours', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tours') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'tour_images', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tour_images') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'tour_dates', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tour_dates') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'bookings', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'booking_participants', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'booking_participants') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'payments', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'email_notifications', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'email_notifications') THEN 'EXISTE' ELSE 'FALTA' END
UNION ALL
SELECT 'audit_logs', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs') THEN 'EXISTE' ELSE 'FALTA' END
ORDER BY tabla;

\echo ''
\echo '========================================'
\echo 'RESUMEN:'
\echo '========================================'
SELECT 
    COUNT(*) FILTER (WHERE table_name IN ('users', 'roles', 'user_roles', 'tours', 'tour_images', 'tour_dates', 'bookings', 'booking_participants', 'payments', 'email_notifications', 'audit_logs')) as tablas_principales,
    COUNT(*) as total_tablas
FROM information_schema.tables 
WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE';
