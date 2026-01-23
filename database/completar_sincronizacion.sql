-- Completar partes faltantes de la sincronización

-- 1. Crear tabla sms_notifications
CREATE TABLE IF NOT EXISTS sms_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    type INTEGER NOT NULL,
    status INTEGER NOT NULL DEFAULT 1,
    to_phone_number VARCHAR(20) NOT NULL,
    message VARCHAR(1600) NOT NULL,
    sent_at TIMESTAMP,
    retry_count INTEGER NOT NULL DEFAULT 0,
    error_message VARCHAR(1000),
    scheduled_for TIMESTAMP,
    provider_message_id VARCHAR(100),
    provider_response TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_sms_type CHECK (type IN (1, 2, 3, 4)),
    CONSTRAINT chk_sms_status CHECK (status IN (1, 2, 3, 4)),
    CONSTRAINT chk_sms_phone_format CHECK (to_phone_number ~ '^\+[1-9]\d{1,14}$'),
    CONSTRAINT chk_sms_retry_count CHECK (retry_count >= 0),
    CONSTRAINT chk_sms_message_length CHECK (LENGTH(message) > 0 AND LENGTH(message) <= 1600)
);

CREATE INDEX IF NOT EXISTS idx_sms_notifications_user_id ON sms_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_booking_id ON sms_notifications(booking_id);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_status ON sms_notifications(status);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_status_scheduled ON sms_notifications(status, scheduled_for);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_provider_id ON sms_notifications(provider_message_id);

-- 2. Agregar columnas a tours
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tours' AND column_name = 'tour_date') THEN
        ALTER TABLE tours ADD COLUMN tour_date TIMESTAMP;
        COMMENT ON COLUMN tours.tour_date IS 'Fecha principal del tour. Puede ser null si el tour tiene múltiples fechas en tour_dates';
        CREATE INDEX IF NOT EXISTS idx_tours_tour_date ON tours(tour_date) WHERE tour_date IS NOT NULL;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tours' AND column_name = 'includes') THEN
        ALTER TABLE tours ADD COLUMN includes TEXT;
    END IF;
END $$;

-- 3. Agregar country_id a bookings
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'country_id') THEN
        ALTER TABLE bookings ADD COLUMN country_id UUID REFERENCES countries(id) ON DELETE SET NULL;
        CREATE INDEX IF NOT EXISTS idx_bookings_country_id ON bookings(country_id);
    END IF;
END $$;

-- 4. Insertar países
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

