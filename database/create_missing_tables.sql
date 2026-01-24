-- Script para crear solo las tablas que faltan en la base de datos
-- Basado en la migración 20260124171843_AddInvoicesBlogCommentsAnalytics

-- Tablas que faltan según verificación:
-- analytics_events, blog_comments, invoices, invoice_sequences
-- tour_categories, tour_tags, coupons, coupon_usages
-- sms_notifications, tour_reviews, user_favorites, waitlist
-- user_two_factor, login_history
-- tour_category_assignments, tour_tag_assignments

-- Crear tabla invoice_sequences si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'invoice_sequences') THEN
        CREATE TABLE invoice_sequences (
            year integer NOT NULL,
            current_value integer NOT NULL DEFAULT 0,
            CONSTRAINT "PK_invoice_sequences" PRIMARY KEY (year)
        );
    END IF;
END $$;

-- Crear tabla tour_categories si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tour_categories') THEN
        CREATE TABLE tour_categories (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            name character varying(100) NOT NULL,
            slug character varying(100) NOT NULL,
            description text,
            display_order integer NOT NULL DEFAULT 0,
            is_active boolean NOT NULL DEFAULT TRUE,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_tour_categories" PRIMARY KEY (id)
        );
        
        CREATE UNIQUE INDEX idx_tour_categories_slug ON tour_categories (slug);
        CREATE INDEX idx_tour_categories_active ON tour_categories (is_active);
    END IF;
END $$;

-- Crear tabla tour_tags si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tour_tags') THEN
        CREATE TABLE tour_tags (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            name character varying(50) NOT NULL,
            slug character varying(50) NOT NULL,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            "UpdatedAt" timestamp with time zone,
            CONSTRAINT "PK_tour_tags" PRIMARY KEY (id)
        );
        
        CREATE UNIQUE INDEX idx_tour_tags_slug ON tour_tags (slug);
    END IF;
END $$;

-- Crear tabla coupons si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'coupons') THEN
        CREATE TABLE coupons (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            code character varying(50) NOT NULL,
            description character varying(500) NOT NULL,
            discount_type integer NOT NULL,
            discount_value numeric(18,2) NOT NULL,
            minimum_purchase_amount numeric(18,2),
            maximum_discount_amount numeric(18,2),
            valid_from timestamp with time zone,
            valid_until timestamp with time zone,
            max_uses integer,
            max_uses_per_user integer,
            current_uses integer NOT NULL DEFAULT 0,
            is_active boolean NOT NULL DEFAULT TRUE,
            is_first_time_only boolean NOT NULL DEFAULT FALSE,
            applicable_tour_id uuid,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_coupons" PRIMARY KEY (id),
            CONSTRAINT chk_current_uses_non_negative CHECK (current_uses >= 0),
            CONSTRAINT chk_discount_value_positive CHECK (discount_value > 0),
            CONSTRAINT chk_max_uses_per_user_positive CHECK (max_uses_per_user IS NULL OR max_uses_per_user > 0),
            CONSTRAINT chk_max_uses_positive CHECK (max_uses IS NULL OR max_uses > 0),
            CONSTRAINT chk_percentage_range CHECK (discount_type != 1 OR (discount_value >= 0 AND discount_value <= 100)),
            CONSTRAINT "FK_coupons_tours_applicable_tour_id" FOREIGN KEY (applicable_tour_id) REFERENCES tours(id) ON DELETE SET NULL
        );
        
        CREATE UNIQUE INDEX "IX_coupons_code" ON coupons (code);
        CREATE INDEX "IX_coupons_is_active" ON coupons (is_active);
        CREATE INDEX "IX_coupons_valid_from" ON coupons (valid_from);
        CREATE INDEX "IX_coupons_valid_until" ON coupons (valid_until);
        CREATE INDEX "IX_coupons_applicable_tour_id" ON coupons (applicable_tour_id);
    END IF;
END $$;

-- Crear tabla tour_category_assignments si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tour_category_assignments') THEN
        CREATE TABLE tour_category_assignments (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            tour_id uuid NOT NULL,
            category_id uuid NOT NULL,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            "UpdatedAt" timestamp with time zone,
            CONSTRAINT "PK_tour_category_assignments" PRIMARY KEY (id),
            CONSTRAINT "FK_tour_category_assignments_tour_categories_category_id" FOREIGN KEY (category_id) REFERENCES tour_categories(id) ON DELETE CASCADE,
            CONSTRAINT "FK_tour_category_assignments_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
        );
        
        CREATE UNIQUE INDEX uq_tour_category ON tour_category_assignments (tour_id, category_id);
        CREATE INDEX idx_tour_category_assignments_tour ON tour_category_assignments (tour_id);
        CREATE INDEX idx_tour_category_assignments_category ON tour_category_assignments (category_id);
    END IF;
END $$;

-- Crear tabla tour_tag_assignments si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tour_tag_assignments') THEN
        CREATE TABLE tour_tag_assignments (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            tour_id uuid NOT NULL,
            tag_id uuid NOT NULL,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            "UpdatedAt" timestamp with time zone,
            CONSTRAINT "PK_tour_tag_assignments" PRIMARY KEY (id),
            CONSTRAINT "FK_tour_tag_assignments_tour_tags_tag_id" FOREIGN KEY (tag_id) REFERENCES tour_tags(id) ON DELETE CASCADE,
            CONSTRAINT "FK_tour_tag_assignments_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
        );
        
        CREATE UNIQUE INDEX uq_tour_tag ON tour_tag_assignments (tour_id, tag_id);
        CREATE INDEX idx_tour_tag_assignments_tour ON tour_tag_assignments (tour_id);
        CREATE INDEX idx_tour_tag_assignments_tag ON tour_tag_assignments (tag_id);
    END IF;
END $$;

-- Crear tabla coupon_usages si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'coupon_usages') THEN
        CREATE TABLE coupon_usages (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            coupon_id uuid NOT NULL,
            user_id uuid NOT NULL,
            booking_id uuid NOT NULL,
            discount_amount numeric(18,2) NOT NULL,
            original_amount numeric(18,2) NOT NULL,
            final_amount numeric(18,2) NOT NULL,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_coupon_usages" PRIMARY KEY (id),
            CONSTRAINT "FK_coupon_usages_coupons_coupon_id" FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
            CONSTRAINT "FK_coupon_usages_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT "FK_coupon_usages_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE
        );
        
        CREATE INDEX "IX_coupon_usages_coupon_id" ON coupon_usages (coupon_id);
        CREATE INDEX "IX_coupon_usages_user_id" ON coupon_usages (user_id);
        CREATE INDEX "IX_coupon_usages_booking_id" ON coupon_usages (booking_id);
        CREATE INDEX "IX_coupon_usages_coupon_id_user_id" ON coupon_usages (coupon_id, user_id);
    END IF;
END $$;

-- Crear tabla sms_notifications si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'sms_notifications') THEN
        CREATE TABLE sms_notifications (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            user_id uuid,
            booking_id uuid,
            type integer NOT NULL,
            status integer NOT NULL DEFAULT 1,
            to_phone_number character varying(20) NOT NULL,
            message character varying(1600) NOT NULL,
            sent_at timestamp with time zone,
            retry_count integer NOT NULL DEFAULT 0,
            error_message character varying(1000),
            scheduled_for timestamp with time zone,
            provider_message_id character varying(100),
            provider_response text,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_sms_notifications" PRIMARY KEY (id),
            CONSTRAINT "FK_sms_notifications_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
            CONSTRAINT "FK_sms_notifications_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL
        );
        
        CREATE INDEX idx_sms_notifications_user_id ON sms_notifications (user_id);
        CREATE INDEX idx_sms_notifications_booking_id ON sms_notifications (booking_id);
        CREATE INDEX idx_sms_notifications_status ON sms_notifications (status);
        CREATE INDEX idx_sms_notifications_status_scheduled ON sms_notifications (status, scheduled_for);
        CREATE INDEX idx_sms_notifications_provider_id ON sms_notifications (provider_message_id);
    END IF;
END $$;

-- Crear tabla tour_reviews si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'tour_reviews') THEN
        CREATE TABLE tour_reviews (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            tour_id uuid NOT NULL,
            user_id uuid NOT NULL,
            booking_id uuid,
            rating integer NOT NULL,
            title character varying(200),
            comment character varying(2000),
            is_approved boolean NOT NULL DEFAULT FALSE,
            is_verified boolean NOT NULL DEFAULT FALSE,
            "TourId1" uuid,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_tour_reviews" PRIMARY KEY (id),
            CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
            CONSTRAINT "FK_tour_reviews_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE,
            CONSTRAINT "FK_tour_reviews_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT "FK_tour_reviews_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
            CONSTRAINT "FK_tour_reviews_tours_TourId1" FOREIGN KEY ("TourId1") REFERENCES tours(id)
        );
        
        CREATE UNIQUE INDEX "IX_tour_reviews_tour_id_user_id" ON tour_reviews (tour_id, user_id);
        CREATE INDEX "IX_tour_reviews_tour_id" ON tour_reviews (tour_id);
        CREATE INDEX "IX_tour_reviews_user_id" ON tour_reviews (user_id);
        CREATE INDEX "IX_tour_reviews_booking_id" ON tour_reviews (booking_id);
        CREATE INDEX "IX_tour_reviews_is_approved" ON tour_reviews (is_approved);
        CREATE INDEX "IX_tour_reviews_rating" ON tour_reviews (rating);
        CREATE INDEX "IX_tour_reviews_TourId1" ON tour_reviews ("TourId1");
    END IF;
END $$;

-- Crear tabla user_favorites si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_favorites') THEN
        CREATE TABLE user_favorites (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            user_id uuid NOT NULL,
            tour_id uuid NOT NULL,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_user_favorites" PRIMARY KEY (id),
            CONSTRAINT "FK_user_favorites_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT "FK_user_favorites_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE
        );
        
        CREATE UNIQUE INDEX "IX_user_favorites_user_id_tour_id" ON user_favorites (user_id, tour_id);
        CREATE INDEX "IX_user_favorites_tour_id" ON user_favorites (tour_id);
    END IF;
END $$;

-- Crear tabla waitlist si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'waitlist') THEN
        CREATE TABLE waitlist (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            tour_id uuid NOT NULL,
            tour_date_id uuid,
            user_id uuid NOT NULL,
            number_of_participants integer NOT NULL,
            is_notified boolean NOT NULL DEFAULT FALSE,
            notified_at timestamp with time zone,
            is_active boolean NOT NULL DEFAULT TRUE,
            priority integer NOT NULL,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_waitlist" PRIMARY KEY (id),
            CONSTRAINT chk_participants_positive CHECK (number_of_participants > 0),
            CONSTRAINT chk_priority_positive CHECK (priority >= 0),
            CONSTRAINT "FK_waitlist_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES tours(id) ON DELETE CASCADE,
            CONSTRAINT "FK_waitlist_tour_dates_tour_date_id" FOREIGN KEY (tour_date_id) REFERENCES tour_dates(id) ON DELETE SET NULL,
            CONSTRAINT "FK_waitlist_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
        
        CREATE INDEX "IX_waitlist_tour_id" ON waitlist (tour_id);
        CREATE INDEX "IX_waitlist_tour_date_id" ON waitlist (tour_date_id);
        CREATE INDEX "IX_waitlist_user_id" ON waitlist (user_id);
        CREATE INDEX "IX_waitlist_is_active" ON waitlist (is_active);
        CREATE INDEX "IX_waitlist_is_notified" ON waitlist (is_notified);
        CREATE INDEX "IX_waitlist_tour_id_tour_date_id_is_active_priority" ON waitlist (tour_id, tour_date_id, is_active, priority);
    END IF;
END $$;

-- Crear tabla user_two_factor si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'user_two_factor') THEN
        CREATE TABLE user_two_factor (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            user_id uuid NOT NULL,
            secret_key character varying(100),
            is_enabled boolean NOT NULL DEFAULT FALSE,
            backup_codes character varying(2000),
            phone_number character varying(20),
            is_sms_enabled boolean NOT NULL DEFAULT FALSE,
            enabled_at timestamp with time zone,
            last_used_at timestamp with time zone,
            "UserId1" uuid,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_user_two_factor" PRIMARY KEY (id),
            CONSTRAINT "FK_user_two_factor_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT "FK_user_two_factor_users_UserId1" FOREIGN KEY ("UserId1") REFERENCES users(id)
        );
        
        CREATE UNIQUE INDEX "IX_user_two_factor_user_id" ON user_two_factor (user_id);
        CREATE INDEX "IX_user_two_factor_is_enabled" ON user_two_factor (is_enabled);
        CREATE UNIQUE INDEX "IX_user_two_factor_UserId1" ON user_two_factor ("UserId1");
    END IF;
END $$;

-- Crear tabla login_history si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'login_history') THEN
        CREATE TABLE login_history (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            user_id uuid NOT NULL,
            ip_address character varying(45) NOT NULL,
            user_agent character varying(500),
            is_successful boolean NOT NULL,
            failure_reason character varying(200),
            location character varying(200),
            "UserId1" uuid,
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_login_history" PRIMARY KEY (id),
            CONSTRAINT "FK_login_history_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
            CONSTRAINT "FK_login_history_users_UserId1" FOREIGN KEY ("UserId1") REFERENCES users(id)
        );
        
        CREATE INDEX "IX_login_history_user_id" ON login_history (user_id);
        CREATE INDEX "IX_login_history_created_at" ON login_history (created_at);
        CREATE INDEX "IX_login_history_ip_address" ON login_history (ip_address);
        CREATE INDEX "IX_login_history_is_successful" ON login_history (is_successful);
        CREATE INDEX "IX_login_history_user_id_created_at" ON login_history (user_id, created_at);
        CREATE INDEX "IX_login_history_UserId1" ON login_history ("UserId1");
    END IF;
END $$;

-- Crear tabla analytics_events si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'analytics_events') THEN
        CREATE TABLE analytics_events (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            "event" character varying(100) NOT NULL,
            entity_type character varying(50),
            entity_id uuid,
            session_id uuid NOT NULL,
            user_id uuid,
            metadata jsonb,
            device character varying(20),
            user_agent text,
            referrer text,
            country character varying(2),
            city character varying(100),
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            "UpdatedAt" timestamp with time zone,
            CONSTRAINT "PK_analytics_events" PRIMARY KEY (id),
            CONSTRAINT "FK_analytics_events_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
        );
        
        CREATE INDEX "IX_analytics_events_user_id" ON analytics_events (user_id);
        CREATE INDEX "IX_analytics_events_session_id" ON analytics_events (session_id);
        CREATE INDEX "IX_analytics_events_event" ON analytics_events ("event");
        CREATE INDEX "IX_analytics_events_entity_type_entity_id" ON analytics_events (entity_type, entity_id);
        CREATE INDEX "IX_analytics_events_created_at" ON analytics_events (created_at);
    END IF;
END $$;

-- Crear tabla blog_comments si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'blog_comments') THEN
        CREATE TABLE blog_comments (
            "Id" uuid NOT NULL,
            "BlogPostId" uuid NOT NULL,
            "UserId" uuid,
            "ParentCommentId" uuid,
            "AuthorName" character varying(200) NOT NULL,
            "AuthorEmail" character varying(200) NOT NULL,
            "AuthorWebsite" character varying(500),
            "Content" character varying(5000) NOT NULL,
            "Status" integer NOT NULL,
            "AdminNotes" character varying(1000),
            "UserIp" character varying(50),
            "UserAgent" character varying(500),
            "Likes" integer NOT NULL DEFAULT 0,
            "Dislikes" integer NOT NULL DEFAULT 0,
            "CreatedAt" timestamp with time zone NOT NULL,
            "UpdatedAt" timestamp with time zone,
            CONSTRAINT "PK_blog_comments" PRIMARY KEY ("Id"),
            CONSTRAINT "CK_BlogComment_Dislikes_NonNegative" CHECK (dislikes >= 0),
            CONSTRAINT "CK_BlogComment_Likes_NonNegative" CHECK (likes >= 0),
            CONSTRAINT "FK_blog_comments_pages_BlogPostId" FOREIGN KEY ("BlogPostId") REFERENCES pages(id) ON DELETE CASCADE,
            CONSTRAINT "FK_blog_comments_users_UserId" FOREIGN KEY ("UserId") REFERENCES users(id) ON DELETE SET NULL,
            CONSTRAINT "FK_blog_comments_blog_comments_ParentCommentId" FOREIGN KEY ("ParentCommentId") REFERENCES blog_comments("Id") ON DELETE CASCADE
        );
        
        CREATE INDEX "IX_blog_comments_BlogPostId" ON blog_comments ("BlogPostId");
        CREATE INDEX "IX_blog_comments_UserId" ON blog_comments ("UserId");
        CREATE INDEX "IX_blog_comments_ParentCommentId" ON blog_comments ("ParentCommentId");
        CREATE INDEX "IX_blog_comments_Status" ON blog_comments ("Status");
        CREATE INDEX "IX_blog_comments_CreatedAt" ON blog_comments ("CreatedAt");
        CREATE INDEX "IX_blog_comments_BlogPostId_Status_CreatedAt" ON blog_comments ("BlogPostId", "Status", "CreatedAt");
    END IF;
END $$;

-- Crear tabla invoices si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'invoices') THEN
        CREATE TABLE invoices (
            id uuid NOT NULL DEFAULT (uuid_generate_v4()),
            invoice_number character varying(50) NOT NULL,
            booking_id uuid NOT NULL,
            user_id uuid NOT NULL,
            currency character varying(3) NOT NULL DEFAULT 'USD',
            subtotal numeric(10,2) NOT NULL,
            discount numeric(10,2) NOT NULL DEFAULT 0,
            taxes numeric(10,2) NOT NULL DEFAULT 0,
            total numeric(10,2) NOT NULL,
            language character varying(2) NOT NULL DEFAULT 'ES',
            issued_at timestamp with time zone NOT NULL,
            pdf_url character varying(500),
            status character varying(20) NOT NULL DEFAULT 'Issued',
            created_at timestamp with time zone NOT NULL DEFAULT (CURRENT_TIMESTAMP),
            updated_at timestamp with time zone,
            CONSTRAINT "PK_invoices" PRIMARY KEY (id),
            CONSTRAINT chk_invoice_language CHECK (language IN ('ES', 'EN')),
            CONSTRAINT chk_invoice_status CHECK (status IN ('Issued', 'Void')),
            CONSTRAINT chk_invoice_total_positive CHECK (total >= 0),
            CONSTRAINT "FK_invoices_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE RESTRICT,
            CONSTRAINT "FK_invoices_users_user_id" FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
        );
        
        CREATE UNIQUE INDEX "IX_invoices_invoice_number" ON invoices (invoice_number);
        CREATE INDEX "IX_invoices_booking_id" ON invoices (booking_id);
        CREATE INDEX "IX_invoices_user_id" ON invoices (user_id);
        CREATE INDEX "IX_invoices_issued_at" ON invoices (issued_at);
    END IF;
END $$;

-- Marcar migración como aplicada
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM "__EFMigrationsHistory" 
        WHERE "MigrationId" = '20260124171843_AddInvoicesBlogCommentsAnalytics'
    ) THEN
        INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
        VALUES ('20260124171843_AddInvoicesBlogCommentsAnalytics', '8.0.0');
    END IF;
END $$;
