-- ============================================
-- Script: Agregar campos de logo a home_page_content
-- Fecha: 2025-01-XX
-- Descripción: Agrega campos LogoUrl, FaviconUrl, LogoUrlSocial para gestión de branding
-- ============================================

-- Agregar columnas de logo si no existen
DO $$ 
BEGIN
    -- Logo principal (para navbar, etc.)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'logo_url') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN logo_url VARCHAR(500);
    END IF;

    -- Favicon (32x32, ico)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'favicon_url') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN favicon_url VARCHAR(500);
    END IF;

    -- Logo para redes sociales (1200x630, Open Graph)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'logo_url_social') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN logo_url_social VARCHAR(500);
    END IF;
END $$;

-- Verificar que las columnas se crearon correctamente
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'home_page_content' 
    AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social')
ORDER BY column_name;

