-- Script para corregir codificación UTF-8 en home_page_content
-- Ejecutar solo si los datos están mal codificados (ej: "PanamÃ¡" en lugar de "Panamá")

-- Verificar datos actuales
SELECT 
    id,
    hero_title,
    nav_logout_button,
    footer_description
FROM home_page_content
LIMIT 1;

-- Si los datos están mal codificados, actualizar con valores correctos
-- NOTA: Esto sobrescribirá los datos existentes con valores por defecto correctos
UPDATE home_page_content
SET 
    hero_title = 'Descubre Panamá',
    hero_subtitle = 'Explora los destinos más increíbles con nuestros tours exclusivos',
    hero_search_placeholder = 'Buscar tours...',
    hero_search_button = 'Buscar',
    tours_section_title = 'Tours Disponibles',
    tours_section_subtitle = 'Selecciona tu próxima aventura',
    loading_tours_text = 'Cargando tours...',
    error_loading_tours_text = 'Error al cargar los tours. Por favor, intenta de nuevo.',
    no_tours_found_text = 'No se encontraron tours disponibles.',
    footer_brand_text = 'ToursPanama',
    footer_description = 'Tu plataforma de confianza para descubrir Panamá',
    footer_copyright = '© 2024 ToursPanama. Todos los derechos reservados.',
    nav_brand_text = 'ToursPanama',
    nav_tours_link = 'Tours',
    nav_bookings_link = 'Mis Reservas',
    nav_login_link = 'Iniciar Sesión',
    nav_logout_button = 'Cerrar Sesión',
    page_title = 'ToursPanama — Descubre los Mejores Tours en Panamá',
    meta_description = 'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.',
    updated_at = CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM home_page_content);

-- Si no existe ningún registro, crear uno nuevo con valores correctos
INSERT INTO home_page_content (
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
)
SELECT 
    uuid_generate_v4(),
    'Descubre Panamá',
    'Explora los destinos más increíbles con nuestros tours exclusivos',
    'Buscar tours...',
    'Buscar',
    'Tours Disponibles',
    'Selecciona tu próxima aventura',
    'Cargando tours...',
    'Error al cargar los tours. Por favor, intenta de nuevo.',
    'No se encontraron tours disponibles.',
    'ToursPanama',
    'Tu plataforma de confianza para descubrir Panamá',
    '© 2024 ToursPanama. Todos los derechos reservados.',
    'ToursPanama',
    'Tours',
    'Mis Reservas',
    'Iniciar Sesión',
    'Cerrar Sesión',
    'ToursPanama — Descubre los Mejores Tours en Panamá',
    'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM home_page_content);

-- Verificar que los datos estén correctos
SELECT 
    id,
    hero_title,
    nav_logout_button,
    footer_description
FROM home_page_content
LIMIT 1;

