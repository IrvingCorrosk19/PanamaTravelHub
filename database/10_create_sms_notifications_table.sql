-- ============================================
-- Script: Crear tabla sms_notifications
-- Fecha: 2025-01-XX
-- Descripción: Tabla para almacenar notificaciones SMS (similar a email_notifications)
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

-- Índices
CREATE INDEX IF NOT EXISTS idx_sms_notifications_user_id ON sms_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_booking_id ON sms_notifications(booking_id);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_status ON sms_notifications(status);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_status_scheduled ON sms_notifications(status, scheduled_for);
CREATE INDEX IF NOT EXISTS idx_sms_notifications_provider_id ON sms_notifications(provider_message_id);

-- Verificar que la tabla se creó correctamente
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'sms_notifications'
ORDER BY ordinal_position;

