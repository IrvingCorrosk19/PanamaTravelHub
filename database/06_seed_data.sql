-- ============================================
-- DATOS INICIALES (SEED DATA)
-- ============================================

-- Insertar roles por defecto
INSERT INTO roles (id, name, description, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'Customer', 'Cliente regular del sistema', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000002', 'Admin', 'Administrador del sistema', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Insertar usuario administrador por defecto
-- Password: Admin123! (debe ser hasheado con Argon2id o BCrypt en la aplicación)
-- Por ahora solo creamos el registro, el hash se generará en la aplicación
INSERT INTO users (id, email, password_hash, first_name, last_name, is_active, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'admin@toursanama.com', 
     'PLACEHOLDER_HASH', -- Debe ser reemplazado con hash real en la aplicación
     'Admin', 'System', true, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- Asignar rol Admin al usuario administrador
INSERT INTO user_roles (id, user_id, role_id, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000001', 
     '00000000-0000-0000-0000-000000000002', 
     CURRENT_TIMESTAMP)
ON CONFLICT (user_id, role_id) DO NOTHING;
