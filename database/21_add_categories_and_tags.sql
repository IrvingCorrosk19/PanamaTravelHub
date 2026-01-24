-- ============================================
-- MIGRACIÓN: Agregar Categorías y Tags a Tours
-- ============================================

-- Tabla de categorías
CREATE TABLE IF NOT EXISTS tour_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Tabla de tags
CREATE TABLE IF NOT EXISTS tour_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de relación tour-categoría (muchos a muchos)
CREATE TABLE IF NOT EXISTS tour_category_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES tour_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tour_category UNIQUE (tour_id, category_id)
);

-- Tabla de relación tour-tag (muchos a muchos)
CREATE TABLE IF NOT EXISTS tour_tag_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tour_tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_tour_tag UNIQUE (tour_id, tag_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tour_categories_slug ON tour_categories(slug);
CREATE INDEX IF NOT EXISTS idx_tour_categories_active ON tour_categories(is_active);
CREATE INDEX IF NOT EXISTS idx_tour_tags_slug ON tour_tags(slug);
CREATE INDEX IF NOT EXISTS idx_tour_category_assignments_tour ON tour_category_assignments(tour_id);
CREATE INDEX IF NOT EXISTS idx_tour_category_assignments_category ON tour_category_assignments(category_id);
CREATE INDEX IF NOT EXISTS idx_tour_tag_assignments_tour ON tour_tag_assignments(tour_id);
CREATE INDEX IF NOT EXISTS idx_tour_tag_assignments_tag ON tour_tag_assignments(tag_id);

-- Insertar categorías por defecto
INSERT INTO tour_categories (name, slug, description, display_order) VALUES
    ('Aventura', 'aventura', 'Tours de aventura y actividades al aire libre', 1),
    ('Cultural', 'cultural', 'Tours culturales e históricos', 2),
    ('Playa', 'playa', 'Tours a playas y actividades acuáticas', 3),
    ('Naturaleza', 'naturaleza', 'Tours de naturaleza y ecoturismo', 4),
    ('Gastronomía', 'gastronomia', 'Tours gastronómicos y culinarios', 5),
    ('Nocturno', 'nocturno', 'Tours y actividades nocturnas', 6)
ON CONFLICT (slug) DO NOTHING;

-- Insertar algunos tags por defecto
INSERT INTO tour_tags (name, slug) VALUES
    ('Familiar', 'familiar'),
    ('Romántico', 'romantico'),
    ('Grupos', 'grupos'),
    ('Solo', 'solo'),
    ('Fotografía', 'fotografia'),
    ('Deportes', 'deportes')
ON CONFLICT (slug) DO NOTHING;
