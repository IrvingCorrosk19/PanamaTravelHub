-- ============================================
-- Script para agregar columna tour_date a la tabla tours
-- ============================================
-- Este script agrega una columna opcional para almacenar la fecha principal del tour
-- La fecha puede ser null ya que los tours también pueden tener múltiples fechas en tour_dates

ALTER TABLE tours
ADD COLUMN IF NOT EXISTS tour_date TIMESTAMP;

-- Agregar comentario a la columna
COMMENT ON COLUMN tours.tour_date IS 'Fecha principal del tour. Puede ser null si el tour tiene múltiples fechas en tour_dates';

-- Crear índice para búsquedas por fecha (opcional, útil para filtrar tours por fecha)
CREATE INDEX IF NOT EXISTS idx_tours_tour_date ON tours(tour_date) WHERE tour_date IS NOT NULL;

