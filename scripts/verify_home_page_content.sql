-- Script de verificación de la tabla home_page_content

-- 1. Verificar que la tabla existe
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'home_page_content')
        THEN '✅ Tabla home_page_content existe'
        ELSE '❌ Tabla home_page_content NO existe'
    END as tabla_status;

-- 2. Contar registros
SELECT 
    COUNT(*) as total_registros,
    CASE 
        WHEN COUNT(*) > 0 THEN '✅ Hay registros'
        ELSE '⚠️ No hay registros'
    END as registros_status
FROM home_page_content;

-- 3. Listar todas las columnas
SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'home_page_content' 
ORDER BY ordinal_position;

-- 4. Verificar índices
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'home_page_content';

-- 5. Verificar datos del registro inicial
SELECT 
    id,
    hero_title,
    hero_subtitle,
    hero_search_placeholder,
    hero_search_button,
    tours_section_title,
    tours_section_subtitle,
    loading_tours_text,
    error_loading_tours_text,
    no_tours_found_text,
    footer_brand_text,
    footer_description,
    footer_copyright,
    nav_brand_text,
    nav_tours_link,
    nav_bookings_link,
    nav_login_link,
    nav_logout_button,
    page_title,
    meta_description,
    created_at,
    updated_at
FROM home_page_content 
LIMIT 1;

