-- Script para corregir codificación UTF-8 en home_page_content
-- Elimina el registro existente y crea uno nuevo con codificación correcta

-- Eliminar registro existente (si existe)
DELETE FROM home_page_content;

-- Crear nuevo registro con valores correctos en UTF-8
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
) VALUES (
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
);

-- Verificar que los datos estén correctos
SELECT 
    id,
    hero_title,
    nav_logout_button,
    footer_description
FROM home_page_content
LIMIT 1;

