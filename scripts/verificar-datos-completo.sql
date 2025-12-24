-- Script completo para verificar estado de la base de datos
-- Verifica tablas, datos y estructura

-- 1. Ver todas las tablas
\echo '=== TABLAS EXISTENTES ==='
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- 2. Verificar tablas esperadas
\echo ''
\echo '=== ESTADO DE TABLAS ESPERADAS ==='
SELECT 
    'users' as tabla,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN 'OK' ELSE 'FALTA' END as estado
UNION ALL SELECT 'roles', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'user_roles', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'user_roles') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'tours', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tours') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'tour_images', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tour_images') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'tour_dates', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tour_dates') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'bookings', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'booking_participants', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'booking_participants') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'payments', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'email_notifications', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'email_notifications') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'audit_logs', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'home_page_content', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'home_page_content') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'refresh_tokens', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'refresh_tokens') THEN 'OK' ELSE 'FALTA' END
UNION ALL SELECT 'DataProtectionKeys', CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'DataProtectionKeys') THEN 'OK' ELSE 'FALTA' END
ORDER BY tabla;

-- 3. Contar registros en tablas principales
\echo ''
\echo '=== CONTEO DE REGISTROS ==='
SELECT 
    'users' as tabla,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') 
         THEN (SELECT COUNT(*)::text FROM users) 
         ELSE 'TABLA NO EXISTE' END as total
UNION ALL 
SELECT 'roles', 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'roles') 
         THEN (SELECT COUNT(*)::text FROM roles) 
         ELSE 'TABLA NO EXISTE' END
UNION ALL 
SELECT 'tours', 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tours') 
         THEN (SELECT COUNT(*)::text FROM tours) 
         ELSE 'TABLA NO EXISTE' END
UNION ALL 
SELECT 'tours activos', 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tours') 
         THEN (SELECT COUNT(*)::text FROM tours WHERE is_active = true) 
         ELSE 'TABLA NO EXISTE' END
UNION ALL 
SELECT 'tour_images', 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tour_images') 
         THEN (SELECT COUNT(*)::text FROM tour_images) 
         ELSE 'TABLA NO EXISTE' END
UNION ALL 
SELECT 'bookings', 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'bookings') 
         THEN (SELECT COUNT(*)::text FROM bookings) 
         ELSE 'TABLA NO EXISTE' END
UNION ALL 
SELECT 'home_page_content', 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'home_page_content') 
         THEN (SELECT COUNT(*)::text FROM home_page_content) 
         ELSE 'TABLA NO EXISTE' END
ORDER BY tabla;

-- 4. Ver tours activos (si existen)
\echo ''
\echo '=== TOURS ACTIVOS ==='
SELECT 
    id,
    name,
    price,
    is_active,
    available_spots,
    max_capacity,
    created_at
FROM tours 
WHERE is_active = true
ORDER BY created_at DESC
LIMIT 10;

-- 5. Ver estructura de tabla tours (si existe)
\echo ''
\echo '=== ESTRUCTURA DE TABLA TOURS ==='
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'tours'
ORDER BY ordinal_position;

-- 6. Verificar migraciones de EF Core
\echo ''
\echo '=== MIGRACIONES DE EF CORE ==='
SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '__EFMigrationsHistory') 
         THEN (SELECT COUNT(*)::text FROM "__EFMigrationsHistory") 
         ELSE 'TABLA NO EXISTE' END as total_migraciones;

-- 7. Ver últimas migraciones aplicadas (si existe la tabla)
SELECT 
    "MigrationId",
    "ProductVersion"
FROM "__EFMigrationsHistory"
ORDER BY "MigrationId" DESC
LIMIT 5;

