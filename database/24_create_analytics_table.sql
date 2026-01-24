-- ============================================
-- TABLA: analytics_events
-- Sistema de Analytics First-Party
-- ============================================

CREATE TABLE IF NOT EXISTS analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50), -- 'tour', 'booking', 'user', etc.
    entity_id UUID, -- ID del tour, booking, etc.
    session_id UUID NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    -- Metadata flexible (JSONB para flexibilidad futura)
    metadata JSONB,
    
    -- Contexto del dispositivo
    device VARCHAR(20), -- 'mobile', 'tablet', 'desktop'
    user_agent TEXT,
    referrer TEXT,
    
    -- Ubicación (opcional, para análisis geográfico)
    country VARCHAR(2), -- ISO 3166-1 alpha-2
    city VARCHAR(100),
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Índices para consultas rápidas
    CONSTRAINT chk_event_length CHECK (char_length(event) <= 100),
    CONSTRAINT chk_device_value CHECK (device IN ('mobile', 'tablet', 'desktop', NULL))
);

-- Índices para consultas frecuentes
CREATE INDEX IF NOT EXISTS idx_analytics_events_event ON analytics_events(event);
CREATE INDEX IF NOT EXISTS idx_analytics_events_entity ON analytics_events(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_session ON analytics_events(session_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user ON analytics_events(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_analytics_events_created ON analytics_events(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_events_metadata ON analytics_events USING GIN(metadata);

-- Índice compuesto para funnels comunes
CREATE INDEX IF NOT EXISTS idx_analytics_events_funnel ON analytics_events(event, entity_type, created_at DESC);

-- Comentarios para documentación
COMMENT ON TABLE analytics_events IS 'Eventos de analytics first-party para análisis de conversión y comportamiento';
COMMENT ON COLUMN analytics_events.event IS 'Nombre del evento (ej: tour_viewed, reserve_clicked)';
COMMENT ON COLUMN analytics_events.entity_type IS 'Tipo de entidad relacionada (tour, booking, user)';
COMMENT ON COLUMN analytics_events.entity_id IS 'ID de la entidad relacionada';
COMMENT ON COLUMN analytics_events.session_id IS 'ID de sesión del usuario (UUID generado en frontend)';
COMMENT ON COLUMN analytics_events.metadata IS 'Datos adicionales del evento en formato JSON (precio, participantes, etc.)';
COMMENT ON COLUMN analytics_events.device IS 'Tipo de dispositivo (mobile, tablet, desktop)';
