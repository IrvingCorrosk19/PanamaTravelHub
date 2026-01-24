-- Script para aplicar la migración de forma condicional
-- Crea las tablas solo si no existen

-- Crear tabla countries si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'countries') THEN
        CREATE TABLE countries (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            code character varying(2) NOT NULL,
            name character varying(100) NOT NULL,
            is_active boolean NOT NULL DEFAULT TRUE,
            display_order integer NOT NULL DEFAULT 0,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_countries" PRIMARY KEY (id)
        );
        
        CREATE INDEX idx_countries_active_order ON countries (is_active, display_order);
        CREATE UNIQUE INDEX idx_countries_code ON countries (code);
    END IF;
END $$;

-- Marcar migración como aplicada si las tablas principales existen
DO $$
DECLARE
    tables_exist BOOLEAN;
    migration_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('countries', 'users', 'tours', 'bookings', 'payments')
    ) INTO tables_exist;
    
    SELECT EXISTS (
        SELECT 1 FROM "__EFMigrationsHistory" 
        WHERE "MigrationId" = '20260124171843_AddInvoicesBlogCommentsAnalytics'
    ) INTO migration_exists;
    
    IF tables_exist AND NOT migration_exists THEN
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
        VALUES ('20260124171843_AddInvoicesBlogCommentsAnalytics', '8.0.0');
    END IF;
END $$;
