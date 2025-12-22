-- ============================================
-- FUNCIONES PARA CONTROL DE CONCURRENCIA Y CUPOS
-- ============================================

-- Función para bloquear cupos de un tour de forma transaccional
-- Previene sobreventa usando SELECT FOR UPDATE
CREATE OR REPLACE FUNCTION reserve_tour_spots(
    p_tour_id UUID,
    p_tour_date_id UUID,
    p_participants INTEGER
) RETURNS BOOLEAN AS $$
DECLARE
    v_available_spots INTEGER;
    v_max_capacity INTEGER;
BEGIN
    -- Si hay tour_date_id, trabajar con tour_dates
    IF p_tour_date_id IS NOT NULL THEN
        SELECT available_spots INTO v_available_spots
        FROM tour_dates
        WHERE id = p_tour_date_id
          AND is_active = true
        FOR UPDATE; -- Lock row para prevenir race conditions
        
        IF v_available_spots IS NULL THEN
            RETURN FALSE; -- Tour date no existe o no está activo
        END IF;
        
        IF v_available_spots < p_participants THEN
            RETURN FALSE; -- No hay suficientes cupos
        END IF;
        
        -- Actualizar cupos disponibles
        UPDATE tour_dates
        SET available_spots = available_spots - p_participants,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_date_id;
        
        RETURN TRUE;
    ELSE
        -- Trabajar con tours directamente
        SELECT available_spots, max_capacity INTO v_available_spots, v_max_capacity
        FROM tours
        WHERE id = p_tour_id
          AND is_active = true
        FOR UPDATE; -- Lock row
        
        IF v_available_spots IS NULL THEN
            RETURN FALSE; -- Tour no existe o no está activo
        END IF;
        
        IF v_available_spots < p_participants THEN
            RETURN FALSE; -- No hay suficientes cupos
        END IF;
        
        -- Actualizar cupos disponibles
        UPDATE tours
        SET available_spots = available_spots - p_participants,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_id;
        
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Función para liberar cupos cuando se cancela o expira una reserva
CREATE OR REPLACE FUNCTION release_tour_spots(
    p_tour_id UUID,
    p_tour_date_id UUID,
    p_participants INTEGER
) RETURNS BOOLEAN AS $$
BEGIN
    -- Si hay tour_date_id, trabajar con tour_dates
    IF p_tour_date_id IS NOT NULL THEN
        UPDATE tour_dates
        SET available_spots = LEAST(
            available_spots + p_participants,
            (SELECT max_capacity FROM tours WHERE id = p_tour_id)
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_date_id;
        
        RETURN TRUE;
    ELSE
        -- Trabajar con tours directamente
        UPDATE tours
        SET available_spots = LEAST(
            available_spots + p_participants,
            max_capacity
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_id;
        
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para actualizar updated_at automáticamente
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_roles_updated_at BEFORE UPDATE ON user_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tours_updated_at BEFORE UPDATE ON tours
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tour_images_updated_at BEFORE UPDATE ON tour_images
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tour_dates_updated_at BEFORE UPDATE ON tour_dates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_booking_participants_updated_at BEFORE UPDATE ON booking_participants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_email_notifications_updated_at BEFORE UPDATE ON email_notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_audit_logs_updated_at BEFORE UPDATE ON audit_logs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
