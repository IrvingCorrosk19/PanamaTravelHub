-- Script simple sin caracteres especiales
-- Ver todas las tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Verificar tablas esperadas
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
ORDER BY tabla;

