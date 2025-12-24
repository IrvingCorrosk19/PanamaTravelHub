-- Script para corregir codificación UTF-8 en home_page_content
-- Usa escape Unicode para asegurar codificación correcta

-- Eliminar registro existente (si existe)
DELETE FROM home_page_content;

-- Crear nuevo registro con valores correctos usando escape Unicode
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
    U&'Descubre Panam\00E1',
    U&'Explora los destinos m\00E1s incre\00EDbles con nuestros tours exclusivos',
    U&'Buscar tours...',
    U&'Buscar',
    U&'Tours Disponibles',
    U&'Selecciona tu pr\00F3xima aventura',
    U&'Cargando tours...',
    U&'Error al cargar los tours. Por favor, intenta de nuevo.',
    U&'No se encontraron tours disponibles.',
    U&'ToursPanama',
    U&'Tu plataforma de confianza para descubrir Panam\00E1',
    U&'\00A9 2024 ToursPanama. Todos los derechos reservados.',
    U&'ToursPanama',
    U&'Tours',
    U&'Mis Reservas',
    U&'Iniciar Sesi\00F3n',
    U&'Cerrar Sesi\00F3n',
    U&'ToursPanama — Descubre los Mejores Tours en Panam\00E1',
    U&'Plataforma moderna de reservas de tours en Panam\00E1. Explora, reserva y disfruta de las mejores experiencias tur\00EDsticas.',
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

