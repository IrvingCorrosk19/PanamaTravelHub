-- Script para eliminar un tour específico de la base de datos
-- Este script elimina el tour y todas sus relaciones (imágenes, fechas, etc.)

-- ID del tour a eliminar
DO $$
DECLARE
    tour_id_to_delete UUID := '467b821f-2303-4984-9ee7-b724f11eeccc';
BEGIN
    -- Verificar si el tour existe
    IF EXISTS (SELECT 1 FROM tours WHERE id = tour_id_to_delete) THEN
        -- Eliminar imágenes del tour (CASCADE debería hacerlo automáticamente, pero por si acaso)
        DELETE FROM tour_images WHERE tour_id = tour_id_to_delete;
        
        -- Eliminar fechas del tour (CASCADE debería hacerlo automáticamente, pero por si acaso)
        DELETE FROM tour_dates WHERE tour_id = tour_id_to_delete;
        
        -- Eliminar el tour
        DELETE FROM tours WHERE id = tour_id_to_delete;
        
        RAISE NOTICE 'Tour % eliminado exitosamente', tour_id_to_delete;
    ELSE
        RAISE NOTICE 'Tour % no encontrado', tour_id_to_delete;
    END IF;
END $$;

-- Verificar que fue eliminado
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM tours WHERE id = '467b821f-2303-4984-9ee7-b724f11eeccc') 
        THEN 'ERROR: El tour aún existe'
        ELSE 'OK: El tour fue eliminado correctamente'
    END AS resultado;

