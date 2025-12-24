-- ============================================
-- TABLA: media_files
-- ============================================
CREATE TABLE IF NOT EXISTS media_files (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    file_url VARCHAR(1000) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL,
    alt_text VARCHAR(500),
    description VARCHAR(1000),
    category VARCHAR(100),
    is_image BOOLEAN NOT NULL DEFAULT false,
    width INTEGER,
    height INTEGER,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_file_size_positive CHECK (file_size >= 0),
    CONSTRAINT chk_width_positive CHECK (width IS NULL OR width > 0),
    CONSTRAINT chk_height_positive CHECK (height IS NULL OR height > 0)
);

-- Índices para media_files
CREATE INDEX IF NOT EXISTS idx_media_files_category ON media_files(category);
CREATE INDEX IF NOT EXISTS idx_media_files_is_image ON media_files(is_image);
CREATE INDEX IF NOT EXISTS idx_media_files_uploaded_by ON media_files(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_media_files_created_at ON media_files(created_at);

-- ============================================
-- TABLA: pages
-- ============================================
CREATE TABLE IF NOT EXISTS pages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    content TEXT NOT NULL,
    excerpt VARCHAR(500),
    meta_title VARCHAR(200),
    meta_description VARCHAR(500),
    meta_keywords VARCHAR(500),
    is_published BOOLEAN NOT NULL DEFAULT false,
    published_at TIMESTAMP,
    template VARCHAR(100),
    display_order INTEGER NOT NULL DEFAULT 0,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_slug_format CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
    CONSTRAINT chk_display_order_positive CHECK (display_order >= 0)
);

-- Índices para pages
CREATE UNIQUE INDEX IF NOT EXISTS idx_pages_slug_unique ON pages(slug);
CREATE INDEX IF NOT EXISTS idx_pages_is_published ON pages(is_published);
CREATE INDEX IF NOT EXISTS idx_pages_published_order ON pages(is_published, display_order);
CREATE INDEX IF NOT EXISTS idx_pages_created_at ON pages(created_at);

-- Comentarios en las tablas
COMMENT ON TABLE media_files IS 'Biblioteca de archivos multimedia del CMS';
COMMENT ON TABLE pages IS 'Páginas dinámicas del CMS';

COMMENT ON COLUMN media_files.category IS 'Categoría para organizar archivos (Tours, Hero, Gallery, etc.)';
COMMENT ON COLUMN pages.slug IS 'URL amigable única para la página';
COMMENT ON COLUMN pages.template IS 'Template a usar para renderizar la página';

