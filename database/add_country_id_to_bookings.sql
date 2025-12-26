-- ============================================
-- MIGRACIÓN: Agregar columna country_id a bookings
-- ============================================

-- Verificar si la columna ya existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'bookings' 
        AND column_name = 'country_id'
    ) THEN
        -- Agregar columna country_id
        ALTER TABLE bookings 
        ADD COLUMN country_id UUID;

        -- Agregar foreign key constraint si la tabla countries existe
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'countries') THEN
            ALTER TABLE bookings
            ADD CONSTRAINT fk_bookings_country_id
            FOREIGN KEY (country_id) 
            REFERENCES countries(id) 
            ON DELETE SET NULL;
        END IF;

        -- Crear índice para mejorar performance
        CREATE INDEX IF NOT EXISTS idx_bookings_country_id ON bookings(country_id) WHERE country_id IS NOT NULL;

        RAISE NOTICE 'Columna country_id agregada exitosamente a la tabla bookings';
    ELSE
        RAISE NOTICE 'La columna country_id ya existe en la tabla bookings';
    END IF;
END $$;

