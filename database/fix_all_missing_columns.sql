-- ============================================
-- Script: Corregir TODAS las columnas faltantes
-- Fecha: 2026-01-24
-- Descripción: Agrega todas las columnas faltantes detectadas en las pruebas
-- ============================================

-- ============================================
-- 1. COLUMNAS FALTANTES EN TOURS
-- ============================================
DO $$ 
BEGIN
    -- available_languages
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'available_languages') THEN
        ALTER TABLE tours ADD COLUMN available_languages TEXT;
        RAISE NOTICE 'Columna available_languages agregada a tours';
    END IF;
    
    -- hero_title
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'hero_title') THEN
        ALTER TABLE tours ADD COLUMN hero_title VARCHAR(500);
        RAISE NOTICE 'Columna hero_title agregada a tours';
    END IF;
    
    -- hero_subtitle
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'hero_subtitle') THEN
        ALTER TABLE tours ADD COLUMN hero_subtitle TEXT;
        RAISE NOTICE 'Columna hero_subtitle agregada a tours';
    END IF;
    
    -- hero_cta_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'hero_cta_text') THEN
        ALTER TABLE tours ADD COLUMN hero_cta_text VARCHAR(200) DEFAULT 'Ver fechas disponibles';
        RAISE NOTICE 'Columna hero_cta_text agregada a tours';
    END IF;
    
    -- social_proof_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'social_proof_text') THEN
        ALTER TABLE tours ADD COLUMN social_proof_text TEXT;
        RAISE NOTICE 'Columna social_proof_text agregada a tours';
    END IF;
    
    -- has_certified_guide
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'has_certified_guide') THEN
        ALTER TABLE tours ADD COLUMN has_certified_guide BOOLEAN DEFAULT true;
        RAISE NOTICE 'Columna has_certified_guide agregada a tours';
    END IF;
    
    -- has_flexible_cancellation
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'has_flexible_cancellation') THEN
        ALTER TABLE tours ADD COLUMN has_flexible_cancellation BOOLEAN DEFAULT true;
        RAISE NOTICE 'Columna has_flexible_cancellation agregada a tours';
    END IF;
    
    -- highlights_duration
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_duration') THEN
        ALTER TABLE tours ADD COLUMN highlights_duration VARCHAR(100);
        RAISE NOTICE 'Columna highlights_duration agregada a tours';
    END IF;
    
    -- highlights_group_type
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_group_type') THEN
        ALTER TABLE tours ADD COLUMN highlights_group_type VARCHAR(100);
        RAISE NOTICE 'Columna highlights_group_type agregada a tours';
    END IF;
    
    -- highlights_physical_level
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_physical_level') THEN
        ALTER TABLE tours ADD COLUMN highlights_physical_level VARCHAR(100);
        RAISE NOTICE 'Columna highlights_physical_level agregada a tours';
    END IF;
    
    -- highlights_meeting_point
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'highlights_meeting_point') THEN
        ALTER TABLE tours ADD COLUMN highlights_meeting_point TEXT;
        RAISE NOTICE 'Columna highlights_meeting_point agregada a tours';
    END IF;
    
    -- story_content
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'story_content') THEN
        ALTER TABLE tours ADD COLUMN story_content TEXT;
        RAISE NOTICE 'Columna story_content agregada a tours';
    END IF;
    
    -- includes_list
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'includes_list') THEN
        ALTER TABLE tours ADD COLUMN includes_list TEXT;
        RAISE NOTICE 'Columna includes_list agregada a tours';
    END IF;
    
    -- excludes_list
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'excludes_list') THEN
        ALTER TABLE tours ADD COLUMN excludes_list TEXT;
        RAISE NOTICE 'Columna excludes_list agregada a tours';
    END IF;
    
    -- map_coordinates
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'map_coordinates') THEN
        ALTER TABLE tours ADD COLUMN map_coordinates VARCHAR(100);
        RAISE NOTICE 'Columna map_coordinates agregada a tours';
    END IF;
    
    -- map_reference_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'map_reference_text') THEN
        ALTER TABLE tours ADD COLUMN map_reference_text TEXT;
        RAISE NOTICE 'Columna map_reference_text agregada a tours';
    END IF;
    
    -- final_cta_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'final_cta_text') THEN
        ALTER TABLE tours ADD COLUMN final_cta_text VARCHAR(500) DEFAULT '¿Listo para vivir esta experiencia?';
        RAISE NOTICE 'Columna final_cta_text agregada a tours';
    END IF;
    
    -- final_cta_button_text
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'final_cta_button_text') THEN
        ALTER TABLE tours ADD COLUMN final_cta_button_text VARCHAR(200) DEFAULT 'Ver fechas disponibles';
        RAISE NOTICE 'Columna final_cta_button_text agregada a tours';
    END IF;
    
    -- block_order
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'block_order') THEN
        ALTER TABLE tours ADD COLUMN block_order JSONB;
        RAISE NOTICE 'Columna block_order agregada a tours';
    END IF;
    
    -- block_enabled
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'tours' AND column_name = 'block_enabled') THEN
        ALTER TABLE tours ADD COLUMN block_enabled JSONB;
        RAISE NOTICE 'Columna block_enabled agregada a tours';
    END IF;
    
END $$;

-- ============================================
-- 2. COLUMNAS FALTANTES EN BOOKINGS
-- ============================================
DO $$ 
BEGIN
    -- allow_partial_payments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'allow_partial_payments') THEN
        ALTER TABLE bookings ADD COLUMN allow_partial_payments BOOLEAN NOT NULL DEFAULT false;
        RAISE NOTICE 'Columna allow_partial_payments agregada a bookings';
    END IF;
    
    -- payment_plan_type
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'payment_plan_type') THEN
        ALTER TABLE bookings ADD COLUMN payment_plan_type INTEGER DEFAULT 0;
        RAISE NOTICE 'Columna payment_plan_type agregada a bookings';
    END IF;
    
END $$;

-- ============================================
-- 3. COLUMNAS FALTANTES EN PAYMENTS (por si acaso)
-- ============================================
DO $$ 
BEGIN
    -- is_partial
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'payments' AND column_name = 'is_partial') THEN
        ALTER TABLE payments ADD COLUMN is_partial BOOLEAN NOT NULL DEFAULT false;
        RAISE NOTICE 'Columna is_partial agregada a payments';
    END IF;
    
    -- installment_number
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'payments' AND column_name = 'installment_number') THEN
        ALTER TABLE payments ADD COLUMN installment_number INTEGER;
        RAISE NOTICE 'Columna installment_number agregada a payments';
    END IF;
    
    -- total_installments
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'payments' AND column_name = 'total_installments') THEN
        ALTER TABLE payments ADD COLUMN total_installments INTEGER;
        RAISE NOTICE 'Columna total_installments agregada a payments';
    END IF;
    
    -- parent_payment_id
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'payments' AND column_name = 'parent_payment_id') THEN
        ALTER TABLE payments ADD COLUMN parent_payment_id UUID REFERENCES payments(id) ON DELETE SET NULL;
        RAISE NOTICE 'Columna parent_payment_id agregada a payments';
    END IF;
    
END $$;

-- ============================================
-- 4. VERIFICACIÓN FINAL
-- ============================================
SELECT 'Columnas en tours:' as info;
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'tours' 
  AND column_name IN (
    'available_languages', 'hero_title', 'hero_subtitle', 'hero_cta_text',
    'social_proof_text', 'has_certified_guide', 'has_flexible_cancellation',
    'highlights_duration', 'highlights_group_type', 'highlights_physical_level',
    'highlights_meeting_point', 'story_content', 'includes_list', 'excludes_list',
    'map_coordinates', 'map_reference_text', 'final_cta_text', 'final_cta_button_text',
    'block_order', 'block_enabled'
  )
ORDER BY column_name;

SELECT 'Columnas en bookings:' as info;
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'bookings' 
  AND column_name IN ('allow_partial_payments', 'payment_plan_type')
ORDER BY column_name;

SELECT 'Columnas en payments:' as info;
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name = 'payments' 
  AND column_name IN ('is_partial', 'installment_number', 'total_installments', 'parent_payment_id')
ORDER BY column_name;
