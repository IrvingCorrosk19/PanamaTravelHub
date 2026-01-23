-- ============================================
-- TABLA: tour_reviews
-- Sistema de Reseñas y Calificaciones
-- ============================================

CREATE TABLE IF NOT EXISTS tour_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    comment VARCHAR(2000),
    is_approved BOOLEAN NOT NULL DEFAULT false,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tour_reviews_tour_id ON tour_reviews(tour_id);
CREATE INDEX IF NOT EXISTS idx_tour_reviews_user_id ON tour_reviews(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_tour_reviews_tour_user_unique ON tour_reviews(tour_id, user_id);
CREATE INDEX IF NOT EXISTS idx_tour_reviews_is_approved ON tour_reviews(is_approved);
CREATE INDEX IF NOT EXISTS idx_tour_reviews_rating ON tour_reviews(rating);

-- Comentarios
COMMENT ON TABLE tour_reviews IS 'Reseñas y calificaciones de tours por usuarios';
COMMENT ON COLUMN tour_reviews.rating IS 'Calificación de 1 a 5 estrellas';
COMMENT ON COLUMN tour_reviews.is_approved IS 'Indica si la reseña ha sido aprobada por un administrador';
COMMENT ON COLUMN tour_reviews.is_verified IS 'Indica si la reseña proviene de un usuario con reserva confirmada';
