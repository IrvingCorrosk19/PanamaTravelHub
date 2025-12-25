-- ============================================
-- Script: Crear tabla countries y agregar country_id a bookings
-- Fecha: 2025-01-XX
-- Descripción: Permite seleccionar país en reservas para preparar expansión multi-país
-- ============================================

-- Crear tabla countries si no existe
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

-- Crear índices
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
    END IF;
END $$;

-- Verificar que las columnas se crearon correctamente
SELECT 
    'countries' as tabla,
    COUNT(*) as total_paises,
    COUNT(*) FILTER (WHERE is_active = true) as paises_activos
FROM countries
UNION ALL
SELECT 
    'bookings' as tabla,
    COUNT(*) as total_reservas,
    COUNT(*) FILTER (WHERE country_id IS NOT NULL) as reservas_con_pais
FROM bookings;

