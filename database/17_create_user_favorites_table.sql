-- ============================================
-- TABLA: user_favorites
-- Sistema de Favoritos/Wishlist
-- ============================================

CREATE TABLE IF NOT EXISTS user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT uq_user_favorites_user_tour UNIQUE (user_id, tour_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_tour_id ON user_favorites(tour_id);

-- Comentarios
COMMENT ON TABLE user_favorites IS 'Tours favoritos de los usuarios (wishlist)';
