-- ============================================
-- MIGRACIÓN: Agregar soporte para Pagos Parciales y Cuotas
-- ============================================

-- Agregar campos a la tabla payments para pagos parciales
ALTER TABLE payments 
ADD COLUMN IF NOT EXISTS is_partial BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS installment_number INTEGER,
ADD COLUMN IF NOT EXISTS total_installments INTEGER,
ADD COLUMN IF NOT EXISTS parent_payment_id UUID REFERENCES payments(id) ON DELETE SET NULL;

-- Agregar índice para búsquedas de pagos relacionados
CREATE INDEX IF NOT EXISTS idx_payments_parent ON payments(parent_payment_id);
CREATE INDEX IF NOT EXISTS idx_payments_installment ON payments(booking_id, installment_number) WHERE is_partial = true;

-- Agregar campo a bookings para permitir pagos parciales
ALTER TABLE bookings
ADD COLUMN IF NOT EXISTS allow_partial_payments BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS payment_plan_type INTEGER DEFAULT 0; -- 0=Full, 1=Installments, 2=Partial

-- Comentarios
COMMENT ON COLUMN payments.is_partial IS 'Indica si este es un pago parcial';
COMMENT ON COLUMN payments.installment_number IS 'Número de cuota (1, 2, 3, etc.)';
COMMENT ON COLUMN payments.total_installments IS 'Total de cuotas programadas';
COMMENT ON COLUMN payments.parent_payment_id IS 'ID del pago padre (para agrupar cuotas)';
COMMENT ON COLUMN bookings.allow_partial_payments IS 'Permite pagos parciales para esta reserva';
COMMENT ON COLUMN bookings.payment_plan_type IS 'Tipo de plan de pago: 0=Completo, 1=Cuotas, 2=Parcial';
