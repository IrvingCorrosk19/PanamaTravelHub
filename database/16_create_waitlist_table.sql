-- ============================================
-- TABLA: waitlist
-- Sistema de Lista de Espera
-- ============================================

CREATE TABLE IF NOT EXISTS waitlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    tour_date_id UUID REFERENCES tour_dates(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    number_of_participants INTEGER NOT NULL,
    is_notified BOOLEAN NOT NULL DEFAULT false,
    notified_at TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    priority INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_participants_positive CHECK (number_of_participants > 0),
    CONSTRAINT chk_priority_positive CHECK (priority >= 0)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_waitlist_tour_id ON waitlist(tour_id);
CREATE INDEX IF NOT EXISTS idx_waitlist_tour_date_id ON waitlist(tour_date_id);
CREATE INDEX IF NOT EXISTS idx_waitlist_user_id ON waitlist(user_id);
CREATE INDEX IF NOT EXISTS idx_waitlist_is_active ON waitlist(is_active);
CREATE INDEX IF NOT EXISTS idx_waitlist_is_notified ON waitlist(is_notified);
CREATE INDEX IF NOT EXISTS idx_waitlist_tour_date_active_priority ON waitlist(tour_id, tour_date_id, is_active, priority);

-- Comentarios
COMMENT ON TABLE waitlist IS 'Lista de espera para tours agotados';
COMMENT ON COLUMN waitlist.priority IS 'Prioridad en la lista (menor número = mayor prioridad)';
COMMENT ON COLUMN waitlist.is_notified IS 'Indica si el usuario ya fue notificado de disponibilidad';
