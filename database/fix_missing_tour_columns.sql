-- ============================================
-- Script: Agregar columnas faltantes a tours
-- Fecha: 2026-01-24
-- Descripción: Corrige el error "column t.available_languages does not exist"
-- ============================================

-- Verificar y agregar columnas CMS si no existen
DO $$ 
BEGIN
    -- available_languages
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'available_languages') THEN
        ALTER TABLE tours ADD COLUMN available_languages TEXT;
        RAISE NOTICE 'Columna available_languages agregada a tours';
    ELSE
        RAISE NOTICE 'Columna available_languages ya existe en tours';
    END IF;
    
    -- hero_title
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'hero_title') THEN
        ALTER TABLE tours ADD COLUMN hero_title VARCHAR(500);
        RAISE NOTICE 'Columna hero_title agregada a tours';
    END IF;
    
    -- hero_subtitle
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'hero_subtitle') THEN
        ALTER TABLE tours ADD COLUMN hero_subtitle TEXT;
        RAISE NOTICE 'Columna hero_subtitle agregada a tours';
    END IF;
    
    -- hero_cta_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'hero_cta_text') THEN
        ALTER TABLE tours ADD COLUMN hero_cta_text VARCHAR(200) DEFAULT 'Ver fechas disponibles';
        RAISE NOTICE 'Columna hero_cta_text agregada a tours';
    END IF;
    
    -- social_proof_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'social_proof_text') THEN
        ALTER TABLE tours ADD COLUMN social_proof_text TEXT;
        RAISE NOTICE 'Columna social_proof_text agregada a tours';
    END IF;
    
    -- has_certified_guide
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'has_certified_guide') THEN
        ALTER TABLE tours ADD COLUMN has_certified_guide BOOLEAN DEFAULT true;
        RAISE NOTICE 'Columna has_certified_guide agregada a tours';
    END IF;
    
    -- has_flexible_cancellation
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'has_flexible_cancellation') THEN
        ALTER TABLE tours ADD COLUMN has_flexible_cancellation BOOLEAN DEFAULT true;
        RAISE NOTICE 'Columna has_flexible_cancellation agregada a tours';
    END IF;
    
    -- highlights_duration
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_duration') THEN
        ALTER TABLE tours ADD COLUMN highlights_duration VARCHAR(100);
        RAISE NOTICE 'Columna highlights_duration agregada a tours';
    END IF;
    
    -- highlights_group_type
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_group_type') THEN
        ALTER TABLE tours ADD COLUMN highlights_group_type VARCHAR(100);
        RAISE NOTICE 'Columna highlights_group_type agregada a tours';
    END IF;
    
    -- highlights_physical_level
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_physical_level') THEN
        ALTER TABLE tours ADD COLUMN highlights_physical_level VARCHAR(100);
        RAISE NOTICE 'Columna highlights_physical_level agregada a tours';
    END IF;
    
    -- highlights_meeting_point
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_meeting_point') THEN
        ALTER TABLE tours ADD COLUMN highlights_meeting_point TEXT;
        RAISE NOTICE 'Columna highlights_meeting_point agregada a tours';
    END IF;
    
    -- story_content
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'story_content') THEN
        ALTER TABLE tours ADD COLUMN story_content TEXT;
        RAISE NOTICE 'Columna story_content agregada a tours';
    END IF;
    
    -- includes_list
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'includes_list') THEN
        ALTER TABLE tours ADD COLUMN includes_list TEXT;
        RAISE NOTICE 'Columna includes_list agregada a tours';
    END IF;
    
    -- excludes_list
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'excludes_list') THEN
        ALTER TABLE tours ADD COLUMN excludes_list TEXT;
        RAISE NOTICE 'Columna excludes_list agregada a tours';
    END IF;
    
    -- map_coordinates
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'map_coordinates') THEN
        ALTER TABLE tours ADD COLUMN map_coordinates VARCHAR(100);
        RAISE NOTICE 'Columna map_coordinates agregada a tours';
    END IF;
    
    -- map_reference_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'map_reference_text') THEN
        ALTER TABLE tours ADD COLUMN map_reference_text TEXT;
        RAISE NOTICE 'Columna map_reference_text agregada a tours';
    END IF;
    
    -- final_cta_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'final_cta_text') THEN
        ALTER TABLE tours ADD COLUMN final_cta_text VARCHAR(500) DEFAULT '¿Listo para vivir esta experiencia?';
        RAISE NOTICE 'Columna final_cta_text agregada a tours';
    END IF;
    
    -- final_cta_button_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'final_cta_button_text') THEN
        ALTER TABLE tours ADD COLUMN final_cta_button_text VARCHAR(200) DEFAULT 'Ver fechas disponibles';
        RAISE NOTICE 'Columna final_cta_button_text agregada a tours';
    END IF;
    
    -- block_order
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'block_order') THEN
        ALTER TABLE tours ADD COLUMN block_order JSONB;
        RAISE NOTICE 'Columna block_order agregada a tours';
    END IF;
    
    -- block_enabled
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'block_enabled') THEN
        ALTER TABLE tours ADD COLUMN block_enabled JSONB;
        RAISE NOTICE 'Columna block_enabled agregada a tours';
    END IF;
    
END $$;

-- Verificar que las columnas se crearon
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'tours' 
  AND column_name IN (
    'available_languages', 'hero_title', 'hero_subtitle', 'hero_cta_text',
    'social_proof_text', 'has_certified_guide', 'has_flexible_cancellation',
    'highlights_duration', 'highlights_group_type', 'highlights_physical_level',
    'highlights_meeting_point', 'story_content', 'includes_list', 'excludes_list',
    'map_coordinates', 'map_reference_text', 'final_cta_text', 'final_cta_button_text',
    'block_order', 'block_enabled'
  )
ORDER BY column_name;
