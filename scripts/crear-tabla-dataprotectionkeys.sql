-- Crear tabla DataProtectionKeys para ASP.NET Core Data Protection
-- Esta tabla almacena las keys de protección de datos

-- Verificar si la tabla ya existe antes de crearla
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'DataProtectionKeys') THEN
        CREATE TABLE "DataProtectionKeys" (
            "Id" SERIAL PRIMARY KEY,
            "FriendlyName" TEXT,
            "Xml" TEXT
        );

        -- Crear índice para mejorar el rendimiento
        CREATE INDEX "IX_DataProtectionKeys_FriendlyName" ON "DataProtectionKeys" ("FriendlyName");
        
        RAISE NOTICE 'Tabla DataProtectionKeys creada exitosamente';
    ELSE
        RAISE NOTICE 'La tabla DataProtectionKeys ya existe';
    END IF;
END $$;

