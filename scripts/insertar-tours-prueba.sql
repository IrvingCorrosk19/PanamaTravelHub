-- Script para insertar tours de prueba en la base de datos
-- Estos tours aparecerán en la aplicación

-- Insertar tours de ejemplo
INSERT INTO tours (id, name, description, itinerary, price, max_capacity, duration_hours, location, is_active, available_spots, created_at)
VALUES 
(
    '550e8400-e29b-41d4-a716-446655440001',
    'Tour del Canal de Panamá',
    'Descubre la maravilla de la ingeniería mundial. Visita las esclusas de Miraflores y aprende sobre la historia del canal que conecta dos océanos.',
    '1. Recogida en hotel
2. Visita al Centro de Visitantes de Miraflores
3. Observación de barcos transitando
4. Museo del Canal
5. Regreso al hotel',
    75.00,
    20,
    4,
    'Ciudad de Panamá',
    true,
    15,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    'Casco Antiguo y Panamá Viejo',
    'Recorre la historia de Panamá visitando el Casco Antiguo colonial y las ruinas de Panamá Viejo, declaradas Patrimonio de la Humanidad.',
    '1. Recogida en hotel
2. Visita a Panamá Viejo (ruinas históricas)
3. Recorrido por Casco Antiguo
4. Visita a iglesias y plazas coloniales
5. Regreso al hotel',
    45.00,
    15,
    3,
    'Casco Antiguo',
    true,
    8,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    'Isla Taboga - Día Completo',
    'Escápate a la Isla de las Flores. Disfruta de playas paradisíacas, snorkel y la tranquilidad de este paraíso tropical.',
    '1. Salida temprano desde el muelle
2. Viaje en lancha a Isla Taboga
3. Snorkel y actividades acuáticas
4. Almuerzo en la isla
5. Tiempo libre en la playa
6. Regreso al atardecer',
    120.00,
    25,
    8,
    'Isla Taboga',
    true,
    12,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440004',
    'Tour Nocturno de la Ciudad',
    'Explora la ciudad de Panamá de noche. Disfruta de la vida nocturna, restaurantes y vistas panorámicas de la ciudad iluminada.',
    '1. Recogida al atardecer
2. Vista panorámica desde Cerro Ancón
3. Recorrido por la Cinta Costera
4. Cena en restaurante local
5. Visita a zona de vida nocturna
6. Regreso al hotel',
    65.00,
    30,
    4,
    'Ciudad de Panamá',
    true,
    20,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440005',
    'Rainforest Adventure - Gamboa',
    'Aventura en la naturaleza. Camina por senderos del bosque tropical, observa la fauna local y disfruta de la biodiversidad panameña.',
    '1. Recogida temprano
2. Llegada a Gamboa
3. Caminata por senderos del bosque
4. Observación de aves y fauna
5. Almuerzo en el lodge
6. Actividades adicionales (opcional)
7. Regreso al hotel',
    95.00,
    12,
    6,
    'Gamboa',
    true,
    5,
    CURRENT_TIMESTAMP
),
(
    '550e8400-e29b-41d4-a716-446655440006',
    'Tour Gastronómico Panameño',
    'Saborea la auténtica cocina panameña. Visita mercados locales, prueba platos tradicionales y aprende sobre la cultura culinaria.',
    '1. Recogida en hotel
2. Visita al Mercado de Mariscos
3. Degustación de ceviche
4. Recorrido por mercado de artesanías
5. Almuerzo en restaurante tradicional
6. Clase de cocina (opcional)
7. Regreso al hotel',
    55.00,
    20,
    3,
    'Ciudad de Panamá',
    true,
    18,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

-- Insertar imágenes para los tours
INSERT INTO tour_images (id, tour_id, image_url, alt_text, display_order, is_primary, created_at)
VALUES 
-- Tour 1: Canal de Panamá
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800', 'Canal de Panamá', 0, true, CURRENT_TIMESTAMP),
('660e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440001', 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200', 'Esclusas de Miraflores', 1, false, CURRENT_TIMESTAMP),

-- Tour 2: Casco Antiguo
('660e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440002', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800', 'Casco Antiguo', 0, true, CURRENT_TIMESTAMP),
('660e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440002', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1200', 'Panamá Viejo', 1, false, CURRENT_TIMESTAMP),

-- Tour 3: Isla Taboga
('660e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440003', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800', 'Isla Taboga', 0, true, CURRENT_TIMESTAMP),
('660e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440003', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200', 'Playa de Taboga', 1, false, CURRENT_TIMESTAMP),

-- Tour 4: Tour Nocturno
('660e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440004', 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800', 'Ciudad de Panamá de noche', 0, true, CURRENT_TIMESTAMP),

-- Tour 5: Rainforest
('660e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440005', 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800', 'Bosque tropical', 0, true, CURRENT_TIMESTAMP),

-- Tour 6: Gastronómico
('660e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440006', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800', 'Comida panameña', 0, true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Verificar que se insertaron correctamente
SELECT 
    t.id,
    t.name,
    t.price,
    t.is_active,
    COUNT(ti.id) FILTER (WHERE ti.id IS NOT NULL) as total_imagenes
FROM tours t
LEFT JOIN tour_images ti ON ti.tour_id = t.id
GROUP BY t.id, t.name, t.price, t.is_active
ORDER BY t.created_at DESC;

