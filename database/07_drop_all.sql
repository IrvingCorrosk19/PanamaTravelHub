-- ============================================
-- SCRIPT PARA ELIMINAR TODAS LAS TABLAS Y OBJETOS
-- ============================================
-- USAR CON PRECAUCIÓN: Esto eliminará todos los datos

-- Eliminar triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
DROP TRIGGER IF EXISTS update_roles_updated_at ON roles;
DROP TRIGGER IF EXISTS update_user_roles_updated_at ON user_roles;
DROP TRIGGER IF EXISTS update_tours_updated_at ON tours;
DROP TRIGGER IF EXISTS update_tour_images_updated_at ON tour_images;
DROP TRIGGER IF EXISTS update_tour_dates_updated_at ON tour_dates;
DROP TRIGGER IF EXISTS update_bookings_updated_at ON bookings;
DROP TRIGGER IF EXISTS update_booking_participants_updated_at ON booking_participants;
DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;
DROP TRIGGER IF EXISTS update_email_notifications_updated_at ON email_notifications;
DROP TRIGGER IF EXISTS update_audit_logs_updated_at ON audit_logs;

-- Eliminar funciones
DROP FUNCTION IF EXISTS reserve_tour_spots(UUID, UUID, INTEGER);
DROP FUNCTION IF EXISTS release_tour_spots(UUID, UUID, INTEGER);
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Eliminar tablas (en orden inverso de dependencias)
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS email_notifications CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS booking_participants CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS tour_dates CASCADE;
DROP TABLE IF EXISTS tour_images CASCADE;
DROP TABLE IF EXISTS tours CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Eliminar extensiones (opcional, comentado por si otras aplicaciones las usan)
-- DROP EXTENSION IF EXISTS "uuid-ossp";
