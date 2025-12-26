-- Script para agregar la columna hero_image_url a la tabla home_page_content
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name = 'home_page_content' AND column_name = 'hero_image_url') THEN
        ALTER TABLE home_page_content
        ADD COLUMN hero_image_url VARCHAR(500);
        RAISE NOTICE 'Columna "hero_image_url" agregada exitosamente a la tabla home_page_content';
    ELSE
        RAISE NOTICE 'La columna "hero_image_url" ya existe en la tabla home_page_content. No se realizó ningún cambio.';
    END IF;
END $$;

-- Verificar la columna
SELECT column_name, data_type, is_nullable, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'home_page_content' AND column_name = 'hero_image_url';

