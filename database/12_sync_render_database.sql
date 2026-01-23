-- ============================================
-- Script: Sincronizar base de datos de Render con localhost
-- Fecha: 2025-01-XX
-- Descripción: Aplica todos los cambios que están en localhost pero faltan en Render
-- IMPORTANTE: Este script es idempotente (se puede ejecutar múltiples veces sin errores)
-- ============================================

-- ============================================
-- 1. AGREGAR CAMPOS DE LOGO A home_page_content
-- ============================================
DO $$ 
BEGIN
    -- Logo principal (para navbar, etc.)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'logo_url') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN logo_url VARCHAR(500);
        RAISE NOTICE 'Columna logo_url agregada a home_page_content';
    END IF;

    -- Favicon (32x32, ico)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'favicon_url') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN favicon_url VARCHAR(500);
        RAISE NOTICE 'Columna favicon_url agregada a home_page_content';
    END IF;

    -- Logo para redes sociales (1200x630, Open Graph)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'logo_url_social') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN logo_url_social VARCHAR(500);
        RAISE NOTICE 'Columna logo_url_social agregada a home_page_content';
    END IF;

    -- Hero image URL
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'home_page_content' AND column_name = 'hero_image_url') THEN
        ALTER TABLE home_page_content 
        ADD COLUMN hero_image_url VARCHAR(500);
        RAISE NOTICE 'Columna hero_image_url agregada a home_page_content';
    END IF;
END $$;

-- ============================================
-- 2. CREAR TABLA media_files
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

-- Comentarios
COMMENT ON TABLE media_files IS 'Biblioteca de archivos multimedia del CMS';
COMMENT ON COLUMN media_files.category IS 'Categoría para organizar archivos (Tours, Hero, Gallery, etc.)';

-- ============================================
-- 3. CREAR TABLA pages
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

-- Comentarios
COMMENT ON TABLE pages IS 'Páginas dinámicas del CMS';
COMMENT ON COLUMN pages.slug IS 'URL amigable única para la página';
COMMENT ON COLUMN pages.template IS 'Template a usar para renderizar la página';

-- ============================================
-- 4. CREAR TABLA countries Y AGREGAR country_id A bookings
-- ============================================
CREATE TABLE IF NOT EXISTS countries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(2) NOT NULL UNIQUE, -- ISO 3166-1 alpha-2 (ej: CR, PA, US)
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    display_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_country_code_length CHECK (LENGTH(code) = 2),
    CONSTRAINT chk_display_order CHECK (display_order >= 0)
);

-- Índices para countries
CREATE INDEX IF NOT EXISTS idx_countries_code ON countries(code);
CREATE INDEX IF NOT EXISTS idx_countries_active_order ON countries(is_active, display_order);

-- Insertar países principales de América Central y otros relevantes
INSERT INTO countries (id, code, name, is_active, display_order) VALUES
    ('550e8400-e29b-41d4-a716-446655440001', 'CR', 'Costa Rica', true, 1),
    ('550e8400-e29b-41d4-a716-446655440002', 'PA', 'Panamá', true, 2),
    ('550e8400-e29b-41d4-a716-446655440003', 'US', 'Estados Unidos', true, 3),
    ('550e8400-e29b-41d4-a716-446655440004', 'MX', 'México', true, 4),
    ('550e8400-e29b-41d4-a716-446655440005', 'CO', 'Colombia', true, 5),
    ('550e8400-e29b-41d4-a716-446655440006', 'GT', 'Guatemala', true, 6),
    ('550e8400-e29b-41d4-a716-446655440007', 'HN', 'Honduras', true, 7),
    ('550e8400-e29b-41d4-a716-446655440008', 'NI', 'Nicaragua', true, 8),
    ('550e8400-e29b-41d4-a716-446655440009', 'SV', 'El Salvador', true, 9),
    ('550e8400-e29b-41d4-a716-446655440010', 'BZ', 'Belice', true, 10),
    ('550e8400-e29b-41d4-a716-446655440011', 'CA', 'Canadá', true, 11),
    ('550e8400-e29b-41d4-a716-446655440012', 'ES', 'España', true, 12),
    ('550e8400-e29b-41d4-a716-446655440013', 'AR', 'Argentina', true, 13),
    ('550e8400-e29b-41d4-a716-446655440014', 'CL', 'Chile', true, 14),
    ('550e8400-e29b-41d4-a716-446655440015', 'BR', 'Brasil', true, 15),
    ('550e8400-e29b-41d4-a716-446655440016', 'PE', 'Perú', true, 16),
    ('550e8400-e29b-41d4-a716-446655440017', 'EC', 'Ecuador', true, 17),
    ('550e8400-e29b-41d4-a716-446655440018', 'VE', 'Venezuela', true, 18),
    ('550e8400-e29b-41d4-a716-446655440019', 'UY', 'Uruguay', true, 19),
    ('550e8400-e29b-41d4-a716-446655440020', 'PY', 'Paraguay', true, 20)
ON CONFLICT (code) DO NOTHING;

-- Agregar columna country_id a bookings si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'country_id') THEN
        ALTER TABLE bookings 
        ADD COLUMN country_id UUID REFERENCES countries(id) ON DELETE SET NULL;
        
        -- Crear índice para country_id
        CREATE INDEX IF NOT EXISTS idx_bookings_country_id ON bookings(country_id);
        
        RAISE NOTICE 'Columna country_id agregada a bookings';
    END IF;
END $$;

-- ============================================
-- 5. CREAR TABLA sms_notifications
-- ============================================
CREATE TABLE IF NOT EXISTS sms_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    type INTEGER NOT NULL, -- 1=BookingConfirmation, 2=BookingReminder, 3=PaymentConfirmation, 4=BookingCancellation
    status INTEGER NOT NULL DEFAULT 1, -- 1=Pending, 2=Sent, 3=Failed, 4=Retrying
    to_phone_number VARCHAR(20) NOT NULL, -- E.164 format (+50760000000)
    message VARCHAR(1600) NOT NULL, -- SMS limit is 1600 chars for concatenated messages
    sent_at TIMESTAMP,
    retry_count INTEGER NOT NULL DEFAULT 0,
    error_message VARCHAR(1000),
    scheduled_for TIMESTAMP,
    provider_message_id VARCHAR(100), -- ID del mensaje del proveedor (Twilio, etc.)
    provider_response TEXT, -- Respuesta completa del proveedor (JSON)
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_sms_type CHECK (type IN (1, 2, 3, 4)),
    CONSTRAINT chk_sms_status CHECK (status IN (1, 2, 3, 4)),
    CONSTRAINT chk_sms_phone_format CHECK (to_phone_number ~ '^\+[1-9]\d{1,14}$'), -- E.164 format
    CONSTRAINT chk_sms_retry_count CHECK (retry_count >= 0),
    CONSTRAINT chk_sms_message_length CHECK (LENGTH(message) > 0 AND LENGTH(message) <= 1600)
);

-- Índices para sms_notifications
CREATE INDEX IF NOT EXISTS idx_sms_notifications_user_id ON sms_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_booking_id ON sms_notifications(booking_id);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_status ON sms_notifications(status);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_status_scheduled ON sms_notifications(status, scheduled_for);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_provider_id ON sms_notifications(provider_message_id);

-- ============================================
-- 6. AGREGAR COLUMNA tour_date A tours
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'tour_date') THEN
        ALTER TABLE tours
        ADD COLUMN tour_date TIMESTAMP;
        
        -- Agregar comentario a la columna
        COMMENT ON COLUMN tours.tour_date IS 'Fecha principal del tour. Puede ser null si el tour tiene múltiples fechas en tour_dates';
        
        -- Crear índice para búsquedas por fecha
        CREATE INDEX IF NOT EXISTS idx_tours_tour_date ON tours(tour_date) WHERE tour_date IS NOT NULL;
        
        RAISE NOTICE 'Columna tour_date agregada a tours';
    END IF;
END $$;

-- ============================================
-- 7. AGREGAR COLUMNA includes A tours
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'includes') THEN
        ALTER TABLE tours
        ADD COLUMN includes TEXT;
        
        RAISE NOTICE 'Columna includes agregada a tours';
    END IF;
END $$;

-- ============================================
-- 8. SINCRONIZAR DATOS DE SEED (Roles, Usuario Admin)
-- ============================================
-- Insertar roles por defecto si no existen
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE 
SET name = EXCLUDED.name,
    description = EXCLUDED.description;

-- Insertar usuario administrador por defecto si no existe
-- NOTA: El password_hash debe ser actualizado manualmente si es necesario
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@toursanama.com', 
     'PLACEHOLDER_HASH', -- Debe ser reemplazado con hash real si es necesario
     'Admin', 'System', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE 
SET email = EXCLUDED.email,
    first_name = EXCLUDED.first_name,
    last_name = EXCLUDED.last_name,
    is_active = EXCLUDED.is_active;

-- Asignar rol Admin al usuario administrador si no existe
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000002', 
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================
DO $$
DECLARE
    v_count INT;
BEGIN
    -- Verificar columnas en home_page_content
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_name = 'home_page_content' 
        AND column_name IN ('logo_url', 'favicon_url', 'logo_url_social', 'hero_image_url');
    
    RAISE NOTICE 'Columnas en home_page_content: %', v_count;
    
    -- Verificar tablas creadas
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_name IN ('media_files', 'pages', 'countries', 'sms_notifications');
    
    RAISE NOTICE 'Tablas nuevas creadas: %', v_count;
    
    -- Verificar columnas en tours
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_name = 'tours' 
        AND column_name IN ('tour_date', 'includes');
    
    RAISE NOTICE 'Columnas nuevas en tours: %', v_count;
    
    -- Verificar columna en bookings
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_name = 'bookings' 
        AND column_name = 'country_id';
    
    RAISE NOTICE 'Columna country_id en bookings: %', v_count;
    
    RAISE NOTICE 'Sincronización completada exitosamente';
END $$;

