-- ============================================
-- Script: Sincronizar DATOS de localhost a Render
-- Fecha: 2025-01-XX
-- Descripción: Replica los datos de negocio de localhost (principal) a Render
-- IMPORTANTE: Este script sincroniza datos, no estructura. Ejecutar después de 12_sync_render_database.sql
-- ADVERTENCIA: Este script puede sobrescribir datos en Render. Usar con precaución.
-- ============================================

-- ============================================
-- INSTRUCCIONES DE USO
-- ============================================
-- Este script está diseñado para ser ejecutado desde localhost hacia Render.
-- 
-- OPCIÓN 1: Exportar desde localhost e importar en Render
--   1. Ejecutar en localhost: pg_dump para exportar datos
--   2. Ejecutar en Render: psql para importar datos
--
-- OPCIÓN 2: Usar este script con COPY o INSERT SELECT
--   Requiere conexión simultánea a ambas bases de datos (usando dblink)
--
-- OPCIÓN 3: Exportar datos específicos y aplicar manualmente
--   Ver sección "EXPORTAR DATOS DESDE LOCALHOST" más abajo

-- ============================================
-- VERIFICACIÓN DE HOMOLOGACIÓN
-- ============================================
-- Antes de sincronizar datos, verificar que el esquema esté sincronizado
DO $$
DECLARE
    v_schema_ok BOOLEAN := true;
    v_missing_tables TEXT[];
BEGIN
    -- Verificar que todas las tablas principales existan
    SELECT array_agg(table_name) INTO v_missing_tables
    FROM (
        SELECT unnest(ARRAY['users', 'roles', 'user_roles', 'tours', 'tour_images', 
                           'tour_dates', 'bookings', 'booking_participants', 'payments',
                           'email_notifications', 'countries', 'home_page_content']) AS table_name
    ) t
    WHERE NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = t.table_name
    );
    
    IF array_length(v_missing_tables, 1) > 0 THEN
        RAISE EXCEPTION 'Faltan tablas en el esquema: %. Ejecuta primero 12_sync_render_database.sql', 
            array_to_string(v_missing_tables, ', ');
    END IF;
    
    RAISE NOTICE 'Esquema verificado correctamente. Todas las tablas principales existen.';
END $$;

-- ============================================
-- EXPORTAR DATOS DESDE LOCALHOST
-- ============================================
-- Ejecuta estos comandos en localhost para exportar datos:

/*
-- Exportar solo datos (sin estructura) de tablas específicas
pg_dump -h localhost -U postgres -d PanamaTravelHub \
  --data-only \
  --table=tours \
  --table=tour_images \
  --table=tour_dates \
  --table=bookings \
  --table=booking_participants \
  --table=payments \
  --table=email_notifications \
  --table=home_page_content \
  --table=sms_notifications \
  -f export_data.sql

-- O exportar todo (estructura + datos)
pg_dump -h localhost -U postgres -d PanamaTravelHub -f full_backup.sql
*/

-- ============================================
-- IMPORTAR DATOS EN RENDER
-- ============================================
-- Después de exportar, ejecuta en Render:

/*
psql "Host=dpg-d54nnjf5r7bs73ej6gn0-a.oregon-postgres.render.com;Port=5432;Database=panamatravelhub;Username=panamatravelhub_user;Password=YFxc28DdPtabZS11XfVxywP5SnS53yZP;SSL Mode=Require;Trust Server Certificate=true" -f export_data.sql
*/

-- ============================================
-- SINCRONIZACIÓN SELECTIVA (Usando dblink)
-- ============================================
-- NOTA: Requiere extensión dblink en ambas bases de datos
-- Solo usar si tienes acceso a configurar dblink

/*
-- Crear extensión dblink si no existe
CREATE EXTENSION IF NOT EXISTS dblink;

-- Ejemplo: Sincronizar tours desde localhost
INSERT INTO tours (id, name, description, itinerary, price, max_capacity, duration_hours, location, is_active, available_spots, tour_date, includes, created_at, updated_at)
SELECT * FROM dblink(
    'host=localhost port=5432 dbname=PanamaTravelHub user=postgres password=Panama2020$',
    'SELECT id, name, description, itinerary, price, max_capacity, duration_hours, location, is_active, available_spots, tour_date, includes, created_at, updated_at FROM tours'
) AS remote_tours(
    id UUID,
    name VARCHAR(200),
    description TEXT,
    itinerary TEXT,
    price DECIMAL(10,2),
    max_capacity INTEGER,
    duration_hours INTEGER,
    location VARCHAR(200),
    is_active BOOLEAN,
    available_spots INTEGER,
    tour_date TIMESTAMP,
    includes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    itinerary = EXCLUDED.itinerary,
    price = EXCLUDED.price,
    max_capacity = EXCLUDED.max_capacity,
    duration_hours = EXCLUDED.duration_hours,
    location = EXCLUDED.location,
    is_active = EXCLUDED.is_active,
    available_spots = EXCLUDED.available_spots,
    tour_date = EXCLUDED.tour_date,
    includes = EXCLUDED.includes,
    updated_at = EXCLUDED.updated_at;
*/

-- ============================================
-- VERIFICACIÓN DE DATOS
-- ============================================
-- Ejecutar estas consultas para comparar conteos entre localhost y Render

DO $$
BEGIN
    RAISE NOTICE '=== VERIFICACIÓN DE DATOS ===';
    RAISE NOTICE 'Ejecuta estas consultas en ambas bases de datos para comparar:';
    RAISE NOTICE '';
    RAISE NOTICE 'SELECT ''tours'' as tabla, COUNT(*) as total FROM tours;';
    RAISE NOTICE 'SELECT ''tour_images'' as tabla, COUNT(*) as total FROM tour_images;';
    RAISE NOTICE 'SELECT ''tour_dates'' as tabla, COUNT(*) as total FROM tour_dates;';
    RAISE NOTICE 'SELECT ''bookings'' as tabla, COUNT(*) as total FROM bookings;';
    RAISE NOTICE 'SELECT ''users'' as tabla, COUNT(*) as total FROM users;';
    RAISE NOTICE 'SELECT ''countries'' as tabla, COUNT(*) as total FROM countries;';
    RAISE NOTICE '';
    RAISE NOTICE 'Para verificar diferencias, compara los resultados entre localhost y Render.';
END $$;

-- ============================================
-- SCRIPT DE COMPARACIÓN
-- ============================================
-- Este bloque genera un reporte de diferencias (ejecutar en ambas bases)

/*
-- Generar reporte de conteos
SELECT 
    'tours' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE is_active = true) as activos,
    COUNT(*) FILTER (WHERE tour_date IS NOT NULL) as con_fecha
FROM tours
UNION ALL
SELECT 
    'tour_images' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE is_primary = true) as primarias,
    NULL::INTEGER as con_fecha
FROM tour_images
UNION ALL
SELECT 
    'tour_dates' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE is_active = true) as activos,
    COUNT(*) FILTER (WHERE tour_date_time > CURRENT_TIMESTAMP) as futuras
FROM tour_dates
UNION ALL
SELECT 
    'bookings' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE status = 2) as confirmadas,
    COUNT(*) FILTER (WHERE country_id IS NOT NULL) as con_pais
FROM bookings
UNION ALL
SELECT 
    'users' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE is_active = true) as activos,
    NULL::INTEGER as con_fecha
FROM users
UNION ALL
SELECT 
    'countries' as tabla,
    COUNT(*) as total_registros,
    COUNT(*) FILTER (WHERE is_active = true) as activos,
    NULL::INTEGER as con_fecha
FROM countries
ORDER BY tabla;
*/

