-- ============================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_locked_until ON users(locked_until) WHERE locked_until IS NOT NULL;

-- Roles
CREATE INDEX idx_roles_name ON roles(name);

-- User Roles
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

-- Tours
CREATE INDEX idx_tours_is_active ON tours(is_active);
CREATE INDEX idx_tours_name ON tours(name);
CREATE INDEX idx_tours_price ON tours(price);
CREATE INDEX idx_tours_available_spots ON tours(available_spots) WHERE is_active = true;

-- Tour Images
CREATE INDEX idx_tour_images_tour_id ON tour_images(tour_id);
CREATE INDEX idx_tour_images_is_primary ON tour_images(is_primary) WHERE is_primary = true;
CREATE INDEX idx_tour_images_display_order ON tour_images(tour_id, display_order);

-- Tour Dates
CREATE INDEX idx_tour_dates_tour_id ON tour_dates(tour_id);
CREATE INDEX idx_tour_dates_tour_date_time ON tour_dates(tour_date_time);
CREATE INDEX idx_tour_dates_is_active ON tour_dates(is_active) WHERE is_active = true;
CREATE INDEX idx_tour_dates_available_spots ON tour_dates(available_spots) WHERE is_active = true AND available_spots > 0;

-- Bookings
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_tour_id ON bookings(tour_id);
CREATE INDEX idx_bookings_tour_date_id ON bookings(tour_date_id) WHERE tour_date_id IS NOT NULL;
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_created_at ON bookings(created_at);
CREATE INDEX idx_bookings_expires_at ON bookings(expires_at) WHERE expires_at IS NOT NULL;
CREATE INDEX idx_bookings_user_status ON bookings(user_id, status);
CREATE INDEX idx_bookings_tour_status ON bookings(tour_id, status);

-- Booking Participants
CREATE INDEX idx_booking_participants_booking_id ON booking_participants(booking_id);

-- Payments
CREATE INDEX idx_payments_booking_id ON payments(booking_id);
CREATE INDEX idx_payments_provider ON payments(provider);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_provider_transaction_id ON payments(provider_transaction_id) WHERE provider_transaction_id IS NOT NULL;
CREATE INDEX idx_payments_provider_payment_intent_id ON payments(provider_payment_intent_id) WHERE provider_payment_intent_id IS NOT NULL;
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_booking_status ON payments(booking_id, status);

-- Email Notifications
CREATE INDEX idx_email_notifications_user_id ON email_notifications(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_email_notifications_booking_id ON email_notifications(booking_id) WHERE booking_id IS NOT NULL;
CREATE INDEX idx_email_notifications_status ON email_notifications(status);
CREATE INDEX idx_email_notifications_type ON email_notifications(type);
CREATE INDEX idx_email_notifications_scheduled_for ON email_notifications(scheduled_for) WHERE scheduled_for IS NOT NULL;
CREATE INDEX idx_email_notifications_pending ON email_notifications(status, scheduled_for) WHERE status = 1;

-- Audit Logs
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_audit_logs_entity_type_id ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_correlation_id ON audit_logs(correlation_id) WHERE correlation_id IS NOT NULL;
CREATE INDEX idx_audit_logs_entity_type_created ON audit_logs(entity_type, created_at);
