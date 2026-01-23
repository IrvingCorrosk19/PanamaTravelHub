-- ============================================
-- TABLAS: coupons y coupon_usages
-- Sistema de Cupones y Descuentos
-- ============================================

-- Tabla de cupones
CREATE TABLE IF NOT EXISTS coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(500) NOT NULL,
    discount_type INTEGER NOT NULL, -- 1=Percentage, 2=FixedAmount
    discount_value DECIMAL(18,2) NOT NULL,
    minimum_purchase_amount DECIMAL(18,2),
    maximum_discount_amount DECIMAL(18,2),
    valid_from TIMESTAMP,
    valid_until TIMESTAMP,
    max_uses INTEGER,
    max_uses_per_user INTEGER,
    current_uses INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_first_time_only BOOLEAN NOT NULL DEFAULT false,
    applicable_tour_id UUID REFERENCES tours(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_discount_value_positive CHECK (discount_value > 0),
    CONSTRAINT chk_max_uses_positive CHECK (max_uses IS NULL OR max_uses > 0),
    CONSTRAINT chk_max_uses_per_user_positive CHECK (max_uses_per_user IS NULL OR max_uses_per_user > 0),
    CONSTRAINT chk_current_uses_non_negative CHECK (current_uses >= 0),
    CONSTRAINT chk_percentage_range CHECK (discount_type != 1 OR (discount_value >= 0 AND discount_value <= 100))
);

-- Tabla de usos de cupones
CREATE TABLE IF NOT EXISTS coupon_usages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    discount_amount DECIMAL(18,2) NOT NULL,
    original_amount DECIMAL(18,2) NOT NULL,
    final_amount DECIMAL(18,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Índices para coupons
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_is_active ON coupons(is_active);
CREATE INDEX IF NOT EXISTS idx_coupons_valid_from ON coupons(valid_from);
CREATE INDEX IF NOT EXISTS idx_coupons_valid_until ON coupons(valid_until);

-- Índices para coupon_usages
CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon_id ON coupon_usages(coupon_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_user_id ON coupon_usages(user_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_booking_id ON coupon_usages(booking_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon_user ON coupon_usages(coupon_id, user_id);

-- Comentarios
COMMENT ON TABLE coupons IS 'Cupones y códigos promocionales para descuentos';
COMMENT ON COLUMN coupons.discount_type IS '1=Porcentaje, 2=Monto fijo';
COMMENT ON COLUMN coupons.discount_value IS 'Valor del descuento (porcentaje 0-100 o monto fijo)';
COMMENT ON COLUMN coupons.is_first_time_only IS 'Indica si el cupón es solo para primera compra';
COMMENT ON TABLE coupon_usages IS 'Registro de usos de cupones por reserva';
