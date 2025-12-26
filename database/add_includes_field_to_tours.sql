-- Script para agregar el campo "includes" (Qué Incluye) a la tabla tours
-- Este campo almacenará los items incluidos en el tour, uno por línea

DO $$
BEGIN
    -- Verificar si la columna ya existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'tours' AND column_name = 'includes'
    ) THEN
        -- Agregar la columna
        ALTER TABLE tours
        ADD COLUMN includes TEXT;
        
        RAISE NOTICE 'Columna "includes" agregada exitosamente a la tabla tours';
    ELSE
        RAISE NOTICE 'La columna "includes" ya existe en la tabla tours';
    END IF;
END $$;

-- Verificar la estructura actualizada
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'tours' AND column_name = 'includes';

