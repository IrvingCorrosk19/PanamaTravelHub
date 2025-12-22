-- ============================================
-- TABLA: users
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(500) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT true,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0,
    locked_until TIMESTAMP,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_failed_attempts CHECK (failed_login_attempts >= 0)
);

-- ============================================
-- TABLA: roles
-- ============================================
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ============================================
-- TABLA: user_roles
-- ============================================
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT uq_user_role UNIQUE (user_id, role_id)
);

-- ============================================
-- TABLA: tours
-- ============================================
CREATE TABLE tours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    itinerary TEXT,
    price DECIMAL(10, 2) NOT NULL,
    max_capacity INTEGER NOT NULL,
    duration_hours INTEGER NOT NULL,
    location VARCHAR(200),
    is_active BOOLEAN NOT NULL DEFAULT true,
    available_spots INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_price_positive CHECK (price >= 0),
    CONSTRAINT chk_capacity_positive CHECK (max_capacity > 0),
    CONSTRAINT chk_duration_positive CHECK (duration_hours > 0),
    CONSTRAINT chk_available_spots CHECK (available_spots >= 0 AND available_spots <= max_capacity)
);

-- ============================================
-- TABLA: tour_images
-- ============================================
CREATE TABLE tour_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(200),
    display_order INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_display_order CHECK (display_order >= 0)
);

-- ============================================
-- TABLA: tour_dates
-- ============================================
CREATE TABLE tour_dates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE CASCADE,
    tour_date_time TIMESTAMP NOT NULL,
    available_spots INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_tour_date_future CHECK (tour_date_time > created_at),
    CONSTRAINT chk_available_spots_tour_date CHECK (available_spots >= 0)
);

-- ============================================
-- TABLA: bookings
-- ============================================
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    tour_id UUID NOT NULL REFERENCES tours(id) ON DELETE RESTRICT,
    tour_date_id UUID REFERENCES tour_dates(id) ON DELETE SET NULL,
    status INTEGER NOT NULL DEFAULT 1, -- 1=Pending, 2=Confirmed, 3=Cancelled, 4=Expired, 5=Completed
    number_of_participants INTEGER NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    expires_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_booking_status CHECK (status IN (1, 2, 3, 4, 5)),
    CONSTRAINT chk_participants_positive CHECK (number_of_participants > 0),
    CONSTRAINT chk_total_amount_positive CHECK (total_amount >= 0)
);

-- ============================================
-- TABLA: booking_participants
-- ============================================
CREATE TABLE booking_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    date_of_birth DATE,
    special_requirements TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_email_format_participant CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- ============================================
-- TABLA: payments
-- ============================================
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE RESTRICT,
    provider INTEGER NOT NULL, -- 1=Stripe, 2=PayPal, 3=Yappy
    status INTEGER NOT NULL DEFAULT 1, -- 1=Initiated, 2=Authorized, 3=Captured, 4=Failed, 5=Refunded
    amount DECIMAL(10, 2) NOT NULL,
    provider_transaction_id VARCHAR(255),
    provider_payment_intent_id VARCHAR(255),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    authorized_at TIMESTAMP,
    captured_at TIMESTAMP,
    refunded_at TIMESTAMP,
    failure_reason TEXT,
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_payment_provider CHECK (provider IN (1, 2, 3)),
    CONSTRAINT chk_payment_status CHECK (status IN (1, 2, 3, 4, 5)),
    CONSTRAINT chk_payment_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_currency_length CHECK (LENGTH(currency) = 3)
);

-- ============================================
-- TABLA: email_notifications
-- ============================================
CREATE TABLE email_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
    type INTEGER NOT NULL, -- 1=BookingConfirmation, 2=BookingReminder, 3=PaymentConfirmation, 4=BookingCancellation
    status INTEGER NOT NULL DEFAULT 1, -- 1=Pending, 2=Sent, 3=Failed, 4=Retrying
    to_email VARCHAR(255) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    body TEXT NOT NULL,
    sent_at TIMESTAMP,
    retry_count INTEGER NOT NULL DEFAULT 0,
    error_message TEXT,
    scheduled_for TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_email_type CHECK (type IN (1, 2, 3, 4)),
    CONSTRAINT chk_email_status CHECK (status IN (1, 2, 3, 4)),
    CONSTRAINT chk_email_format_notification CHECK (to_email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT chk_retry_count CHECK (retry_count >= 0)
);

-- ============================================
-- TABLA: audit_logs
-- ============================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE, etc.
    before_state JSONB,
    after_state JSONB,
    ip_address VARCHAR(45), -- IPv6 compatible
    user_agent TEXT,
    correlation_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    CONSTRAINT chk_action CHECK (action IN ('CREATE', 'UPDATE', 'DELETE', 'READ', 'LOGIN', 'LOGOUT', 'PAYMENT', 'CANCEL'))
);
