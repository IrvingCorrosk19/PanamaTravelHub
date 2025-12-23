-- Script para crear la tabla home_page_content
-- Ejecutar este script en la base de datos PostgreSQL

CREATE TABLE IF NOT EXISTS home_page_content (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Hero Section
    hero_title VARCHAR(200) NOT NULL DEFAULT 'Descubre Panamá',
    hero_subtitle VARCHAR(500) NOT NULL DEFAULT 'Explora los destinos más increíbles con nuestros tours exclusivos',
    hero_search_placeholder VARCHAR(100) NOT NULL DEFAULT 'Buscar tours...',
    hero_search_button VARCHAR(50) NOT NULL DEFAULT 'Buscar',
    
    -- Tours Section
    tours_section_title VARCHAR(200) NOT NULL DEFAULT 'Tours Disponibles',
    tours_section_subtitle VARCHAR(300) NOT NULL DEFAULT 'Selecciona tu próxima aventura',
    loading_tours_text VARCHAR(200) NOT NULL DEFAULT 'Cargando tours...',
    error_loading_tours_text VARCHAR(300) NOT NULL DEFAULT 'Error al cargar los tours. Por favor, intenta de nuevo.',
    no_tours_found_text VARCHAR(200) NOT NULL DEFAULT 'No se encontraron tours disponibles.',
    
    -- Footer
    footer_brand_text VARCHAR(100) NOT NULL DEFAULT 'ToursPanama',
    footer_description VARCHAR(500) NOT NULL DEFAULT 'Tu plataforma de confianza para descubrir Panamá',
    footer_copyright VARCHAR(200) NOT NULL DEFAULT '© 2024 ToursPanama. Todos los derechos reservados.',
    
    -- Navigation
    nav_brand_text VARCHAR(100) NOT NULL DEFAULT 'ToursPanama',
    nav_tours_link VARCHAR(50) NOT NULL DEFAULT 'Tours',
    nav_bookings_link VARCHAR(50) NOT NULL DEFAULT 'Mis Reservas',
    nav_login_link VARCHAR(50) NOT NULL DEFAULT 'Iniciar Sesión',
    nav_logout_button VARCHAR(50) NOT NULL DEFAULT 'Cerrar Sesión',
    
    -- SEO
    page_title VARCHAR(200) NOT NULL DEFAULT 'ToursPanama — Descubre los Mejores Tours en Panamá',
    meta_description VARCHAR(500) NOT NULL DEFAULT 'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.',
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- Insertar registro inicial con valores por defecto
INSERT INTO home_page_content (
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
    meta_description
) VALUES (
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
    'Plataforma moderna de reservas de tours en Panamá. Explora, reserva y disfruta de las mejores experiencias turísticas.'
) ON CONFLICT DO NOTHING;

-- Crear índice para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_home_page_content_updated_at ON home_page_content(updated_at);

