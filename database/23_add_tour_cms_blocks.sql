-- ============================================
-- MIGRACIÓN: Campos CMS para Tours (Bloques Editables)
-- ============================================
-- Esta migración agrega campos CMS para permitir edición de bloques
-- en tour-detail.html sin tocar código

-- Agregar campos CMS al tour
ALTER TABLE tours
ADD COLUMN IF NOT EXISTS hero_title VARCHAR(500),
ADD COLUMN IF NOT EXISTS hero_subtitle TEXT,
ADD COLUMN IF NOT EXISTS hero_cta_text VARCHAR(200) DEFAULT 'Ver fechas disponibles',
ADD COLUMN IF NOT EXISTS social_proof_text TEXT,
ADD COLUMN IF NOT EXISTS has_certified_guide BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS has_flexible_cancellation BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS available_languages TEXT, -- JSON array: ["Español", "Inglés"]
ADD COLUMN IF NOT EXISTS highlights_duration VARCHAR(100),
ADD COLUMN IF NOT EXISTS highlights_group_type VARCHAR(100),
ADD COLUMN IF NOT EXISTS highlights_physical_level VARCHAR(100),
ADD COLUMN IF NOT EXISTS highlights_meeting_point TEXT,
ADD COLUMN IF NOT EXISTS story_content TEXT, -- WYSIWYG content
ADD COLUMN IF NOT EXISTS includes_list TEXT, -- JSON array o texto separado por líneas
ADD COLUMN IF NOT EXISTS excludes_list TEXT, -- JSON array o texto separado por líneas
ADD COLUMN IF NOT EXISTS map_coordinates VARCHAR(100), -- "lat,lng"
ADD COLUMN IF NOT EXISTS map_reference_text TEXT,
ADD COLUMN IF NOT EXISTS final_cta_text VARCHAR(500) DEFAULT '¿Listo para vivir esta experiencia?',
ADD COLUMN IF NOT EXISTS final_cta_button_text VARCHAR(200) DEFAULT 'Ver fechas disponibles',
ADD COLUMN IF NOT EXISTS block_order JSONB, -- Orden de bloques: ["hero", "social", "highlights", "story", "includes", "availability", "map", "reviews", "final_cta"]
ADD COLUMN IF NOT EXISTS block_enabled JSONB; -- Bloques activos: {"hero": true, "social": true, ...}

-- Índices para búsqueda
CREATE INDEX IF NOT EXISTS idx_tours_hero_title ON tours(hero_title) WHERE hero_title IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tours_cms_enabled ON tours USING GIN(block_enabled) WHERE block_enabled IS NOT NULL;

-- Comentarios para documentación
COMMENT ON COLUMN tours.hero_title IS 'Título principal del hero (CMS editable)';
COMMENT ON COLUMN tours.hero_subtitle IS 'Subtítulo del hero (CMS editable)';
COMMENT ON COLUMN tours.hero_cta_text IS 'Texto del CTA principal del hero';
COMMENT ON COLUMN tours.social_proof_text IS 'Texto corto para prueba social';
COMMENT ON COLUMN tours.available_languages IS 'Idiomas disponibles (JSON array)';
COMMENT ON COLUMN tours.story_content IS 'Contenido WYSIWYG de la historia del tour';
COMMENT ON COLUMN tours.includes_list IS 'Lista de lo que incluye (texto o JSON)';
COMMENT ON COLUMN tours.excludes_list IS 'Lista de lo que NO incluye (texto o JSON)';
COMMENT ON COLUMN tours.map_coordinates IS 'Coordenadas del mapa (formato: "lat,lng")';
COMMENT ON COLUMN tours.block_order IS 'Orden de bloques (JSON array)';
COMMENT ON COLUMN tours.block_enabled IS 'Bloques activos/desactivados (JSON object)';
