-- Crear tabla __EFMigrationsHistory si no existe
CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

-- Insertar migración si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "__EFMigrationsHistory" 
        WHERE "MigrationId" = '20260124171843_AddInvoicesBlogCommentsAnalytics'
    ) THEN
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
        VALUES ('20260124171843_AddInvoicesBlogCommentsAnalytics', '8.0.0');
    END IF;
END $$;
