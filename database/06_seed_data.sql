-- ============================================
-- DATOS INICIALES (SEED DATA)
-- ============================================

-- Insertar roles por defecto
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Insertar usuario administrador por defecto
-- Email: admin@panamatravelhub.com | Password: Admin123!
-- Hash BCrypt válido para Admin123! (work factor 10)
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@panamatravelhub.com',
     '$2a$10$9LcbAUt7aEf1qRXk39GLTO9tyAkiF7zHUfjMASIN6WrTZ.2YLVil.',
     'Admin', 'System', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Asignar rol Admin al usuario administrador
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000002', 
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;
