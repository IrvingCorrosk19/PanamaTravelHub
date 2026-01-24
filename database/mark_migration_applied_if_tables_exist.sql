-- Script para marcar la migración como aplicada si las tablas principales ya existen
-- Esto permite aplicar migraciones de EF Core cuando algunas tablas ya fueron creadas con scripts SQL manuales

DO $$
DECLARE
    tables_exist BOOLEAN;
    migration_exists BOOLEAN;
BEGIN
    -- Verificar si las tablas principales ya existen
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('countries', 'users', 'tours', 'bookings', 'payments')
    ) INTO tables_exist;
    
    -- Verificar si la migración ya está marcada como aplicada
    SELECT EXISTS (
        SELECT 1 FROM "__EFMigrationsHistory" 
        WHERE "MigrationId" = '20260124171843_AddInvoicesBlogCommentsAnalytics'
    ) INTO migration_exists;
    
    -- Si las tablas existen pero la migración no está marcada, marcarla como aplicada
    IF tables_exist AND NOT migration_exists THEN
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
        VALUES ('20260124171843_AddInvoicesBlogCommentsAnalytics', '8.0.0');
        
        RAISE NOTICE 'Migración marcada como aplicada porque las tablas principales ya existen';
    ELSIF NOT tables_exist THEN
        RAISE NOTICE 'Las tablas principales no existen. Debe aplicar la migración completa.';
    ELSIF migration_exists THEN
        RAISE NOTICE 'La migración ya está marcada como aplicada.';
    END IF;
END $$;
