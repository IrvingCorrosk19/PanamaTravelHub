--
-- PostgreSQL database dump
--

\restrict Z5mBRPBsw3rwvhgCvq2OVyWVsdadaNAfgGpMawtba3tOHV7kM1tmarXCAeWsyW5

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS fk_bookings_country_id;
ALTER TABLE IF EXISTS ONLY public.waitlist DROP CONSTRAINT IF EXISTS "FK_waitlist_users_user_id";
ALTER TABLE IF EXISTS ONLY public.waitlist DROP CONSTRAINT IF EXISTS "FK_waitlist_tours_tour_id";
ALTER TABLE IF EXISTS ONLY public.waitlist DROP CONSTRAINT IF EXISTS "FK_waitlist_tour_dates_tour_date_id";
ALTER TABLE IF EXISTS ONLY public.user_two_factor DROP CONSTRAINT IF EXISTS "FK_user_two_factor_users_user_id";
ALTER TABLE IF EXISTS ONLY public.user_two_factor DROP CONSTRAINT IF EXISTS "FK_user_two_factor_users_UserId1";
ALTER TABLE IF EXISTS ONLY public.user_favorites DROP CONSTRAINT IF EXISTS "FK_user_favorites_users_user_id";
ALTER TABLE IF EXISTS ONLY public.user_favorites DROP CONSTRAINT IF EXISTS "FK_user_favorites_tours_tour_id";
ALTER TABLE IF EXISTS ONLY public.tour_tag_assignments DROP CONSTRAINT IF EXISTS "FK_tour_tag_assignments_tours_tour_id";
ALTER TABLE IF EXISTS ONLY public.tour_tag_assignments DROP CONSTRAINT IF EXISTS "FK_tour_tag_assignments_tour_tags_tag_id";
ALTER TABLE IF EXISTS ONLY public.tour_reviews DROP CONSTRAINT IF EXISTS "FK_tour_reviews_users_user_id";
ALTER TABLE IF EXISTS ONLY public.tour_reviews DROP CONSTRAINT IF EXISTS "FK_tour_reviews_tours_tour_id";
ALTER TABLE IF EXISTS ONLY public.tour_reviews DROP CONSTRAINT IF EXISTS "FK_tour_reviews_tours_TourId1";
ALTER TABLE IF EXISTS ONLY public.tour_reviews DROP CONSTRAINT IF EXISTS "FK_tour_reviews_bookings_booking_id";
ALTER TABLE IF EXISTS ONLY public.tour_category_assignments DROP CONSTRAINT IF EXISTS "FK_tour_category_assignments_tours_tour_id";
ALTER TABLE IF EXISTS ONLY public.tour_category_assignments DROP CONSTRAINT IF EXISTS "FK_tour_category_assignments_tour_categories_category_id";
ALTER TABLE IF EXISTS ONLY public.sms_notifications DROP CONSTRAINT IF EXISTS "FK_sms_notifications_users_user_id";
ALTER TABLE IF EXISTS ONLY public.sms_notifications DROP CONSTRAINT IF EXISTS "FK_sms_notifications_bookings_booking_id";
ALTER TABLE IF EXISTS ONLY public.login_history DROP CONSTRAINT IF EXISTS "FK_login_history_users_user_id";
ALTER TABLE IF EXISTS ONLY public.login_history DROP CONSTRAINT IF EXISTS "FK_login_history_users_UserId1";
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS "FK_invoices_users_user_id";
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS "FK_invoices_bookings_booking_id";
ALTER TABLE IF EXISTS ONLY public.coupons DROP CONSTRAINT IF EXISTS "FK_coupons_tours_applicable_tour_id";
ALTER TABLE IF EXISTS ONLY public.coupon_usages DROP CONSTRAINT IF EXISTS "FK_coupon_usages_users_user_id";
ALTER TABLE IF EXISTS ONLY public.coupon_usages DROP CONSTRAINT IF EXISTS "FK_coupon_usages_coupons_coupon_id";
ALTER TABLE IF EXISTS ONLY public.coupon_usages DROP CONSTRAINT IF EXISTS "FK_coupon_usages_bookings_booking_id";
ALTER TABLE IF EXISTS ONLY public.blog_comments DROP CONSTRAINT IF EXISTS "FK_blog_comments_users_UserId";
ALTER TABLE IF EXISTS ONLY public.blog_comments DROP CONSTRAINT IF EXISTS "FK_blog_comments_pages_BlogPostId";
ALTER TABLE IF EXISTS ONLY public.blog_comments DROP CONSTRAINT IF EXISTS "FK_blog_comments_blog_comments_ParentCommentId";
ALTER TABLE IF EXISTS ONLY public.analytics_events DROP CONSTRAINT IF EXISTS "FK_analytics_events_users_user_id";
DROP INDEX IF EXISTS public.uq_tour_tag;
DROP INDEX IF EXISTS public.uq_tour_category;
DROP INDEX IF EXISTS public.idx_users_email_verification_token;
DROP INDEX IF EXISTS public.idx_tours_tour_date;
DROP INDEX IF EXISTS public.idx_tour_tags_slug;
DROP INDEX IF EXISTS public.idx_tour_tag_assignments_tour;
DROP INDEX IF EXISTS public.idx_tour_tag_assignments_tag;
DROP INDEX IF EXISTS public.idx_tour_category_assignments_tour;
DROP INDEX IF EXISTS public.idx_tour_category_assignments_category;
DROP INDEX IF EXISTS public.idx_tour_categories_slug;
DROP INDEX IF EXISTS public.idx_tour_categories_active;
DROP INDEX IF EXISTS public.idx_sms_notifications_user_id;
DROP INDEX IF EXISTS public.idx_sms_notifications_status_scheduled;
DROP INDEX IF EXISTS public.idx_sms_notifications_status;
DROP INDEX IF EXISTS public.idx_sms_notifications_provider_id;
DROP INDEX IF EXISTS public.idx_sms_notifications_booking_id;
DROP INDEX IF EXISTS public.idx_countries_code;
DROP INDEX IF EXISTS public.idx_countries_active_order;
DROP INDEX IF EXISTS public.idx_bookings_country_id;
DROP INDEX IF EXISTS public."IX_waitlist_user_id";
DROP INDEX IF EXISTS public."IX_waitlist_tour_id_tour_date_id_is_active_priority";
DROP INDEX IF EXISTS public."IX_waitlist_tour_id";
DROP INDEX IF EXISTS public."IX_waitlist_tour_date_id";
DROP INDEX IF EXISTS public."IX_waitlist_is_notified";
DROP INDEX IF EXISTS public."IX_waitlist_is_active";
DROP INDEX IF EXISTS public."IX_user_two_factor_user_id";
DROP INDEX IF EXISTS public."IX_user_two_factor_is_enabled";
DROP INDEX IF EXISTS public."IX_user_two_factor_UserId1";
DROP INDEX IF EXISTS public."IX_user_favorites_user_id_tour_id";
DROP INDEX IF EXISTS public."IX_user_favorites_tour_id";
DROP INDEX IF EXISTS public."IX_tour_reviews_user_id";
DROP INDEX IF EXISTS public."IX_tour_reviews_tour_id_user_id";
DROP INDEX IF EXISTS public."IX_tour_reviews_tour_id";
DROP INDEX IF EXISTS public."IX_tour_reviews_rating";
DROP INDEX IF EXISTS public."IX_tour_reviews_is_approved";
DROP INDEX IF EXISTS public."IX_tour_reviews_booking_id";
DROP INDEX IF EXISTS public."IX_tour_reviews_TourId1";
DROP INDEX IF EXISTS public."IX_login_history_user_id_created_at";
DROP INDEX IF EXISTS public."IX_login_history_user_id";
DROP INDEX IF EXISTS public."IX_login_history_is_successful";
DROP INDEX IF EXISTS public."IX_login_history_ip_address";
DROP INDEX IF EXISTS public."IX_login_history_created_at";
DROP INDEX IF EXISTS public."IX_login_history_UserId1";
DROP INDEX IF EXISTS public."IX_invoices_user_id";
DROP INDEX IF EXISTS public."IX_invoices_issued_at";
DROP INDEX IF EXISTS public."IX_invoices_invoice_number";
DROP INDEX IF EXISTS public."IX_invoices_booking_id";
DROP INDEX IF EXISTS public."IX_coupons_valid_until";
DROP INDEX IF EXISTS public."IX_coupons_valid_from";
DROP INDEX IF EXISTS public."IX_coupons_is_active";
DROP INDEX IF EXISTS public."IX_coupons_code";
DROP INDEX IF EXISTS public."IX_coupons_applicable_tour_id";
DROP INDEX IF EXISTS public."IX_coupon_usages_user_id";
DROP INDEX IF EXISTS public."IX_coupon_usages_coupon_id_user_id";
DROP INDEX IF EXISTS public."IX_coupon_usages_coupon_id";
DROP INDEX IF EXISTS public."IX_coupon_usages_booking_id";
DROP INDEX IF EXISTS public."IX_blog_comments_UserId";
DROP INDEX IF EXISTS public."IX_blog_comments_Status";
DROP INDEX IF EXISTS public."IX_blog_comments_ParentCommentId";
DROP INDEX IF EXISTS public."IX_blog_comments_CreatedAt";
DROP INDEX IF EXISTS public."IX_blog_comments_BlogPostId_Status_CreatedAt";
DROP INDEX IF EXISTS public."IX_blog_comments_BlogPostId";
DROP INDEX IF EXISTS public."IX_analytics_events_user_id";
DROP INDEX IF EXISTS public."IX_analytics_events_session_id";
DROP INDEX IF EXISTS public."IX_analytics_events_event";
DROP INDEX IF EXISTS public."IX_analytics_events_entity_type_entity_id";
DROP INDEX IF EXISTS public."IX_analytics_events_created_at";
ALTER TABLE IF EXISTS ONLY public.countries DROP CONSTRAINT IF EXISTS countries_pkey;
ALTER TABLE IF EXISTS ONLY public.countries DROP CONSTRAINT IF EXISTS countries_code_key;
ALTER TABLE IF EXISTS ONLY public.waitlist DROP CONSTRAINT IF EXISTS "PK_waitlist";
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS "PK_users";
ALTER TABLE IF EXISTS ONLY public.user_two_factor DROP CONSTRAINT IF EXISTS "PK_user_two_factor";
ALTER TABLE IF EXISTS ONLY public.user_favorites DROP CONSTRAINT IF EXISTS "PK_user_favorites";
ALTER TABLE IF EXISTS ONLY public.tours DROP CONSTRAINT IF EXISTS "PK_tours";
ALTER TABLE IF EXISTS ONLY public.tour_tags DROP CONSTRAINT IF EXISTS "PK_tour_tags";
ALTER TABLE IF EXISTS ONLY public.tour_tag_assignments DROP CONSTRAINT IF EXISTS "PK_tour_tag_assignments";
ALTER TABLE IF EXISTS ONLY public.tour_reviews DROP CONSTRAINT IF EXISTS "PK_tour_reviews";
ALTER TABLE IF EXISTS ONLY public.tour_dates DROP CONSTRAINT IF EXISTS "PK_tour_dates";
ALTER TABLE IF EXISTS ONLY public.tour_category_assignments DROP CONSTRAINT IF EXISTS "PK_tour_category_assignments";
ALTER TABLE IF EXISTS ONLY public.tour_categories DROP CONSTRAINT IF EXISTS "PK_tour_categories";
ALTER TABLE IF EXISTS ONLY public.sms_notifications DROP CONSTRAINT IF EXISTS "PK_sms_notifications";
ALTER TABLE IF EXISTS ONLY public.pages DROP CONSTRAINT IF EXISTS "PK_pages";
ALTER TABLE IF EXISTS ONLY public.login_history DROP CONSTRAINT IF EXISTS "PK_login_history";
ALTER TABLE IF EXISTS ONLY public.invoices DROP CONSTRAINT IF EXISTS "PK_invoices";
ALTER TABLE IF EXISTS ONLY public.invoice_sequences DROP CONSTRAINT IF EXISTS "PK_invoice_sequences";
ALTER TABLE IF EXISTS ONLY public.email_settings DROP CONSTRAINT IF EXISTS "PK_email_settings";
ALTER TABLE IF EXISTS ONLY public.coupons DROP CONSTRAINT IF EXISTS "PK_coupons";
ALTER TABLE IF EXISTS ONLY public.coupon_usages DROP CONSTRAINT IF EXISTS "PK_coupon_usages";
ALTER TABLE IF EXISTS ONLY public.bookings DROP CONSTRAINT IF EXISTS "PK_bookings";
ALTER TABLE IF EXISTS ONLY public.blog_comments DROP CONSTRAINT IF EXISTS "PK_blog_comments";
ALTER TABLE IF EXISTS ONLY public.analytics_events DROP CONSTRAINT IF EXISTS "PK_analytics_events";
DROP TABLE IF EXISTS public.waitlist;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_two_factor;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.user_favorites;
DROP TABLE IF EXISTS public.tours;
DROP TABLE IF EXISTS public.tour_tags;
DROP TABLE IF EXISTS public.tour_tag_assignments;
DROP TABLE IF EXISTS public.tour_reviews;
DROP TABLE IF EXISTS public.tour_images;
DROP TABLE IF EXISTS public.tour_dates;
DROP TABLE IF EXISTS public.tour_category_assignments;
DROP TABLE IF EXISTS public.tour_categories;
DROP TABLE IF EXISTS public.sms_notifications;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.refresh_tokens;
DROP TABLE IF EXISTS public.payments;
DROP TABLE IF EXISTS public.password_reset_tokens;
DROP TABLE IF EXISTS public.pages;
DROP TABLE IF EXISTS public.media_files;
DROP TABLE IF EXISTS public.login_history;
DROP TABLE IF EXISTS public.invoices;
DROP TABLE IF EXISTS public.invoice_sequences;
DROP TABLE IF EXISTS public.home_page_content;
DROP TABLE IF EXISTS public.email_settings;
DROP TABLE IF EXISTS public.email_notifications;
DROP TABLE IF EXISTS public.coupons;
DROP TABLE IF EXISTS public.coupon_usages;
DROP TABLE IF EXISTS public.countries;
DROP TABLE IF EXISTS public.bookings;
DROP TABLE IF EXISTS public.booking_participants;
DROP TABLE IF EXISTS public.blog_comments;
DROP TABLE IF EXISTS public.audit_logs;
DROP TABLE IF EXISTS public.analytics_events;
DROP TABLE IF EXISTS public."__EFMigrationsHistory";
DROP TABLE IF EXISTS public."DataProtectionKeys";
DROP FUNCTION IF EXISTS public.update_updated_at_column();
DROP FUNCTION IF EXISTS public.reserve_tour_spots(p_tour_id uuid, p_tour_date_id uuid, p_participants integer);
DROP FUNCTION IF EXISTS public.release_tour_spots(p_tour_id uuid, p_tour_date_id uuid, p_participants integer);
DROP EXTENSION IF EXISTS "uuid-ossp";
--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: release_tour_spots(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.release_tour_spots(p_tour_id uuid, p_tour_date_id uuid, p_participants integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si hay tour_date_id, trabajar con tour_dates
    IF p_tour_date_id IS NOT NULL THEN
        UPDATE tour_dates
        SET available_spots = LEAST(
            available_spots + p_participants,
            (SELECT max_capacity FROM tours WHERE id = p_tour_id)
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_date_id;
        
        RETURN TRUE;
    ELSE
        -- Trabajar con tours directamente
        UPDATE tours
        SET available_spots = LEAST(
            available_spots + p_participants,
            max_capacity
        ),
        updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_id;
        
        RETURN TRUE;
    END IF;
END;
$$;


--
-- Name: reserve_tour_spots(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reserve_tour_spots(p_tour_id uuid, p_tour_date_id uuid, p_participants integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_available_spots INTEGER;
    v_max_capacity INTEGER;
BEGIN
    -- Si hay tour_date_id, trabajar con tour_dates
    IF p_tour_date_id IS NOT NULL THEN
        SELECT available_spots INTO v_available_spots
        FROM tour_dates
        WHERE id = p_tour_date_id
          AND is_active = true
        FOR UPDATE; -- Lock row para prevenir race conditions
        
        IF v_available_spots IS NULL THEN
            RETURN FALSE; -- Tour date no existe o no estÃ¡ activo
        END IF;
        
        IF v_available_spots < p_participants THEN
            RETURN FALSE; -- No hay suficientes cupos
        END IF;
        
        -- Actualizar cupos disponibles
        UPDATE tour_dates
        SET available_spots = available_spots - p_participants,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_date_id;
        
        RETURN TRUE;
    ELSE
        -- Trabajar con tours directamente
        SELECT available_spots, max_capacity INTO v_available_spots, v_max_capacity
        FROM tours
        WHERE id = p_tour_id
          AND is_active = true
        FOR UPDATE; -- Lock row
        
        IF v_available_spots IS NULL THEN
            RETURN FALSE; -- Tour no existe o no estÃ¡ activo
        END IF;
        
        IF v_available_spots < p_participants THEN
            RETURN FALSE; -- No hay suficientes cupos
        END IF;
        
        -- Actualizar cupos disponibles
        UPDATE tours
        SET available_spots = available_spots - p_participants,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_tour_id;
        
        RETURN TRUE;
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: DataProtectionKeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."DataProtectionKeys" (
    "Id" integer NOT NULL,
    "FriendlyName" text,
    "Xml" text
);


--
-- Name: DataProtectionKeys_Id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public."DataProtectionKeys" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."DataProtectionKeys_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


--
-- Name: analytics_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_events (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    event character varying(100) NOT NULL,
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
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAt" timestamp with time zone
);


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    entity_type character varying(100) NOT NULL,
    entity_id uuid NOT NULL,
    action character varying(50) NOT NULL,
    before_state jsonb,
    after_state jsonb,
    ip_address character varying(45),
    user_agent text,
    correlation_id uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_action CHECK (((action)::text = ANY (ARRAY[('CREATE'::character varying)::text, ('UPDATE'::character varying)::text, ('DELETE'::character varying)::text, ('READ'::character varying)::text, ('LOGIN'::character varying)::text, ('LOGOUT'::character varying)::text, ('PAYMENT'::character varying)::text, ('CANCEL'::character varying)::text])))
);


--
-- Name: blog_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_comments (
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
    "Likes" integer DEFAULT 0 NOT NULL,
    "Dislikes" integer DEFAULT 0 NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "CK_BlogComment_Dislikes_NonNegative" CHECK (("Dislikes" >= 0)),
    CONSTRAINT "CK_BlogComment_Likes_NonNegative" CHECK (("Likes" >= 0))
);


--
-- Name: booking_participants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_participants (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    booking_id uuid NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(255),
    phone character varying(20),
    date_of_birth date,
    special_requirements text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_email_format_participant CHECK (((email IS NULL) OR ((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)))
);


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    tour_id uuid NOT NULL,
    tour_date_id uuid,
    status integer DEFAULT 1 NOT NULL,
    number_of_participants integer NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    expires_at timestamp without time zone,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    country_id uuid,
    allow_partial_payments boolean DEFAULT false NOT NULL,
    payment_plan_type integer DEFAULT 0,
    CONSTRAINT chk_booking_status CHECK ((status = ANY (ARRAY[1, 2, 3, 4, 5]))),
    CONSTRAINT chk_participants_positive CHECK ((number_of_participants > 0)),
    CONSTRAINT chk_total_amount_positive CHECK ((total_amount >= (0)::numeric))
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    code character varying(2) NOT NULL,
    name character varying(100) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_country_code_length CHECK ((length((code)::text) = 2)),
    CONSTRAINT chk_display_order CHECK ((display_order >= 0))
);


--
-- Name: coupon_usages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupon_usages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    coupon_id uuid NOT NULL,
    user_id uuid NOT NULL,
    booking_id uuid NOT NULL,
    discount_amount numeric(18,2) NOT NULL,
    original_amount numeric(18,2) NOT NULL,
    final_amount numeric(18,2) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.coupons (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    current_uses integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_first_time_only boolean DEFAULT false NOT NULL,
    applicable_tour_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT chk_current_uses_non_negative CHECK ((current_uses >= 0)),
    CONSTRAINT chk_discount_value_positive CHECK ((discount_value > (0)::numeric)),
    CONSTRAINT chk_max_uses_per_user_positive CHECK (((max_uses_per_user IS NULL) OR (max_uses_per_user > 0))),
    CONSTRAINT chk_max_uses_positive CHECK (((max_uses IS NULL) OR (max_uses > 0))),
    CONSTRAINT chk_percentage_range CHECK (((discount_type <> 1) OR ((discount_value >= (0)::numeric) AND (discount_value <= (100)::numeric))))
);


--
-- Name: email_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    booking_id uuid,
    type integer NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    to_email character varying(255) NOT NULL,
    subject character varying(500) NOT NULL,
    body text NOT NULL,
    sent_at timestamp without time zone,
    retry_count integer DEFAULT 0 NOT NULL,
    error_message text,
    scheduled_for timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_email_format_notification CHECK (((to_email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT chk_email_status CHECK ((status = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT chk_email_type CHECK ((type = ANY (ARRAY[1, 2, 3, 4]))),
    CONSTRAINT chk_retry_count CHECK ((retry_count >= 0))
);


--
-- Name: email_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_settings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    smtp_host character varying(200) NOT NULL,
    smtp_port integer NOT NULL,
    smtp_username character varying(255),
    smtp_password character varying(500),
    from_address character varying(255) NOT NULL,
    from_name character varying(200) NOT NULL,
    enable_ssl boolean NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: home_page_content; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.home_page_content (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    hero_title character varying(200) DEFAULT 'Descubre PanamÃ¡'::character varying NOT NULL,
    hero_subtitle character varying(500) DEFAULT 'Explora los destinos mÃ¡s increÃ­bles con nuestros tours exclusivos'::character varying NOT NULL,
    hero_search_placeholder character varying(100) DEFAULT 'Buscar tours...'::character varying NOT NULL,
    hero_search_button character varying(50) DEFAULT 'Buscar'::character varying NOT NULL,
    tours_section_title character varying(200) DEFAULT 'Tours Disponibles'::character varying NOT NULL,
    tours_section_subtitle character varying(300) DEFAULT 'Selecciona tu prÃ³xima aventura'::character varying NOT NULL,
    loading_tours_text character varying(200) DEFAULT 'Cargando tours...'::character varying NOT NULL,
    error_loading_tours_text character varying(300) DEFAULT 'Error al cargar los tours. Por favor, intenta de nuevo.'::character varying NOT NULL,
    no_tours_found_text character varying(200) DEFAULT 'No se encontraron tours disponibles.'::character varying NOT NULL,
    footer_brand_text character varying(100) DEFAULT 'ToursPanama'::character varying NOT NULL,
    footer_description character varying(500) DEFAULT 'Tu plataforma de confianza para descubrir PanamÃ¡'::character varying NOT NULL,
    footer_copyright character varying(200) DEFAULT 'Â© 2024 ToursPanama. Todos los derechos reservados.'::character varying NOT NULL,
    nav_brand_text character varying(100) DEFAULT 'ToursPanama'::character varying NOT NULL,
    nav_tours_link character varying(50) DEFAULT 'Tours'::character varying NOT NULL,
    nav_bookings_link character varying(50) DEFAULT 'Mis Reservas'::character varying NOT NULL,
    nav_login_link character varying(50) DEFAULT 'Iniciar SesiÃ³n'::character varying NOT NULL,
    nav_logout_button character varying(50) DEFAULT 'Cerrar SesiÃ³n'::character varying NOT NULL,
    page_title character varying(200) DEFAULT 'ToursPanama â€” Descubre los Mejores Tours en PanamÃ¡'::character varying NOT NULL,
    meta_description character varying(500) DEFAULT 'Plataforma moderna de reservas de tours en PanamÃ¡. Explora, reserva y disfruta de las mejores experiencias turÃ­sticas.'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    logo_url character varying(500),
    favicon_url character varying(500),
    logo_url_social character varying(500),
    hero_image_url character varying(500)
);


--
-- Name: invoice_sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_sequences (
    year integer NOT NULL,
    current_value integer DEFAULT 0 NOT NULL
);


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    invoice_number character varying(50) NOT NULL,
    booking_id uuid NOT NULL,
    user_id uuid NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    discount numeric(10,2) DEFAULT 0 NOT NULL,
    taxes numeric(10,2) DEFAULT 0 NOT NULL,
    total numeric(10,2) NOT NULL,
    language character varying(2) DEFAULT 'ES'::character varying NOT NULL,
    issued_at timestamp with time zone NOT NULL,
    pdf_url character varying(500),
    status character varying(20) DEFAULT 'Issued'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT chk_invoice_language CHECK (((language)::text = ANY ((ARRAY['ES'::character varying, 'EN'::character varying])::text[]))),
    CONSTRAINT chk_invoice_status CHECK (((status)::text = ANY ((ARRAY['Issued'::character varying, 'Void'::character varying])::text[]))),
    CONSTRAINT chk_invoice_total_positive CHECK ((total >= (0)::numeric))
);


--
-- Name: login_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.login_history (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    ip_address character varying(45) NOT NULL,
    user_agent character varying(500),
    is_successful boolean NOT NULL,
    failure_reason character varying(200),
    location character varying(200),
    "UserId1" uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: media_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.media_files (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(1000) NOT NULL,
    file_url character varying(1000) NOT NULL,
    mime_type character varying(100) NOT NULL,
    file_size bigint NOT NULL,
    alt_text character varying(500),
    description character varying(1000),
    category character varying(100),
    is_image boolean DEFAULT false NOT NULL,
    width integer,
    height integer,
    uploaded_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_file_size_positive CHECK ((file_size >= 0)),
    CONSTRAINT chk_height_positive CHECK (((height IS NULL) OR (height > 0))),
    CONSTRAINT chk_width_positive CHECK (((width IS NULL) OR (width > 0)))
);


--
-- Name: pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying(200) NOT NULL,
    slug character varying(200) NOT NULL,
    content text NOT NULL,
    excerpt character varying(500),
    meta_title character varying(200),
    meta_description character varying(500),
    meta_keywords character varying(500),
    is_published boolean DEFAULT false NOT NULL,
    published_at timestamp without time zone,
    template character varying(100),
    display_order integer DEFAULT 0 NOT NULL,
    created_by uuid,
    updated_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_display_order_positive CHECK ((display_order >= 0)),
    CONSTRAINT chk_slug_format CHECK (((slug)::text ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'::text))
);


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(500) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    used_at timestamp without time zone,
    ip_address character varying(45),
    user_agent character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: TABLE password_reset_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.password_reset_tokens IS 'Tokens para recuperaciÃ³n de contraseÃ±a. Expiran en 15 minutos y son de un solo uso.';


--
-- Name: COLUMN password_reset_tokens.token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.token IS 'Token Ãºnico (UUID sin guiones) para resetear contraseÃ±a';


--
-- Name: COLUMN password_reset_tokens.expires_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.expires_at IS 'Fecha y hora de expiraciÃ³n del token (15 minutos desde creaciÃ³n)';


--
-- Name: COLUMN password_reset_tokens.is_used; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.is_used IS 'Indica si el token ya fue utilizado (un solo uso)';


--
-- Name: COLUMN password_reset_tokens.used_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.password_reset_tokens.used_at IS 'Fecha y hora en que se utilizÃ³ el token';


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    booking_id uuid NOT NULL,
    provider integer NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    amount numeric(10,2) NOT NULL,
    provider_transaction_id character varying(255),
    provider_payment_intent_id character varying(255),
    currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    authorized_at timestamp without time zone,
    captured_at timestamp without time zone,
    refunded_at timestamp without time zone,
    failure_reason text,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    is_partial boolean DEFAULT false NOT NULL,
    installment_number integer,
    total_installments integer,
    parent_payment_id uuid,
    CONSTRAINT chk_currency_length CHECK ((length((currency)::text) = 3)),
    CONSTRAINT chk_payment_amount_positive CHECK ((amount > (0)::numeric)),
    CONSTRAINT chk_payment_provider CHECK ((provider = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT chk_payment_status CHECK ((status = ANY (ARRAY[1, 2, 3, 4, 5])))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token character varying(500) NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    is_revoked boolean DEFAULT false NOT NULL,
    revoked_at timestamp without time zone,
    replaced_by_token character varying(500),
    ip_address character varying(45),
    user_agent character varying(500),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_expires_at_future CHECK ((expires_at > created_at))
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: sms_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sms_notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    booking_id uuid,
    type integer NOT NULL,
    status integer DEFAULT 1 NOT NULL,
    to_phone_number character varying(20) NOT NULL,
    message character varying(1600) NOT NULL,
    sent_at timestamp with time zone,
    retry_count integer DEFAULT 0 NOT NULL,
    error_message character varying(1000),
    scheduled_for timestamp with time zone,
    provider_message_id character varying(100),
    provider_response text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: tour_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_categories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: tour_category_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_category_assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tour_id uuid NOT NULL,
    category_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAt" timestamp with time zone
);


--
-- Name: tour_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_dates (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tour_id uuid NOT NULL,
    tour_date_time timestamp without time zone NOT NULL,
    available_spots integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_available_spots_tour_date CHECK ((available_spots >= 0)),
    CONSTRAINT chk_tour_date_future CHECK ((tour_date_time > created_at))
);


--
-- Name: tour_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_images (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tour_id uuid NOT NULL,
    image_url character varying(500) NOT NULL,
    alt_text character varying(200),
    display_order integer DEFAULT 0 NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    CONSTRAINT chk_display_order CHECK ((display_order >= 0))
);


--
-- Name: tour_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_reviews (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tour_id uuid NOT NULL,
    user_id uuid NOT NULL,
    booking_id uuid,
    rating integer NOT NULL,
    title character varying(200),
    comment character varying(2000),
    is_approved boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    "TourId1" uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT chk_rating_range CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: tour_tag_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_tag_assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tour_id uuid NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAt" timestamp with time zone
);


--
-- Name: tour_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tour_tags (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    slug character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "UpdatedAt" timestamp with time zone
);


--
-- Name: tours; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tours (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(200) NOT NULL,
    description text NOT NULL,
    itinerary text,
    price numeric(10,2) NOT NULL,
    max_capacity integer NOT NULL,
    duration_hours integer NOT NULL,
    location character varying(200),
    is_active boolean DEFAULT true NOT NULL,
    available_spots integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    includes text,
    tour_date timestamp without time zone,
    available_languages text,
    hero_title character varying(500),
    hero_subtitle text,
    hero_cta_text character varying(200) DEFAULT 'Ver fechas disponibles'::character varying,
    social_proof_text text,
    has_certified_guide boolean DEFAULT true,
    has_flexible_cancellation boolean DEFAULT true,
    highlights_duration character varying(100),
    highlights_group_type character varying(100),
    highlights_physical_level character varying(100),
    highlights_meeting_point text,
    story_content text,
    includes_list text,
    excludes_list text,
    map_coordinates character varying(100),
    map_reference_text text,
    final_cta_text character varying(500) DEFAULT '¿Listo para vivir esta experiencia?'::character varying,
    final_cta_button_text character varying(200) DEFAULT 'Ver fechas disponibles'::character varying,
    block_order jsonb,
    block_enabled jsonb,
    CONSTRAINT chk_available_spots CHECK (((available_spots >= 0) AND (available_spots <= max_capacity))),
    CONSTRAINT chk_capacity_positive CHECK ((max_capacity > 0)),
    CONSTRAINT chk_duration_positive CHECK ((duration_hours > 0)),
    CONSTRAINT chk_price_positive CHECK ((price >= (0)::numeric))
);


--
-- Name: COLUMN tours.tour_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tours.tour_date IS 'Fecha principal del tour. Puede ser null si el tour tiene múltiples fechas en tour_dates';


--
-- Name: user_favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_favorites (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    tour_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone
);


--
-- Name: user_two_factor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_two_factor (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    secret_key character varying(100),
    is_enabled boolean DEFAULT false NOT NULL,
    backup_codes character varying(2000),
    phone_number character varying(20),
    is_sms_enabled boolean DEFAULT false NOT NULL,
    enabled_at timestamp with time zone,
    last_used_at timestamp with time zone,
    "UserId1" uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(500) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    phone character varying(20),
    is_active boolean DEFAULT true NOT NULL,
    failed_login_attempts integer DEFAULT 0 NOT NULL,
    locked_until timestamp without time zone,
    last_login_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone,
    email_verified boolean DEFAULT false NOT NULL,
    email_verified_at timestamp without time zone,
    email_verification_token character varying(100),
    CONSTRAINT chk_email_format CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT chk_failed_attempts CHECK ((failed_login_attempts >= 0))
);


--
-- Name: waitlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.waitlist (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tour_id uuid NOT NULL,
    tour_date_id uuid,
    user_id uuid NOT NULL,
    number_of_participants integer NOT NULL,
    is_notified boolean DEFAULT false NOT NULL,
    notified_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    priority integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    CONSTRAINT chk_participants_positive CHECK ((number_of_participants > 0)),
    CONSTRAINT chk_priority_positive CHECK ((priority >= 0))
);


--
-- Data for Name: DataProtectionKeys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."DataProtectionKeys" ("Id", "FriendlyName", "Xml") FROM stdin;
1	key-619536ab-eb6f-4a07-9521-b045c1b4826c	<key id="619536ab-eb6f-4a07-9521-b045c1b4826c" version="1"><creationDate>2025-12-24T23:57:52.1021052Z</creationDate><activationDate>2025-12-24T23:57:51.8097607Z</activationDate><expirationDate>2026-03-24T23:57:51.8097607Z</expirationDate><descriptor deserializerType="Microsoft.AspNetCore.DataProtection.AuthenticatedEncryption.ConfigurationModel.AuthenticatedEncryptorDescriptorDeserializer, Microsoft.AspNetCore.DataProtection, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60"><descriptor><encryption algorithm="AES_256_CBC" /><validation algorithm="HMACSHA256" /><masterKey p4:requiresEncryption="true" xmlns:p4="http://schemas.asp.net/2015/03/dataProtection"><!-- Warning: the key below is in an unencrypted form. --><value>QumhzP/6HFyEWusYt9wgVbeMW4i7ztkc64z3Hl+Ed3gnH6y6L3mjUV7OS6FrfbqQR1tELVQ/rgxQH0KPHGm3Lw==</value></masterKey></descriptor></descriptor></key>
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20260124171843_AddInvoicesBlogCommentsAnalytics	8.0.0
20260124220110_AddEmailSettingsTable	8.0.11
\.


--
-- Data for Name: analytics_events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.analytics_events (id, event, entity_type, entity_id, session_id, user_id, metadata, device, user_agent, referrer, country, city, created_at, "UpdatedAt") FROM stdin;
c8e00a03-510e-400c-96ba-ae03d45a3dae	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	439c3e6a-a3cd-4286-8cf1-79499a04bbc5	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:11:48.523275-08	\N
6a361d4f-3ab9-43fb-9ffe-717129d4196d	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	439c3e6a-a3cd-4286-8cf1-79499a04bbc5	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:11:53.878727-08	\N
96fb1cff-dcfc-4ece-afd6-bd9b9eeed369	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	11cb003a-49fa-4055-b327-127d1f1314e7	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:12:18.58198-08	\N
f4c449fd-284b-460f-aa7b-aa91a3772583	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:17:33.367016-08	\N
596732df-90e3-4e0e-b5b5-6c7ddff773cc	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:17:39.588932-08	\N
d77f91f6-f6f0-4764-9b32-09c3fd45dbcd	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:24:52.164541-08	\N
46b76d5c-f3c5-45b1-910c-64af01e143e7	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	\N	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-24 14:25:07.59027-08	\N
71be8a44-c2bb-4fb9-b0ce-cd51cff5607c	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-26 18:02:35.966279-08	\N
16e67dc2-c76c-4f60-89ab-4e1d39d134bf	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-26 18:02:55.573194-08	\N
249d9a48-5179-41f1-9155-eec5d7a4d5fc	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-26 18:24:32.438929-08	\N
b9547598-a8ea-40aa-a69f-002f71abd987	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-26 18:24:50.688594-08	\N
f6ae99d0-ead4-4119-b15f-25584cc012b2	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-26 20:06:22.029913-08	\N
055a5145-aaff-4545-80a7-94b6f4c00e42	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	40a60dfc-c745-4be5-ba5c-62a7cfbda9ba	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-26 20:06:24.657618-08	\N
bb400ecb-90a8-4227-8f40-df4d7384ac19	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:36:59.334398-08	\N
ce7f2226-87b6-4a61-88c6-61a0514c44be	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:37:00.83746-08	\N
c54916bb-91f3-44b7-94ba-8da90c6c5de7	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:42:05.683015-08	\N
7a725fd9-b0b5-4a5b-b7ed-d97915156d23	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:42:07.931025-08	\N
aef9b7d0-616e-4ea8-99ab-1e42f9bbe874	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:42:28.165727-08	\N
06e324b1-14ce-448f-8c63-a1ebd37a50b2	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:42:39.179589-08	\N
7ddc6cdd-c73e-483a-bf36-0d7fee2b2ecc	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:43:14.554523-08	\N
2564dc17-027d-4c21-8949-8968005da437	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:43:15.962962-08	\N
b42d95a2-8222-4351-974f-de84227c1e04	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:50:28.537554-08	\N
ba29d6a4-6f2e-4701-910d-1e7df157d148	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:50:30.909874-08	\N
1475b6b6-c67b-43c3-a86a-41baab03f70e	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 19:50:39.00312-08	\N
8a72a16b-63b6-460c-a0eb-6e654f98dddf	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:03:36.719994-08	\N
658e917b-6bf9-4353-8c91-0034f895dd67	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:03:45.206956-08	\N
cdb08456-62e6-40de-9093-824625d037f8	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:03:55.109292-08	\N
3041761c-2afb-4791-82d4-d335152f555f	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:08:11.425801-08	\N
f5b90ceb-0249-407d-a9b5-f43d2ef2d330	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:09:37.797954-08	\N
e34ccb58-fc82-43fd-8599-254616b5a2bc	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:09:42.01875-08	\N
e7c0718a-2fb0-4007-954a-3fa3bed42ab4	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:15:51.630537-08	\N
9301428a-b2e5-40f2-a841-9591491f1fcf	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:23:39.789406-08	\N
0322ca25-ce02-4da9-9e07-7253148be9f8	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:23:48.231343-08	\N
76653a91-b0aa-48c2-978d-932f69182c5f	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-27 20:23:58.858577-08	\N
08db3631-52a2-4518-bb2c-4c9e2803f379	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-28 19:45:14.209561-08	\N
9405fab5-8cfd-470a-8f0e-50eebbfbc7ea	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	\N	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-28 19:45:20.723932-08	\N
16ff87e0-5506-4428-931a-768d6739b718	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-28 20:18:52.246831-08	\N
c937318e-8acf-4566-8c53-57076fa1ef8d	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-28 20:18:59.344088-08	\N
5b35e110-b447-48a5-9290-67374f41b7b7	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:18:33.628766-08	\N
0251d97c-f5ca-4899-81db-f6c0ee47df78	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:18:35.996102-08	\N
be764e30-38e4-4419-b8f5-39f21bd95acf	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:24:47.339297-08	\N
b3b85071-6e0a-4c27-a978-21435645340c	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:24:50.558892-08	\N
4e629347-a2ce-4505-8142-c975ea6af15d	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:27:05.057159-08	\N
815a4366-b977-47f6-b8c1-d6956c5f88c3	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:27:08.803125-08	\N
43c5c957-8ca2-434f-8e61-fe947d06be45	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:36:02.347332-08	\N
d5817eb5-b522-4adb-b4f4-60532b99503d	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:36:06.577412-08	\N
350554e7-9aa6-470b-8ba2-84f6f35fba4e	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:36:17.657767-08	\N
1f36c7ab-1860-46eb-9e45-924e05ed0d2e	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:36:18.016048-08	\N
a097b673-6705-4718-9d94-0a3e440dc45a	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:36:27.623847-08	\N
d1b3c104-c138-4807-8e53-5be00a2d6b24	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 17:36:35.034444-08	\N
972f07e6-62c8-4021-a8fe-a736abdf4ab6	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 18:18:22.241991-08	\N
6b426978-0485-4914-86af-eeb22fc1b7d0	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 18:18:26.328906-08	\N
1c150d26-b883-4a4d-8f27-b4bd7c7c16b7	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 18:18:36.217171-08	\N
0ad1f2fc-0191-44bc-aefa-b00e2e47a51e	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 18:18:36.563133-08	\N
de61bbab-eb94-4acd-be84-a69bd6723be1	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	\N	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 18:59:19.925611-08	\N
58e1d0c7-5d5a-40b4-bce5-155cbf7510d8	tour_viewed	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{"price": 23, "location": "Panama", "tourName": "Cebaco"}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 19:00:18.833152-08	\N
5663a71e-8033-4aa3-bcf3-574e84d8ae0c	sticky_cta_shown	tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	dd9dc4e0-874e-47b6-8f44-7e56bea119e4	00000000-0000-0000-0000-000000000001	{}	desktop	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	https://localhost:7009/tour-detail.html?id=29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	\N	2026-01-29 19:00:31.163165-08	\N
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_logs (id, user_id, entity_type, entity_id, action, before_state, after_state, ip_address, user_agent, correlation_id, created_at, updated_at) FROM stdin;
ac455314-d6df-4367-9ef2-0898719051a7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0cd5d752-8f1d-4baf-99ed-87cc2dede4d6	2025-12-25 03:53:22.290557	\N
08f9019d-fb63-4751-8d20-d88de88c4f51	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3a7b88df-e6d1-4fe5-a4e7-43d68e77a0b0	2025-12-25 03:56:14.829501	\N
5c65265f-3175-4013-b400-38e4915a1a86	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a57eb964-83a1-41e5-9cdb-23b99645dcfa	2025-12-25 03:57:53.231022	\N
ae001e30-f17b-48f1-8c28-af2fedbfe5d1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8ec3c4bf-01f1-4de3-a0c6-9240ed401039	2025-12-25 04:04:41.162437	\N
3b0f3f9b-6c17-430b-9532-c47e21a3b9e5	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a8adf74a-ddea-46fd-9005-10c5bbc7374e	2025-12-25 04:09:33.942853	\N
1a417c81-f31b-49b0-8bb7-fcd5d5d5d44b	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6520e781-9fe0-481f-9571-b368baa266d7	2025-12-25 04:10:53.47888	\N
482ac49f-40b0-407c-81c7-7192e70e664e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2c28ed16-b7f8-497e-9bd8-0047c854dc31	2025-12-25 04:19:53.670803	\N
0fd312e9-ba94-425f-a47c-ab0914176ede	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	30b72ec0-db16-4a56-8199-0082d8d7c2cc	2025-12-25 04:21:43.285428	\N
387135f9-d580-4d69-bed0-de6d71832eed	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	27a3b63e-0703-4e8f-907e-072a7695197f	2025-12-25 04:23:38.661618	\N
ad70a09e-4984-4553-994c-0a605da194df	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a766e865-bf39-4953-a91b-2d0f9c838908	2025-12-25 04:25:42.481234	\N
e2f4fb52-d436-4ece-a890-042a5bef13ec	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b0b716b6-a9db-4a7b-99a3-eae6feef8cd8	2025-12-25 04:39:28.543165	\N
6de6a599-71ea-49e9-ab8d-a1bb79660eff	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	71aecf3c-3143-471a-a702-a8c336f25d77	2025-12-25 04:40:00.57821	\N
4d659d30-08b4-4455-bc70-fe9730bcaf4a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6c8e060f-7a91-4c88-a2b4-d6ac69b705f3	2025-12-25 04:43:48.994053	\N
c5741eff-e1d3-4c90-8584-410f0747f645	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6e6e8d8a-edd3-4689-baae-097ce13b386d	2025-12-25 04:46:28.650357	\N
3a7f073f-811e-45a4-8ae6-6502490d4799	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	ab7eb6a3-c039-4c6c-93c9-4ee0bc650520	2025-12-25 04:48:47.062875	\N
5ef966cb-dfc3-401d-8b34-e599ea466dd8	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	192ee554-f16d-4eab-ac83-068ec9b1d21e	2025-12-25 04:55:18.370508	\N
9cecead4-b497-42af-8eab-7c1062f6bf4e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d0abdb74-ca3c-443d-bfec-02bdb9f3926d	2025-12-25 05:05:09.194905	\N
04bb6b64-0fec-4faf-9ca6-80b454d67250	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b17dceaa-fea6-44e6-91fd-5dba8bb96080	2025-12-25 05:06:40.77859	\N
eada1002-2430-4e98-8f96-d2fb9895b3a2	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	74dcc0d9-c9f5-4470-8a32-a5c96ec7694f	2025-12-25 05:09:57.367368	\N
44f1b946-1d4a-41bb-8657-1c0a51402ba1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	33b7fee8-c2f0-4623-8871-f6452af438a3	2025-12-25 05:15:23.67128	\N
dc9cd597-670f-45bb-82ec-d37498149c5a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b20a2f1e-3fd3-4759-9cb3-27fc41aade9d	2025-12-25 05:20:38.301962	\N
fcf8563c-8d5f-48cf-b387-c66e337cd293	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8fe8f0b0-49a9-41b6-a84e-8f56c0849020	2025-12-25 05:22:57.41498	\N
5bd45e6f-869a-4f86-b786-73af25c1d488	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	233dbc6a-1297-4488-98d1-ff342d531608	2025-12-25 05:30:34.221291	\N
ca4a09c8-845f-4247-a5b6-471864dae366	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b2a38a8e-b840-4e0e-b8dc-4277b360ba98	2025-12-25 05:34:37.808157	\N
758459b6-ab46-4860-8782-5ce75213c2e2	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	12a97895-cf7e-4228-91e0-784c9dd7775c	2025-12-25 05:41:36.016427	\N
8c90f18f-b3c2-4f19-aba8-e890af121c0d	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	9b5b97f0-4f72-4427-83b0-838a49c32fde	2025-12-25 05:43:33.740348	\N
d9a6f9db-71e8-4c0e-af7f-3e71650d954c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8678bca6-7f78-46df-95dd-1bde0abf52f5	2025-12-25 05:47:08.27139	\N
39338ef7-eb7a-472d-93e9-419d1344c010	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f207685d-f441-4225-ad5a-43ddc4c7bfcc	2025-12-25 05:57:02.155798	\N
b9a68586-e989-48e9-853b-7e5729c1baaf	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	071acc14-8c87-4325-b3f2-d8d74202c67a	2025-12-25 06:00:17.012231	\N
eb35b17f-09b9-4047-850b-29a1d9fb31f1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	957f0da1-1980-4373-9ec5-6cd0cad07e07	2025-12-25 06:02:22.332106	\N
6af771e6-a84a-4857-a80a-17c1fc561b3c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	41d39f20-0ceb-40ff-b7e1-38466829f787	2025-12-25 06:02:27.049409	\N
b9d1c936-e392-4daa-b894-5e25d60d8282	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	213597b0-a36a-41fa-9261-593e1a2a4e1e	2025-12-25 06:03:00.636923	\N
b9e05dbd-9ba5-4af1-92e0-0a4148c488f3	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0504cba7-c0d4-4f78-8a00-82e127ca1461	2025-12-25 06:03:03.762396	\N
d2b72ce7-15eb-406e-8f7f-059c8ef4a1c8	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b845bd52-efa1-4d4b-8624-513b1089001d	2025-12-25 06:14:09.361527	\N
8f4df3dd-1b3c-4e5b-a791-12467517f52b	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a9a98908-f16c-4638-9429-96cc1a58c8fb	2025-12-25 06:14:14.248717	\N
52aab2cd-8452-4149-969d-aa425e41d080	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f538cdd3-762e-49a3-a0ef-c2c2bf68361d	2025-12-25 06:15:58.885044	\N
5657ef6c-550f-47c3-aea1-f0cad52ddcaf	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	824d5e9c-4f6d-47c7-9eb6-b0ca3d451300	2025-12-25 06:19:57.734385	\N
db2141ac-41c3-4c65-9d14-22f6eddce53e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	29b725fb-0ccf-40bd-95d3-00a97dc1f3a1	2025-12-25 06:31:43.776229	\N
41e6f01b-0823-4f9c-9e8b-768a8352c1ac	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	ef282529-0779-4c9d-923b-f11ce5a5cba7	2025-12-25 06:33:39.304546	\N
1c1dfc05-9b55-44fb-b6e7-54e0a7762dfa	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e3ae4c13-64a9-4a0d-93e2-acf28ad65dbf	2025-12-25 06:34:21.394034	\N
e62790ea-2038-44ae-ad24-a136eb564bb4	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	500d1096-cfab-49bc-99aa-2b84bd4ccb6e	2025-12-25 06:37:49.797851	\N
e3f2cae7-7ec7-4a39-9b5f-b5a1ea3782f6	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	953ceb2c-d5a6-4206-9eec-37924ad2491a	2025-12-25 06:42:07.157866	\N
95003de4-3edc-4e03-bb74-0c179604c3b8	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	21d2a8fc-27c1-4f7f-91dd-47d3fb8523d8	2025-12-25 06:46:22.014324	\N
cbcf2e6b-c844-4097-8828-6a9d24099610	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8820340b-05a4-44a6-865c-2c629023126f	2025-12-25 07:04:22.309295	\N
0dfd12ab-1ae2-4c74-ad6c-30ac49c93023	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"QkWSJyKav/nA2csaHC9Tvt0/Fc3YJoOgtEEF0cwskzMwOpj2iH28OdD7Y8iQx5XfiAbidRKL1n6HcGbKwArWiA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	861dae2b-78bd-41d7-b332-906101ff8558	2025-12-25 07:13:05.911073	\N
9626c2cf-5c52-4b2c-9039-58c49e234c2e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"QkWSJyKav/nA2csaHC9Tvt0/Fc3YJoOgtEEF0cwskzMwOpj2iH28OdD7Y8iQx5XfiAbidRKL1n6HcGbKwArWiA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	22565d5f-c07a-43ff-854a-74b7797b0ab8	2025-12-25 07:13:05.910993	\N
9f76525d-5999-4d1e-bd4f-678850d9f2cf	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2f2daea6-3c56-430b-b90e-00394413396d	2025-12-25 07:13:09.251853	\N
b3554eef-dc7b-437c-8375-31b0f2a9a03a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroTitle\\":\\"Título del Hero\\",\\"heroSubtitle\\":\\"Subtítulo del Hero\\",\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":\\"Título de la Sección de Tours\\",\\"toursSectionSubtitle\\":\\"Subtítulo de la Sección de Tours\\",\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":\\"Texto de la Marca del Footer\\",\\"footerDescription\\":\\"Descripción del Footer\\",\\"footerCopyright\\":\\"Copyright del Footer\\",\\"navBrandText\\":\\"Texto de la Marca en Nav\\",\\"navToursLink\\":\\"Link Nav: Tours\\",\\"navBookingsLink\\":\\"Link Nav: Reservas\\",\\"navLoginLink\\":\\"Link Nav: Login\\",\\"navLogoutButton\\":\\"Logout\\",\\"pageTitle\\":\\"Título de la Página (SEO)\\",\\"metaDescription\\":\\"Meta Description (SEO)\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6ba3d5ef-12ac-4abb-966d-81f00eaf87b8	2025-12-25 07:15:21.008572	\N
6a687033-d191-4cb8-9eea-7b7522911b28	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"QuWUF5wPEpdQmS06910QVD+IQ9EOZyjDTNc4/Jj/6V/d8Mk+6tYnF4cgijX4QnZsk5itEvXNvhu+DLadHInUVg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	acf68576-1306-499f-9e02-e6ea79fe14f9	2025-12-25 07:15:48.113941	\N
58d05b18-eb6a-4b61-9eee-0dfe4c43df50	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"QuWUF5wPEpdQmS06910QVD+IQ9EOZyjDTNc4/Jj/6V/d8Mk+6tYnF4cgijX4QnZsk5itEvXNvhu+DLadHInUVg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8e0c2d51-ee5e-4deb-b042-859586ec35dc	2025-12-25 07:15:48.223945	\N
01d1947f-11a9-49ec-9e25-aae2b417eea1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	acd70cb6-1c02-4b70-ba60-0970b675fd6a	2025-12-25 07:15:53.720102	\N
10cfbb86-8f39-423b-b6a2-dabc484c6e70	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"VALeAuJQJl3/OAx02NeAPRTy6hljE3fCidX33NFtX1OTE/8IEKazJXEklWr8jWvaIuBfM/glQzwKuPbapD48GA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b1398997-8b00-4503-bfa0-91c0fdd9d437	2025-12-25 07:19:46.332757	\N
3a77d5e2-e1fe-43c6-b115-54fb2340ae56	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2cf1efbf-0bd7-4a6b-8adb-3531271c229a	2025-12-25 07:37:49.921979	\N
8f2d62dd-e1db-44fa-b8dd-a1b14e1b00e1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	9ea86c90-028b-42fa-b236-6f1320751fa2	2025-12-25 09:07:45.91269	\N
26f7d01d-de5a-44a3-bd59-fa0b39470efb	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f245d906-26da-40ec-87e1-b8df7128c967	2025-12-25 09:24:31.572678	\N
b2377e9e-f082-4738-8c69-2ee56469e2d4	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	34ea2b89-6e5b-420d-a0a9-1466d1ab67b8	2025-12-25 15:40:04.926324	\N
83717365-9d8a-433e-81f5-cf037d50fce8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	57ff4e7b-1807-40a5-9429-04d58e3cbaa2	2025-12-25 15:41:04.200977	\N
cd32afe2-ca8c-4685-a361-fc715585216f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d89e199a-4b64-4fc1-995c-b5d26d5e9841	2025-12-25 15:41:16.221123	\N
a91428c4-6586-4955-9720-9a817e61a82d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	11239de2-e8cc-4f2b-ac37-bbecfd3c1624	2025-12-25 15:41:33.212196	\N
95ce6a85-89ac-42fa-ba27-954e37e0b24e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4826efb0-f242-4be1-a306-43a35ac9c526	2025-12-25 15:41:33.239596	\N
32f11f5a-27a8-4888-ad4a-a32d8948bda0	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	fd4eb879-66a7-43f2-b901-a594e9e0a3ce	2025-12-25 15:56:25.327574	\N
ff192a1c-1b77-4680-8b7c-40b9cde49007	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	268bcd34-8cd8-45ac-914f-051ef2d9ce97	2025-12-25 15:56:49.657585	\N
8a8a0865-572b-4f38-9e72-3e4255020fe8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	20843af6-a86c-4436-905e-7cf97f178c7a	2025-12-25 15:57:02.432502	\N
8da4e6e7-b46e-4f62-95d3-9b7b64677503	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	5c9fba4d-e9f7-41b0-a606-2b490ebfeaf2	2025-12-25 15:57:12.884351	\N
502451c8-16da-48d3-94b5-aa8dcf47ae15	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"a5U+u402+5tkUkZGjCiJ7+9t/NkF7YkK7UmAmKT8T/hNDga7fPCzH6TOBtnl/krMwgOIN54CTBwicwPByK4aNg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e7e74e34-bb9d-4d66-850a-e2b53aadc37b	2025-12-25 16:02:15.043711	\N
1df708d6-f882-434f-88df-11b0b4d9c7cf	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b5634c7d-0a81-4c51-888d-9b70d6329ec8	2025-12-25 16:02:20.934341	\N
f2e81903-473c-4833-ad3c-8b292372273a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"RYrwALeFkJcaRoY9i9VDr4cMfi0NgzU7fDcaM9GtyhXmsLv8s2FvY6sPNqzX3fYUjx/FihucU7mtRbZUwwkCaA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d3e36cf0-da7e-4f9b-b71d-516f6d22a47f	2025-12-25 16:06:57.276636	\N
5bd1dda2-6b72-41e6-a308-bf98fecb9476	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b33dc8d8-8787-424a-bb9b-322f0c95b6e3	2025-12-25 16:07:03.263823	\N
ecac3a26-4ea7-4050-924d-253cb58765d6	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	85e1b68a-5c26-494a-90e5-2f2b3aceaf4a	2025-12-25 16:07:29.679651	\N
b62df57a-9cc9-4f8b-af87-7e46ad05033e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b49551a2-dce9-414e-b61b-b4a1030d228f	2025-12-25 16:07:29.689083	\N
09842d58-37e9-46ac-a8d9-6bfeef70383d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	22e50ff2-3850-4645-8b50-6a4b6552746d	2025-12-25 16:07:29.747899	\N
7b3c6f58-9dac-4ecd-9ca3-23229294fc87	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	103b9530-d9d4-4c5a-8462-f30adffb9b0b	2025-12-25 16:07:29.871819	\N
cc639672-53c9-4305-a9ca-f7b2f4d3667d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4ec46c48-bb1b-4bfb-99bc-61ccfb0b680d	2025-12-25 16:07:29.917884	\N
20cdbbaa-4909-4571-90e0-85cf09c37ef6	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"c2NoKAkutZQV6vhwUptWAkQoArppNGWry1RYrpiVPJ9lKYhj9XJh9udCvs7udray4aRUXcnOI4ACcAp0jK9MXA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1f11c5de-ea45-4e78-841d-8784a1693c0b	2025-12-25 16:08:24.954611	\N
036ddffd-64ca-4cbb-9998-0789eed0d6ea	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	329fea59-55f1-41d2-aa7f-29f77c618ce7	2025-12-25 16:11:44.084701	\N
cf4ed199-8df2-4471-b91f-cc9c90c1c842	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a5719979-7470-4da7-96ba-098927fac099	2025-12-25 16:12:51.338851	\N
2f39a042-c975-4a2b-a820-1c3f7f92ec43	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b376f286-728c-4a25-b7f2-2ce211874357	2025-12-25 16:13:04.34818	\N
b466e448-cda4-4632-965a-12084a2daf59	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"uv5AJ+pnEK7iKoHpHKtVWAsebHoozCsziFYS2WxuKSol5senn970ytF6HcKeyjKynAhG76IojJGMk7FTMbrCpw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a0439dd8-70c3-4736-a91f-1678732ef1fd	2025-12-25 16:59:47.932466	\N
ecd608a3-312d-4ac8-9854-2c575c80d6bf	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":\\"undefined\\",\\"faviconUrl\\":\\"undefined\\",\\"logoUrlSocial\\":null,\\"heroTitle\\":\\"Título del Hero\\",\\"heroSubtitle\\":\\"ddddd\\",\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":null,\\"footerDescription\\":null,\\"footerCopyright\\":null,\\"navBrandText\\":null,\\"navToursLink\\":null,\\"navBookingsLink\\":null,\\"navLoginLink\\":null,\\"navLogoutButton\\":null,\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	c44a2ca1-b768-4ba9-a76b-ea5016d6aad9	2025-12-25 16:13:16.070035	\N
839a5c5c-1351-4aaf-9113-9e92f4ce6020	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"qPeNerdPgQ/gSM4+EEOuws76Nblx4hlfoU10gDk5RfYOxayofiFp5LecQX/xcd7gSFiUXmJUd5UwQ9SGvm2jWA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2195eadb-7249-4365-8a0c-e059cedcf6c3	2025-12-25 16:24:49.018835	\N
3c82b318-1095-4fbc-975e-91875fd150d0	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"qPeNerdPgQ/gSM4+EEOuws76Nblx4hlfoU10gDk5RfYOxayofiFp5LecQX/xcd7gSFiUXmJUd5UwQ9SGvm2jWA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	eda7d47b-9fae-4ca2-9b57-abac10b52327	2025-12-25 16:24:49.036335	\N
a8f3f739-7986-4e9b-8f79-a0d53da9e616	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f024b63c-8cfd-4bef-b40a-c54aea8a102b	2025-12-25 16:24:57.28934	\N
882c504a-e1d8-46b7-ab55-e54c697f6bec	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"cQoKptj3tCbUV2JVsrl1qZWiLF3AFO+RXhphq9l00cl/3S/pE9+JHe9sluGAZAQg4qR5/nsSYxX/WIHaZE2KJA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b029013d-a47b-45c6-b2e5-df3263fea485	2025-12-25 16:36:55.227705	\N
3dfbfdc6-d6c3-4ed8-b765-4acf254197b9	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"cQoKptj3tCbUV2JVsrl1qZWiLF3AFO+RXhphq9l00cl/3S/pE9+JHe9sluGAZAQg4qR5/nsSYxX/WIHaZE2KJA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4feee037-22e9-4c77-b8a5-f6d0c0360ea8	2025-12-25 16:36:55.227705	\N
0df635c5-ec8f-464d-9512-65e4994535da	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b9f353c2-7e61-4a85-84ae-ca4acfe3d4f8	2025-12-25 16:36:59.077052	\N
5431acd5-e41a-446d-8c0e-ed440c218312	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"yijU23lcP5367pXKROlJcsCLHEpORaoiHK9CFD/7gZQg4QcxZJAdBF/R8lh7tx/qnkaJlROCYB7peDAPLKeT9Q==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4088a095-4a04-4643-8d9c-44a062d08cb0	2025-12-25 16:39:47.961413	\N
6913bae8-f0f3-4ef4-b58b-9ee51bd29778	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"yijU23lcP5367pXKROlJcsCLHEpORaoiHK9CFD/7gZQg4QcxZJAdBF/R8lh7tx/qnkaJlROCYB7peDAPLKeT9Q==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4308688b-65bf-4607-ac50-867fcaceac0c	2025-12-25 16:39:47.981098	\N
1a580656-5812-4991-9bdc-9ac04c17b5ec	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d4b1440c-4e8c-4631-8e56-aa3879f8b3ba	2025-12-25 16:39:51.66046	\N
303756d6-0f27-4802-8b6e-1c3d6d658ec7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"r4Nyd3Ju87nUJXIeuW1UNdeW8cNXYLADORM8HriF/LoQbFCC0B7IjQ3/O3h4MPuo2P0ihLL9S3yM7YY6Tv/0KA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	cd13222f-b0aa-4624-a03c-6c1a5f73ac20	2025-12-25 16:41:38.468489	\N
5b4e1680-9743-4ebc-a689-013ad155be15	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3689ca31-21d9-4fb0-b584-5696e4da71ad	2025-12-25 16:42:57.745168	\N
74664556-33e3-431a-b77f-2789e56f4a19	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"+uaWS+DIK7gpZWOA7IMEmfkTe3Bq8LJu7FNKY/pIvrFYctGZbYhYExO+YwxPH8/5TPxvxRvIWw7T11QSgY9C4g==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	52ed1708-c923-4837-b077-31ff3ad95a3d	2025-12-25 16:46:44.989876	\N
7d58c0af-72b2-4246-b836-5a2142ca22fd	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"+uaWS+DIK7gpZWOA7IMEmfkTe3Bq8LJu7FNKY/pIvrFYctGZbYhYExO+YwxPH8/5TPxvxRvIWw7T11QSgY9C4g==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	68a4a44d-a7c0-49ff-bec6-fbc43d04c9ac	2025-12-25 16:46:45.042424	\N
0ef2ce3c-3ca5-4dd3-97ad-a17f18297e55	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	163e6e00-741d-422f-b2e2-b384b81aebeb	2025-12-25 16:46:47.581472	\N
027c5bd1-6731-4b81-a382-7d204140c38f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"u0iHgpb5cDVAO6gjHm3s1EZOxszBqLm59Viimm2Pc+DKblblBwdTP/fFc2TkxgRCGA2EFc0+mwXLozo1OpdmAA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a03e0692-8c55-4f14-a8e2-6d40bbbba7eb	2025-12-25 16:49:30.54907	\N
48338b91-c2c3-4f13-9261-38e19ab452b2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"u0iHgpb5cDVAO6gjHm3s1EZOxszBqLm59Viimm2Pc+DKblblBwdTP/fFc2TkxgRCGA2EFc0+mwXLozo1OpdmAA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f5346196-9d69-4320-97ab-2155c3a9cc8e	2025-12-25 16:49:30.54907	\N
13cfa2b0-5aaa-4c80-88f3-8bbaa8870179	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	28e78ece-8fb6-47b4-b6b7-20081c5c70bc	2025-12-25 16:49:36.769959	\N
78baaec4-8bdf-4144-87cb-3eeb9bff1fec	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"iLqAWRUScqJkXymr79O/OUEIWjkq40TqIUBWEEQJ9AljstsvRNlgZxFZX7m1hknGXdRiNyUFcM2KjursCCTd+w==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	394bc063-4cae-44e8-9ac7-3f2a7200bcab	2025-12-25 16:53:30.262633	\N
a2f56e3c-f5b8-4044-9eee-0e8829d37c2e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	126d3081-9b5c-46ff-b836-f38f7b5e7f3f	2025-12-25 16:53:33.151228	\N
95aaf597-1065-4556-93af-3a3ebcc3ff5c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"uv5AJ+pnEK7iKoHpHKtVWAsebHoozCsziFYS2WxuKSol5senn970ytF6HcKeyjKynAhG76IojJGMk7FTMbrCpw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	eae18443-8178-4eb5-8bba-7737f461ecbf	2025-12-25 16:59:47.932465	\N
6ce6e45d-21e0-4c9f-8776-9923f90e762d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	10ed7313-8317-4303-ba6a-6ff5224d6ab1	2025-12-25 17:49:58.487095	\N
144bb794-a9fa-449f-bb51-c4694539dc07	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d647f703-9bbf-40d3-a197-681d35530d75	2025-12-25 16:59:57.761959	\N
48d319c9-9ac3-49e2-816d-ffc013d1b023	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"aUFvd4QQyp7u+iTPwMiVLbTqaXno6np5LSH5/SliIcoJtned8IP+P5Zta98MnA6rO8MgXBqP7FWirVgxUJGiog==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f533ae03-0dab-49bf-86e4-f29aefc7a28a	2025-12-25 17:05:33.070889	\N
ab6589b8-2c03-4bdc-a2a8-65456501fe4e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"aUFvd4QQyp7u+iTPwMiVLbTqaXno6np5LSH5/SliIcoJtned8IP+P5Zta98MnA6rO8MgXBqP7FWirVgxUJGiog==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	5b0ae5e2-85f9-4f1d-8622-0262f4585565	2025-12-25 17:05:33.070895	\N
64d65bb0-b818-4a95-989c-cdb46754c77f	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	22c7470c-77af-4e77-962c-5d53cdc47484	2025-12-25 17:06:03.462068	\N
e503a5f6-14de-4886-ac01-e222b3d8a749	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"SSPvEuLqkoLNIrnoYflyIRVHdrJrH0xZhMfnxJDZhV5KLdQGh6f/gWvTXaoVlgQJc4VF7U76dQ+mLN3ZUklQpQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a2c25503-fc08-4801-b298-05a08caf7f19	2025-12-25 17:09:18.061448	\N
8cea3987-9173-44cc-967e-ff0d1e7e8e3b	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	eddbec5b-2ac1-4ad9-95b9-65d93330b038	2025-12-25 17:09:24.312269	\N
5717e5ee-1de4-4999-83f7-762967a50561	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"SX5VD136odk1QcHmkpSfMg0Z4HA8ZfwOf86hBoYLmxUE0PFcEQ/Dd6nioNM5BMZGNFFNpKE2GZOaovgLtyXUFQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	53cbccf2-44c0-46ce-b0f4-851f445af683	2025-12-25 17:09:45.970501	\N
f0e78690-8efd-42bb-a1e6-0048f68edfa6	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"SX5VD136odk1QcHmkpSfMg0Z4HA8ZfwOf86hBoYLmxUE0PFcEQ/Dd6nioNM5BMZGNFFNpKE2GZOaovgLtyXUFQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0661eec2-1759-4996-8caf-88d65434deec	2025-12-25 17:09:46.023351	\N
dec0d692-2797-4524-96d1-076231499f90	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d6f4cf63-640b-4d16-a366-2236eb40bdb2	2025-12-25 17:09:48.916179	\N
24f94fa8-f0fc-4b69-b706-acb9a59c3768	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	05728988-0fa4-4d8b-a33a-4f6ad9fd3d40	2025-12-25 17:10:40.72477	\N
a2733ee5-2fc4-4b3c-b1fc-6d3833b20c5c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f7ed46b2-2a4c-4ca5-94e7-562acee1d202	2025-12-25 17:10:40.769231	\N
928ab54a-6b43-4a78-a7bf-eed8752fe558	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8a8b1794-bdd7-49dc-99e1-b438277372e1	2025-12-25 17:10:40.812744	\N
cbcf8aaf-9a80-4207-86b1-cd329b2fdc0f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1b2b1749-932c-4476-8802-795e621cb36a	2025-12-25 17:10:40.860249	\N
c10e5f71-8762-4f16-9ce4-434cff424ebf	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	02c243c1-6d86-4b36-b9d4-c32e4ee33483	2025-12-25 17:10:41.079023	\N
40615692-efbc-40cd-a1af-ca6193c50352	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"OK3b2jTARaSo7lugaxA3t4QZEBwsrzR5ZGzSM+TRcqipP00Ca/EP4qY/ktFRhNZP3pSYuY+WWfyPARdRE6m2ag==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	25a4c1b7-3b3e-4aae-a63f-640de0e04efd	2025-12-25 17:17:18.666515	\N
548352ec-44f8-4b5c-bd6e-952c295bf256	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"OK3b2jTARaSo7lugaxA3t4QZEBwsrzR5ZGzSM+TRcqipP00Ca/EP4qY/ktFRhNZP3pSYuY+WWfyPARdRE6m2ag==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d11b4100-d856-4a96-a320-75a8987b6f51	2025-12-25 17:17:18.666515	\N
743bd54f-b8a6-4ab1-b1df-78d1b0abeace	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	54a5bb1b-d84b-4f9e-a685-958f8f776c9e	2025-12-25 17:17:21.87081	\N
186cc910-7c8e-4a85-85de-6b2dd8740222	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f791d047-7ff6-4a90-afeb-26194653c50a	2025-12-25 17:17:51.084228	\N
ad7d2acd-8602-4e88-b49a-1f0886d160be	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	78f93bea-990d-4a63-8d58-b12fbf76841f	2025-12-25 17:17:51.152809	\N
54076212-bb0b-43bb-b59e-4c9df47d4ac2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	becf8666-b8fc-4b2e-b5b9-0f48e7419ccb	2025-12-25 17:17:51.168714	\N
1d054fb4-5f76-46bb-aea4-165d0906d981	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	09713847-671e-4f26-b6e2-7597e49785ba	2025-12-25 17:17:51.228438	\N
4d8c9edc-454f-4fa9-8118-64af24f4ce6f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	654708c9-7a4d-443d-be67-4a80980712af	2025-12-25 17:17:51.252987	\N
0fdc4345-bade-4efd-9383-318fa3babc51	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Cebacossssssssssssssssssssssssssssssssssssssssssss\\",\\"itinerary\\":\\"10 pm\\",\\"price\\":1000,\\"maxCapacity\\":100,\\"durationHours\\":48,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/0ea7d517-d587-4e1f-865b-55c04dd204b8.png\\",\\"https://localhost:7009/uploads/tours/bcf906db-381c-40a9-b3a8-c6abf7aa8cb8.png\\",\\"https://localhost:7009/uploads/tours/4063f549-0b60-48be-8933-1d5e2801a7d9.png\\",\\"https://localhost:7009/uploads/tours/01c01705-7c19-4822-85ae-6aa48488529b.jpeg\\",\\"https://localhost:7009/uploads/tours/1e151d0a-1303-4699-b2bc-a257ad576650.jpeg\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	599d8b19-48fc-4fe1-9add-7e42d46a701c	2025-12-25 17:18:33.023109	\N
1d50aeec-1d27-4107-85c7-e40763a5140a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"JYmGED0Vd9nsApEiLHDa/bNwb6uWtPH0SMpyHZplTeSRFbYfnOqeFK99MtjZ9dxd+EYS9JAcpfAdR5Mviuk2kw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	564dd99c-3336-4f10-b452-c0bf8f8b12be	2025-12-25 17:23:52.721301	\N
a3717bbb-6cec-4090-8513-7a9f82275ad2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2f229160-0ece-4b02-8360-5cdcd0a1e0db	2025-12-25 17:49:58.669155	\N
94b7ca37-1c53-4b66-90f3-1a158821eb27	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"JYmGED0Vd9nsApEiLHDa/bNwb6uWtPH0SMpyHZplTeSRFbYfnOqeFK99MtjZ9dxd+EYS9JAcpfAdR5Mviuk2kw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	ab0ff532-37fa-42e0-9d6f-3a7a095f810f	2025-12-25 17:23:52.728939	\N
cc5d4831-8ae1-49e5-9463-1c190c96b019	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	95079652-e734-4d61-9607-df8bd90030d2	2025-12-25 17:24:07.842901	\N
352e32ba-37a3-49c4-a212-8fdbac860d92	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"DRaHwE6fGMGuyIHi3sZvJo6JcW5SkFE2gQc7eTN5Ztmtuw0tZCjJXvYwdx6t9X60vdZ/yszP45V+7ecKbg8k2Q==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	02d3f2fe-50ac-44ce-a6f6-9f39e9fe8b34	2025-12-25 17:26:42.053148	\N
414fec14-cd73-4c02-9ddc-53979ba8e9bf	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"DRaHwE6fGMGuyIHi3sZvJo6JcW5SkFE2gQc7eTN5Ztmtuw0tZCjJXvYwdx6t9X60vdZ/yszP45V+7ecKbg8k2Q==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3d01236b-f270-483a-85dc-9b6f7c89c4dc	2025-12-25 17:26:42.053138	\N
1c1e89fd-433a-48ec-a4eb-cf5e00cbcde7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	780f9265-6a0d-401b-8dad-dba0a7aacd86	2025-12-25 17:26:44.899481	\N
dfeee0c8-1f78-4ab2-a534-fdecd880b071	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"0kamo/iEPNzgzuKvnXRDtC8wwBpwGWtUobdFvJSLbtgI8siAU6o3Qk7osfMTD5vX7M549gytyHizQ/PkMFsvSg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0ea285a2-00ea-4509-81d3-52fdf12ccdaa	2025-12-25 17:28:49.132825	\N
0e56d86a-baf7-42e6-bee0-1ec5794b61c3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"0kamo/iEPNzgzuKvnXRDtC8wwBpwGWtUobdFvJSLbtgI8siAU6o3Qk7osfMTD5vX7M549gytyHizQ/PkMFsvSg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	253e2b18-ce74-44f5-b9d4-1a80ad66f4c5	2025-12-25 17:28:49.295348	\N
f7170091-e232-4ab6-a3a4-ccae0020ce69	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4625a6e8-bd4f-4056-b71a-9fda77145794	2025-12-25 17:28:52.40172	\N
131ad56f-66c5-479e-99e9-c7c168d3f950	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"WiijtW3ZQYfxro7ighy4feHtjQ3AHnPH0nKYjJ+SIRfFmvwBcrTuWMlnEDCZH1lY2Nm1ON/D7T4Gi1YNDFnORw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3fda679e-f88d-4626-80be-4942b485c73e	2025-12-25 17:29:49.303381	\N
7683d4b9-560c-431b-947b-a2bf168221ef	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	af129bf8-507a-4459-ac16-4b8fae307bb1	2025-12-25 17:33:15.33942	\N
af98be5a-e899-416e-9830-4e803a4642c3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	467b821f-2303-4984-9ee7-b724f11eeccc	DELETE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	31c9c4a3-4b01-4c91-af55-98e148df7190	2025-12-25 17:33:18.739899	\N
ef41f32f-549b-4816-8709-12b373721d4b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	467b821f-2303-4984-9ee7-b724f11eeccc	DELETE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	920ed121-9fa8-4c39-9e54-7d89c60d77fa	2025-12-25 17:33:31.164743	\N
83218058-9491-415b-8d95-17db15b3f00c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"0Kzbvgkmrp0dsQafB8BGyc8wmZeOHb+YEIzhNWXHak4Tzjop0i54lJVohGwhI7C1XP1UxqfDOIQTlx1/M6sf9g==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	26e48198-7e03-4929-909a-c38952b9487b	2025-12-25 17:37:32.370038	\N
cb7a11a4-75bb-49cb-be9a-f1a3d2283fb4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"0Kzbvgkmrp0dsQafB8BGyc8wmZeOHb+YEIzhNWXHak4Tzjop0i54lJVohGwhI7C1XP1UxqfDOIQTlx1/M6sf9g==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2f61ef7f-f01e-4577-afe9-38eea0dddda5	2025-12-25 17:37:32.391401	\N
8e4018a6-91fa-467d-a8fb-2fe1ba8c815f	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	cb0553af-cf66-4338-9790-4a30ffd57c2e	2025-12-25 17:37:39.39267	\N
35204a86-e486-48dd-a113-210f81488008	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	100c9d65-0e2d-4089-b5ad-7ba09fd957c9	2025-12-25 17:38:12.442248	\N
a57fca36-11e5-44d5-be5e-ce09d56b2855	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	c2540da8-71da-45dd-9ba4-4e345451977b	2025-12-25 17:38:12.491164	\N
3555923f-01af-432c-b9ae-e4775ad4a157	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e41ecd89-ff66-4b5c-8fdf-59c361df0210	2025-12-25 17:38:12.535405	\N
f8d4e148-9e67-4886-953b-84c4ced9b676	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b35dd1cd-f960-458f-8293-5af7eabf5506	2025-12-25 17:38:12.57042	\N
c57b9ea1-4825-4a87-92fd-5caec2ee31b7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0b3b9745-65e1-4786-936d-8480ec9852dc	2025-12-25 17:38:12.584648	\N
521fd0a5-c52e-4721-9330-bfff0a3f75e8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tour\\\\nDescripción del Tour\\\\nDescripción del Tour\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/79ec717d-86f8-4607-9d15-b14fb3e7845f.png\\",\\"https://localhost:7009/uploads/tours/01a74ce4-d1a8-43f1-afc9-5ea416de6b2c.png\\",\\"https://localhost:7009/uploads/tours/2001d789-3c71-44a2-a674-558a70b5ce94.png\\",\\"https://localhost:7009/uploads/tours/2438f038-a3d7-4c8d-8b27-6f7edef814a7.jpeg\\",\\"https://localhost:7009/uploads/tours/47fce5a0-1aec-46a6-a276-649debc5f802.jpeg\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	dae13ae4-0244-43ff-94d2-98534ebf928a	2025-12-25 17:38:42.841731	\N
8d26d878-22ce-46ac-aef7-ec35200fa0c6	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"FThxZ2UJqZEjPYhhRl4E3nwNgyU+37cithqIUaFhBrdYD83sWLHVU19dFS7rvlj3z8xUeFvt+Vp4/n/QXm4rWg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	7795f6fb-0274-4d36-ae70-f396c826d1fe	2025-12-25 17:49:41.801449	\N
131eb523-683a-42a9-9c6d-918ec9a496c3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"FThxZ2UJqZEjPYhhRl4E3nwNgyU+37cithqIUaFhBrdYD83sWLHVU19dFS7rvlj3z8xUeFvt+Vp4/n/QXm4rWg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	73673617-48ea-4fb0-83fb-de7c08fccc1f	2025-12-25 17:49:41.815965	\N
7ae53a54-486e-4982-8c88-9555e23d7358	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e655e091-011c-4c42-9d13-f3e4450292f8	2025-12-25 17:49:45.902635	\N
3f94881d-c720-4ee0-8606-916e59632f5b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	510d2b63-2860-46a6-8106-379e26c7e67c	2025-12-25 17:49:58.477895	\N
c1491959-2c32-4947-9cc0-89643c6bfc42	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	aec89c08-f916-40d2-9501-c4f48cd71526	2025-12-25 17:49:58.500349	\N
02e8ed7f-c7c6-436d-9e17-8249165f182c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e9f50ada-a4bf-499e-a46e-b2ed19aeee3c	2025-12-25 17:49:58.645226	\N
28565b0d-45a1-4c47-9850-15d913a57be8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Dqas8nA9k0TVRAK2h+W3GLtvtyyIAoEE6lS1nU25a4hqLEMsxwf/HoTxY3fYzRfKM63ya5hU6A/OszOFwxjjRA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	95e319ba-0adc-4775-8f79-c29343680964	2025-12-25 17:54:35.116223	\N
c792cfa3-6319-4b6c-8e2a-d723376eacb1	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Dqas8nA9k0TVRAK2h+W3GLtvtyyIAoEE6lS1nU25a4hqLEMsxwf/HoTxY3fYzRfKM63ya5hU6A/OszOFwxjjRA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	060ee963-eeb0-441c-821b-e851f2dcef70	2025-12-25 17:54:35.116228	\N
0642c63d-28c8-455f-94a4-d05b1bb0fbef	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	de8ae4a6-42d2-4ec4-a5b5-ad3186d34cd9	2025-12-25 17:54:38.786091	\N
0cb0fcd3-52e7-4e60-8ab6-30bf0587ae27	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	da86f6b9-97fb-4cea-8f74-446616b8229d	2025-12-25 17:54:56.404867	\N
5862a933-c397-477d-bcb2-1cda7d99b896	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	9755b636-29a2-4440-927a-bb8510ba9f70	2025-12-25 17:54:56.412852	\N
c40ae3eb-1ea8-45d3-8767-5255a07c02b7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	7ebe6784-a3c7-4724-93dd-66416ab8152b	2025-12-25 17:54:56.4298	\N
0773fc8f-1961-4a74-98e2-132f7ed948dc	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tour\\\\nDescripción del Tour\\\\nDescripción del Tour\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/bd893b13-d08d-4c73-b7f0-0f12031d762f.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d22369f3-661a-4fe1-b915-320d68eb052b	2025-12-25 17:55:15.477546	\N
e8379806-cf0c-422e-8f82-703bf5923957	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Sc7bs7sGB87jBbtT4Y9N/alwPY3qUMewq8dzlryvt5+K9CgiWWAFdTPuG0uRiM1a+mxATBS7/B0p8cfQ4HyHfA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1efef028-f635-4800-8860-3c38da5f3238	2025-12-25 17:55:30.198414	\N
0bf362a6-35fe-4231-9ac9-ccc0a772437d	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d7908e36-505b-4ac6-b399-60ab00909762	2025-12-25 17:56:06.246493	\N
180fbe2f-8389-4c36-b12d-beb3ebfce100	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tourssss\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/bd893b13-d08d-4c73-b7f0-0f12031d762f.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b6b097f0-77a5-4f0c-9439-784a0350069e	2025-12-25 17:56:27.503352	\N
706fff5f-8f79-4e4e-971f-7c33cf01474c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	15471fb8-2ab6-4f2d-b6b5-488562858e80	2025-12-25 17:56:42.9731	\N
3db81e85-526c-4b28-b71f-c87ef2d25957	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tourssss\\\\nDescripción del Tourssss\\\\nvvvvvvvvv\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/bd893b13-d08d-4c73-b7f0-0f12031d762f.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	61373d3c-bf90-4b55-8d64-06d917c466dc	2025-12-25 17:56:59.810233	\N
eb444f34-9827-407e-9562-dd519141a477	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Y+flu6KsH88WVCIMUT/s3iY89kaoTXcLFeIu76n9Cuz+38za+WJvhfJ8gRgbUzGM5/wXRh86NtptZo4peV2/Sg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	9b328665-41aa-42c2-a310-c048a5e26f85	2025-12-25 17:57:02.475029	\N
1eabb3de-ec74-48d4-a110-9325592581dd	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	637e20e1-d76e-446c-aaea-c7e85f70ecd0	2025-12-25 17:57:25.824132	\N
f57ea043-cfe9-44d6-8e06-a686a0e018a2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	7bfbe7e0-fe49-4c24-9ff2-95ab520a8582	2025-12-25 18:08:11.395825	\N
71b63a47-17a0-4fb4-9bc7-c7037cf9654f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tourssss\\\\nDescripción del Tourssss\\\\nvvvvvvvvv\\\\nsssssss\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/bd893b13-d08d-4c73-b7f0-0f12031d762f.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	5ec73465-c2e3-4a7a-bbb2-be5e2fe9228d	2025-12-25 18:08:26.751051	\N
50d41884-3f13-4a6d-a874-c0849225b0e4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	77e1e030-cf3a-4500-8c37-2ee0d9702004	2025-12-25 18:15:02.178788	\N
9d353010-4a69-4e96-97e9-501b9ce4000e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tourssss\\\\nDescripción del Tourssss\\\\nvvvvvvvvv\\\\nsssssss\\",\\"includes\\":\\"wswwswss\\\\nwswsws\\\\nwswsws\\\\nwswswsws\\\\nwswsws\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0f5f31a8-1a20-44ee-b8e4-6b123ab68413	2025-12-25 18:15:22.75477	\N
06fd8e08-f40f-4f4a-8a03-f6e89cc83f9d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"woxGg9HKQnPMw2vJc5b2oLOzh/qsnAJCOYpszDSFg4YNcCd9tkFU/sFfs5s14zUCXVGJ0lqG4uGHitcUwflISg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a4094c46-9cca-4a8f-a6d6-ba0588a7ad39	2025-12-25 18:15:53.384302	\N
b9002898-5c22-4ca6-a8d5-1d3db1cd710c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"woxGg9HKQnPMw2vJc5b2oLOzh/qsnAJCOYpszDSFg4YNcCd9tkFU/sFfs5s14zUCXVGJ0lqG4uGHitcUwflISg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	48e3640e-f288-4ecd-bbf7-d6627a3f4535	2025-12-25 18:15:53.428019	\N
7bbd5b51-35ed-4a8e-83c7-3872d7cbfe27	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	50b7fe14-76ca-4b45-b3fe-600285e280f7	2025-12-25 18:15:55.630523	\N
a33e0be3-bde6-4733-b02c-9b7d6bd9d5f4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6dd5ea53-7263-4ab6-89d0-5b9d0e29ae0f	2025-12-25 18:16:13.390411	\N
4877ee02-539e-4a89-8e78-b6024c966b04	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	73520103-9a51-48f2-9097-e10ed96edf8a	2025-12-25 18:16:32.341798	\N
b949eeb0-48f9-400a-ad3c-417aca8f64ab	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	71af5ab8-f273-488d-bbf9-804ea38075a1	2025-12-25 18:24:25.541471	\N
6b2d6cd0-5c79-4190-9c6a-725d461b00d5	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b4c5a8a3-d6e5-4097-b0e5-dadc335b40ae	2025-12-25 18:24:43.51353	\N
a5ba09a1-5382-4e82-8c54-71f6ab2c47ec	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":\\"/uploads/media/663184e9-1d96-4a30-bb56-ffa09284dcd5.jpeg\\",\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":\\"AloticoPTY\\",\\"heroSearchPlaceholder\\":\\"Búsqueda\\",\\"heroSearchButton\\":\\"Búsqueda\\",\\"toursSectionTitle\\":\\"Nuestros Tours\\",\\"toursSectionSubtitle\\":\\"Descubre nuestras ofertas\\",\\"loadingToursText\\":\\"Cargando Tours\\",\\"errorLoadingToursText\\":\\"Error Cargando Tours\\",\\"noToursFoundText\\":\\"No Hay Tours\\",\\"footerBrandText\\":\\"AloticoPty\\",\\"footerDescription\\":null,\\"footerCopyright\\":\\"@2026 AloticoPTY.com\\",\\"navBrandText\\":\\"Tours\\",\\"navToursLink\\":\\"Tours\\",\\"navBookingsLink\\":\\"Mis reservas\\",\\"navLoginLink\\":\\"Iniciar sesión\\",\\"navLogoutButton\\":\\"Cerrar sesión\\",\\"pageTitle\\":\\"Descubre los mejores tours\\",\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f87e6031-5771-4e34-9ce0-cacf4f63f45d	2025-12-25 18:28:41.153243	\N
54c6cad1-f1af-4570-82f2-d6cf2e13703e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"DJDzB8oYHrsNmc5PxnV/t+LLh2pffWItryIE/3tjJskin4XfuSeXrZxba/u1rgHAk25xZzPINoQ0f9xnWYPGKA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6d6b93e9-d2bf-452f-860a-9056eb0c92f5	2025-12-25 18:28:58.906846	\N
42e9638a-5c21-4f52-92fd-0669a51ed41c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"DJDzB8oYHrsNmc5PxnV/t+LLh2pffWItryIE/3tjJskin4XfuSeXrZxba/u1rgHAk25xZzPINoQ0f9xnWYPGKA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4ce8235d-1158-4c8e-9a8f-79bad75cdd24	2025-12-25 18:28:58.93354	\N
d9cd9787-63cb-40ff-bb5d-1a0b1b978f1d	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e0ea2cf8-91c7-4951-887e-c3cfcb076af9	2025-12-25 18:29:02.338965	\N
befa04d6-e215-4a93-a9d6-dd7e89d44ae3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"B/PC4URpfSvItzsPkXnNsZ/TNfRL9/sjRfVRYnrP0IveNbEXbxReqhiPOM2MNURt7ZXIzAOFX2Md1veFEvXHnA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	326129de-2deb-4a84-8386-62cf25c43755	2025-12-25 18:35:32.041129	\N
88662df1-48e4-4c8a-8ad0-5c1127c8755f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"B/PC4URpfSvItzsPkXnNsZ/TNfRL9/sjRfVRYnrP0IveNbEXbxReqhiPOM2MNURt7ZXIzAOFX2Md1veFEvXHnA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	cbe8ccc9-7ade-4a56-8d84-0b77070f3517	2025-12-25 18:35:32.089544	\N
cdc23cc5-aced-4dfd-8ce6-dc6d58194b18	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	82dd0eaf-a0d6-4774-a588-f1b7c05acd0a	2025-12-25 18:35:37.639433	\N
5a37836e-cb77-443c-9bdb-4b7de69a98f9	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f3fb53f5-f564-4be9-acf0-a67842955afb	2025-12-25 18:36:19.946387	\N
3e18950c-7645-4738-b425-ffdfa84c6846	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":\\"/uploads/media/663184e9-1d96-4a30-bb56-ffa09284dcd5.jpeg\\",\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":null,\\"footerDescription\\":null,\\"footerCopyright\\":null,\\"navBrandText\\":null,\\"navToursLink\\":null,\\"navBookingsLink\\":null,\\"navLoginLink\\":null,\\"navLogoutButton\\":null,\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	027d3404-0020-44ee-b11f-01c044b370f9	2025-12-25 18:36:23.831331	\N
1383af26-03cf-4927-96bd-35ce575628fc	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Hi51ovHVPelKyu1TzeTMu0aitJCqgwl9x+zgbUb5pw4wlaY5E9NiTy83a2vUkgNuAfFM6KcRM8kHR4EzYQ1eNg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f55e90ee-4b2e-4536-9540-9455c9bd91e4	2025-12-25 18:37:10.753113	\N
00c191e8-9ff5-4e57-9c70-8e36222fe97b	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f968f8f2-65d5-40d7-a1cf-acbafa5d7e2d	2026-01-24 13:19:47.674981	\N
1eea4715-b3bc-4a62-844b-3cb2db7ed5f0	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Hi51ovHVPelKyu1TzeTMu0aitJCqgwl9x+zgbUb5pw4wlaY5E9NiTy83a2vUkgNuAfFM6KcRM8kHR4EzYQ1eNg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d08d7493-5065-433c-b9bc-64ee8dd0e388	2025-12-25 18:37:10.860443	\N
428f2f07-a910-4d84-89c4-4d56e8140c06	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b0689918-4a38-41bf-996a-67e93c6d800b	2025-12-25 18:37:15.104802	\N
800afc7e-ad3f-409f-8278-b5e6b67ffddc	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"4P9FRa9jKmwY7aPZtm3JUJbN9BCCZKZqqGLddz3QfDRnu9p7aT8jHkzHFdB30fmj28HRkWonWqi41J+3josmvg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f4116c07-c23f-4045-bd32-26bc4be72ccc	2025-12-25 18:45:18.409558	\N
4920c753-c73c-4a6b-acfa-1b0561a9f7d4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"4P9FRa9jKmwY7aPZtm3JUJbN9BCCZKZqqGLddz3QfDRnu9p7aT8jHkzHFdB30fmj28HRkWonWqi41J+3josmvg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f556584e-9632-45ff-882e-4bec6d5b9e8d	2025-12-25 18:45:18.409543	\N
9225c3a2-445e-4844-82d2-1da129eecd43	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	73dd5c31-400a-4118-8346-6bfbfe8e7562	2025-12-25 18:45:21.518444	\N
d402b1be-add8-463e-80ba-c7085dcef1da	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"ISAfIb7KuEqgFSoX6tojtzSCb0/T5L+GqKtlrZcgna5ptysZLDmP2dp1LC742QSpjrZqbcKGrl+C1sDGKtBXsg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	957295bb-a0d4-4f3a-b529-d6b2a175235c	2025-12-25 18:52:25.335577	\N
d265e557-5a44-4574-82c9-f7f7e373c373	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"ISAfIb7KuEqgFSoX6tojtzSCb0/T5L+GqKtlrZcgna5ptysZLDmP2dp1LC742QSpjrZqbcKGrl+C1sDGKtBXsg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1126ad51-3944-4dfa-aa1e-0bcdbfaa8f4a	2025-12-25 18:52:25.335592	\N
024c3d67-bba3-4909-95e6-67bc9b8fea41	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	eadc48c9-810b-4a99-9956-82ae6ab0a4ac	2025-12-25 18:52:29.465923	\N
a1b769d7-67e8-496b-ab51-edbbba8ab730	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":null,\\"footerDescription\\":null,\\"footerCopyright\\":null,\\"navBrandText\\":null,\\"navToursLink\\":null,\\"navBookingsLink\\":null,\\"navLoginLink\\":null,\\"navLogoutButton\\":null,\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	36305718-97b8-4716-8bce-678aba711435	2025-12-25 18:53:03.680315	\N
36bcbb0e-c518-49fe-a83d-5fbc2fbda8c7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"GqzuirteapJF/lWUtr9zncqYrikrdGBw30PlkwhddMz8S0OTPCRczBmiZO3GVVf/QplTY618XAcFF0rBxBUFGw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	33413246-81c3-44c9-ad8f-e639830ad577	2025-12-25 18:53:32.708159	\N
542a23e3-280b-47da-b022-cbc6eccf7d50	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"GqzuirteapJF/lWUtr9zncqYrikrdGBw30PlkwhddMz8S0OTPCRczBmiZO3GVVf/QplTY618XAcFF0rBxBUFGw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	5d1ac6e0-8d8f-4266-9db2-4731b29a80b0	2025-12-25 18:53:32.831286	\N
52ac8caf-11a3-448c-ba80-3333fb38e0f2	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	54b261b4-d1a8-44fb-8eee-34ffe34c3ab4	2025-12-25 18:53:35.992852	\N
a2d1b73d-74c6-44a2-b902-1fe510083cb3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"VGhoNmX48elxH3KIHKFGK3U318iEXEFVwt8FLNHVkSHZXp2Srn3n52/Gx6HLTybQb5U5vEBtOoGbkMaPvg3TQw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1938d0d0-c247-4f4c-994d-607af4d149ff	2025-12-25 18:53:47.557393	\N
1e18f6bb-4998-49f5-b3d0-f2a86d4c44b3	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"email\\":\\"cliente1@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\",\\"confirmPassword\\":\\"Panama2020$\\",\\"firstName\\":\\"Irving Isaac\\",\\"lastName\\":\\"Corro Mendoza\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	99fa176f-1a05-4528-8e3b-0d0f047d95a1	2025-12-25 18:59:01.500475	\N
c7b3777b-f4fb-4ace-bb2e-e9f5ad548f02	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8b2a6dbf-c1fd-4159-9ff3-d22250791d2c	2025-12-25 18:59:26.899255	\N
cccf6372-3a14-41bb-b2c2-bcb162d3fb78	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	5e1ff4df-d687-40ee-b6f3-22f7ef7e2b20	2025-12-26 02:55:29.251823	\N
1befc81f-f9a5-48eb-bea2-93055ec7c30f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"0VnOYD5SWIYKa+VLyM8yIxhxoHf8ydTACORnrA2Kt0hCmdiD4S/2lAGqfELL4THtUYFczU0gOGb5Llyc+yO+FA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0b1e55d5-9619-4b1c-bafc-6cef64fcc06e	2025-12-26 02:55:57.216198	\N
f3bcbc8d-b5eb-417b-b3b6-a5d11a8e48cc	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8ac443a2-f750-4fab-b9c2-1aa88f7c4f6a	2025-12-26 02:56:31.678249	\N
5573fb91-bda2-4a6b-8269-a9d45f8584ed	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	84fed9f9-6033-4786-b8a0-a6a078889eb6	2025-12-26 02:57:26.153057	\N
7432e2f7-b4c1-4460-846f-fde95929a192	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"aJ/1SvfhfmZ/85uzgJ8DzWGLMJZuiqkQAszmlXRaEVi1U5ctZe0uU385+PeQg48gkJOZvf2kN7kELkbLy3wQPg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	038301d6-21d8-439b-8c2a-3ea9806fbec7	2025-12-26 03:06:59.014011	\N
a4414ab6-c0d1-4755-8156-7e3ed018a9c3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"aJ/1SvfhfmZ/85uzgJ8DzWGLMJZuiqkQAszmlXRaEVi1U5ctZe0uU385+PeQg48gkJOZvf2kN7kELkbLy3wQPg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6ab008b7-7385-4549-ad48-bff838037710	2025-12-26 03:06:59.013965	\N
85594b1d-cc42-4d21-82ee-8af487c12eb0	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	cecc22d8-1db1-4954-97c9-1e4e821c36a5	2025-12-26 03:07:30.191723	\N
1c5ee5b5-af05-41b1-9e0c-721ed09de227	44261c54-dd97-4858-b686-a0076e3943e6	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a5f5afda-9e8a-48b7-aab0-c2e6fb8ffeb4	2025-12-26 03:08:35.14892	\N
0ad5b461-ce31-45f5-944e-e4769e6e60cd	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"zUpcckgkOIMT5XhTjTlaRL4PA3pRM7MRSyTGD8JhjGnHw1l4+s3R4rUIbKb4+Kfp4n99jW/tJyAlXJtk0DzoCQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0af5b41f-6622-4dac-9cef-dd671db007f8	2025-12-26 03:12:25.254344	\N
bdbd7fd9-302c-4ea9-9808-8a0920d05d04	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"zUpcckgkOIMT5XhTjTlaRL4PA3pRM7MRSyTGD8JhjGnHw1l4+s3R4rUIbKb4+Kfp4n99jW/tJyAlXJtk0DzoCQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3b29c82e-00ad-44a0-8601-d646057aaa8b	2025-12-26 03:12:25.254344	\N
6ce73b86-417e-44a4-aa87-719cb342e1d2	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	eb1e3e42-852e-4466-8b61-e2b1aabffa0b	2025-12-26 03:12:28.489248	\N
b13195f7-c2c5-404a-aede-8dcd8324e874	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tourssss\\\\nDescripción del Tourssss\\\\nvvvvvvvvv\\\\nsssssss\\",\\"includes\\":\\"wswwswss\\\\nwswsws\\\\nwswsws\\\\nwswswsws\\\\nwswsws\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"tourDate\\":\\"2025-12-28T11:12:00.000Z\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	62756895-d25b-4285-aae2-597b84c44aea	2025-12-26 03:12:53.696708	\N
7de6683e-0c9b-4e39-95bd-388dbd2f7450	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"K1gDhPeaRIQ9f723jXIMRJxB+UcwpBgfF9vZxk6UUTcQIktb1m9blVvvAFZPin2BQJTnYDkNqhYpjxfPmrLBmA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	7c212841-5d23-4981-9122-3b15eac69bf6	2025-12-26 03:13:13.629108	\N
e8d1fd21-3724-47ee-91c8-357df9488921	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	e18cb70c-a3d4-439b-836f-5aaefcffa94b	2025-12-26 03:15:25.890242	\N
892ee82e-8206-46e3-81c9-6c4dd0cacc39	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8e6899a0-53e8-4a04-b8d7-61e0787ef1ca	2025-12-26 05:44:25.637706	\N
a8a9812b-524b-4f26-9f4c-ba94b732e88c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"oAfN7+oH2y4awxD3Zl4aEBiyy0X40x986PKW1RREMsedYSOWLWQcXVMmYd4bnTH9bHzC2DUObHqXE+CrDNnM7w==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1bbce239-f6f0-45b9-9ec8-ab87a1c9900a	2025-12-26 05:58:28.505479	\N
0301b655-e5e8-489d-94ab-316a1bbacf02	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"oAfN7+oH2y4awxD3Zl4aEBiyy0X40x986PKW1RREMsedYSOWLWQcXVMmYd4bnTH9bHzC2DUObHqXE+CrDNnM7w==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6355396e-fd22-443d-84c7-af8883fc9c41	2025-12-26 05:58:28.600476	\N
06e5e1b3-309a-444b-a08c-9b010ddbb110	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	47f9f583-458d-4ca4-a790-0c1c135d9c40	2025-12-26 05:58:48.053096	\N
1e09231d-9245-4043-a196-7fa193ae781e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"+nHkgYSV8XSdk5qR9iyX0DAG7LOLjhwEV8Yr6xnkE9ucfH4vxdcJVhZyFns8RHoDvddVGRfkI3KD0jCnrAZ4XA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	22911334-dea8-4eaa-8968-54e1d77dfbf4	2025-12-26 06:02:25.426045	\N
b61bb00f-3899-4690-a995-413b87376dc5	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8ac7e4fe-20c7-4a1c-8c8e-f3df7944602a	2025-12-26 06:02:29.228624	\N
46fcc3db-aa7f-4989-883e-8744db1bb22b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"CjNuDmk/efaEG+H5C3K1rI6g9d0cfnTNX/Bu3QCVmpzzT34pH97v6+5ARmuqDdqja+/C53suR4gEN6YrDn60Qw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	549d10f6-1f9e-4e36-a450-f06c81c2c255	2025-12-26 06:04:43.941993	\N
51e8a628-2901-42e6-94c7-280e95efc9e3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"CjNuDmk/efaEG+H5C3K1rI6g9d0cfnTNX/Bu3QCVmpzzT34pH97v6+5ARmuqDdqja+/C53suR4gEN6YrDn60Qw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	05fb0a47-e373-464e-b748-5e61e6190101	2025-12-26 06:04:43.941971	\N
820a4a01-365c-47a7-a9b4-b87a4edea0f4	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	831ea8eb-bcf3-48a8-b407-b1c603f724b8	2025-12-26 06:04:52.411061	\N
65e8790d-bd0a-4e50-a150-0be2f2516cab	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Qvh49AMI8rSK65hyVlg3/AbEVxBmQbIT+g2PZ2kxxu0eBxyNcpw9Se1LzpO7U8QQBaltvGYzlrAKGeQ5vv8Dtg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	55cbfb0d-5111-4092-8d1e-6e37301c0eda	2025-12-26 06:07:30.160938	\N
ddaa0831-a2b1-4adb-944c-e4834f1b3c12	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Qvh49AMI8rSK65hyVlg3/AbEVxBmQbIT+g2PZ2kxxu0eBxyNcpw9Se1LzpO7U8QQBaltvGYzlrAKGeQ5vv8Dtg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	352c7528-6c38-4ebd-a167-639b599e36a1	2025-12-26 06:07:30.160939	\N
abdec01f-b00b-4f00-a5ff-b485e9aceaf4	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d8a7afe8-ab45-47e9-a707-af083945d103	2025-12-26 06:07:36.292405	\N
8440bbb8-16fa-4a00-86af-e6ea2da9749c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"NMcyfuGzKi9/LzXUMZnggBqeuRWK1ZFmZa3qxgR+f7QaQ9kUELCM9WFVV1N8EDbnmUYtGR+V/KYlYuHSsDpsxg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	92e6d97e-1f55-4a12-9cd4-1c0758035959	2025-12-26 06:14:34.849342	\N
063a8f79-27b0-4eef-82b0-ba71e94b0bf4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"NMcyfuGzKi9/LzXUMZnggBqeuRWK1ZFmZa3qxgR+f7QaQ9kUELCM9WFVV1N8EDbnmUYtGR+V/KYlYuHSsDpsxg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	7366aa7d-08ec-44c2-a5ba-5d0a472bfa5d	2025-12-26 06:14:34.849341	\N
6eb655e4-8852-413d-94f7-4437dc06331f	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d6d11e7a-d6cb-403c-b2cb-5579717508c2	2025-12-26 06:14:39.13829	\N
5193c418-8585-4ae3-951e-9c837580394d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"ZZYPVuqgFfCn4pNdhlxkvBkxSrzNdauttrE+/l5nr8ybVv9H6NxJ/ODUzB2TmJrmlxLS+kfEs9mBI90D+sdwFA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	19d02499-c652-4137-8ba6-92aab5fbfe33	2025-12-26 06:20:07.946893	\N
c7e7b1bd-69b6-4ffb-9712-1ebe092c625e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b4637edf-7ec7-476c-947f-c7f675fe2f0c	2025-12-26 06:20:10.579049	\N
ed240b08-7f94-4571-b5a2-5e6dc8021bf3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"yKdLmZNFuziEHhPf7rQtyVMvovLJNajRPtwED9mExl5sGXBjM57yUIUmM3x9n5BnxBbKfKE4kSLM3lhcXx6mNQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b934a678-a0b6-45b1-afda-b5880e323794	2025-12-26 06:24:26.165709	\N
069b5cea-6dad-4d10-a848-c038d2a2bf16	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	48976c9a-eaff-487f-a97a-5ce81db6bd67	2025-12-26 06:24:30.366914	\N
552c5fde-70cd-416c-b7f4-906665a6c7bb	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	User	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	UPDATE	\N	{"RequestBody": "{\\"firstName\\":\\"Administrador\\",\\"lastName\\":\\"Sistema\\",\\"phone\\":null,\\"isActive\\":true,\\"roles\\":[\\"Admin\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	324d7d9f-37b4-4617-815b-a9ec740d3093	2025-12-26 06:24:41.044086	\N
b4bff083-18de-4a9b-aad1-0fb4fbc4d129	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"VTHHGnOvk9s2953/WrrTKnYVWaxPE/NsXcpOhFaEQueJv7uGNZIwx5K4Hy75hpWP8vlLX07t+jpydc1BD7F1jA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	98393869-3d1b-432b-a420-f1d2732a9a95	2025-12-26 06:27:32.598865	\N
1a4d43fc-9c02-4578-806e-1d4261199883	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"VTHHGnOvk9s2953/WrrTKnYVWaxPE/NsXcpOhFaEQueJv7uGNZIwx5K4Hy75hpWP8vlLX07t+jpydc1BD7F1jA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d025fdb6-5d56-4fc6-b8ac-6f672e191bad	2025-12-26 06:27:32.598866	\N
2280edb1-bf47-4854-a570-c04698c9a8d9	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\",\\"confirmPassword\\":\\"Panama2020$\\",\\"firstName\\":\\"irving\\",\\"lastName\\":\\"corro\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	469b552c-62ed-4963-9c44-59d0f18bc1c6	2025-12-26 06:28:14.09093	\N
24c053c1-a522-449b-8b36-87ee80d83c38	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f180612f-9e19-4781-b93a-60cf38ed4c2a	2025-12-26 06:28:38.694603	\N
b58295f1-c39b-4473-9cad-83cff50e7b90	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0efe5d4a-b1bf-4fb9-96cf-2817761be5da	2025-12-26 06:33:49.457653	\N
fa45f1db-db08-4e13-99ff-72b4b0cced8c	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"33R4wsUzBJS+8x4vvxLLa814qDBLZRvWMoBftpjSifS3q65oaBl0dzWC6UbONo1LNeMcRE8ErBWzZ14phz5GmA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	034d12e3-149d-44a2-8298-aa9bbab7bfc5	2025-12-26 06:39:15.909152	\N
ff2d6ec9-bb0b-425a-abbc-bc7ef44a0136	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"33R4wsUzBJS+8x4vvxLLa814qDBLZRvWMoBftpjSifS3q65oaBl0dzWC6UbONo1LNeMcRE8ErBWzZ14phz5GmA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	260a1678-562a-422b-83bc-ac58b48cb9f9	2025-12-26 06:39:15.909082	\N
b7b6351f-9b87-4d9b-99ad-460e894ea366	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1fc5c5db-2897-4af8-81c9-5df8a1483bb7	2025-12-26 06:39:37.559496	\N
50ed5f28-3e20-46fe-af47-9b4098154068	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	eb13bef8-c1e3-4eb1-bc8b-a9e451145003	2025-12-26 06:40:33.287372	\N
f6ae700c-6bab-4992-9309-b434182897cf	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"BbgpdR7VllgUZY40XukiIq+nT8QKlJOnX6UPSbU1O58+Tnhcfk1vtz+g8G2gvbzOzIB6KKHnh/8Qfw2OMVcVHw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2273fb9f-e204-4a60-9563-9f57a4928783	2025-12-26 06:49:30.463086	\N
2b651527-3054-4a4f-9da7-91bf52fce62c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"BbgpdR7VllgUZY40XukiIq+nT8QKlJOnX6UPSbU1O58+Tnhcfk1vtz+g8G2gvbzOzIB6KKHnh/8Qfw2OMVcVHw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	358820dc-5dc6-4446-91f4-481a86004749	2025-12-26 06:49:30.463088	\N
d1982183-0ccd-47e1-831e-07696575dace	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6c189137-a599-4721-9860-05c43debb8d5	2025-12-26 06:49:34.980414	\N
3696dfac-3ab0-4cb1-9a15-e04a11b6c75b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"V0tmrLMmdsqHQ7WoUT0YF70vBbrxNKGeYztSE+KUOXdZ9nE3w7MXFR2qAOwXnx3fsWTrCgkCnLj31CFjZZRXFQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	039a0d30-4df7-432c-844b-c073a6d730c7	2025-12-26 06:49:49.262244	\N
7bd5c65e-1baf-4228-9144-d8738c3677bc	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a73e58df-4038-4779-9824-82969063bcb2	2025-12-26 06:56:34.264709	\N
dd14e01d-67e3-4526-84a2-efff1d0c62f2	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"ItKyypMjv+3eJt9j/BSoWn38J1NHyNzcpWqoIyp2xxDGucdvbpd0gyfa/O++rHalqstPksrgEP7a34BJZVwehw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	28b33457-c42a-4b12-ac20-61bd366d110c	2025-12-26 07:03:24.643745	\N
fceda4ad-e303-421f-b815-cfc9ed08aab5	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"ItKyypMjv+3eJt9j/BSoWn38J1NHyNzcpWqoIyp2xxDGucdvbpd0gyfa/O++rHalqstPksrgEP7a34BJZVwehw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	5afe88f5-d60c-46b9-9a95-a0f899267f5d	2025-12-26 07:03:24.670582	\N
2628fff2-0d4c-42ac-9741-d9f1717b7de6	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3b48b5fa-133c-4822-b8eb-0001e8993f7b	2025-12-26 07:03:43.622912	\N
2d102454-25f9-4243-b508-e5ebf0c1f4d9	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Q1o9Ao58RlU+YwNIz/fWQUDGfglyL9niKKCD7QG1Dwh+KyT0rdeDFtHmE8y45cSZRxfIoGHfl28+TsMhdHXe5w==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a53397b8-c5b3-42d5-a4d7-73e499a1aa75	2025-12-26 07:07:51.113316	\N
f05cf094-e7d5-48b7-b81d-bda88f64b8c9	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	59eb78a2-0b3f-4436-b2c9-98e250ea5e36	2025-12-26 07:08:05.089203	\N
a00e09bc-453a-4b81-aac9-8b2d823c626d	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"Q1o9Ao58RlU+YwNIz/fWQUDGfglyL9niKKCD7QG1Dwh+KyT0rdeDFtHmE8y45cSZRxfIoGHfl28+TsMhdHXe5w==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6d6f9857-4d9b-44f2-8d5e-bbacbf24e342	2025-12-26 07:07:51.113317	\N
fb3298f2-bcd3-448b-baec-870e026e28dc	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"G6+PzW7eVY78IlB5BSFv6sUP99rNwnHXN2FjhEndW0kutzsUMWD/64fmszi305EOzfGrGYRWMTH68MGipmYD8g==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	43bfe6e8-8fea-4112-939d-1b0a116eeb20	2025-12-26 07:19:35.943215	\N
4840ee28-88e4-4d70-ae80-dbfee40600d3	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"G6+PzW7eVY78IlB5BSFv6sUP99rNwnHXN2FjhEndW0kutzsUMWD/64fmszi305EOzfGrGYRWMTH68MGipmYD8g==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	851cf77f-1906-488e-8b95-5bd95bb3715e	2025-12-26 07:19:35.943239	\N
276f7a67-3c07-453e-ae71-f102f61bb8e9	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	47593cbb-fd8c-4218-a714-e7abb4be814c	2025-12-26 07:19:42.693034	\N
72f6c696-14f7-4c92-b2af-42991b944883	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"rSOPFC6FHnsYYqrDHnu030kiBlGtVVIVmRA0zrDBpxUnET0b2SYb2Ua7nKvcuBDzEAvXYVNIN9PBefU4EzcTgQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	ddd49a95-6f16-4ea9-a793-864cb99b9527	2025-12-26 07:19:48.368401	\N
30d181ec-6fc9-4fb5-8c15-add946077f1f	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	66b9d2ee-43cd-4cc1-aabc-893243fbfc40	2025-12-26 07:20:11.404751	\N
bf66bf06-b754-4fa8-8f54-8d8fbe3e28e7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	22686d70-f92c-4e6b-b865-efe2fabbeb91	2025-12-26 07:45:07.086337	\N
91ab947a-bb95-4cd6-bb5b-f3a0d28d17e9	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"bzwn8onjEoKgfI1+RXQDtEi8rJ/YqIUaG6mURcFm5Bl3z57pMoSlzNy6bpZ6x52ke+vDPxQiy2JkoBDVOL1/RQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a1949735-2a58-492e-b51c-87fac35841e9	2025-12-26 07:59:08.660294	\N
765b91f5-fb34-4784-8551-46f269260bac	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"bzwn8onjEoKgfI1+RXQDtEi8rJ/YqIUaG6mURcFm5Bl3z57pMoSlzNy6bpZ6x52ke+vDPxQiy2JkoBDVOL1/RQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0449e8c1-101e-402c-b075-0592b3a49210	2025-12-26 07:59:08.660307	\N
ba07b012-f025-4e68-bf34-8b5251f32ce9	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f490d5ac-4e76-490e-942f-3477f60b5ac5	2025-12-26 07:59:11.820178	\N
223eb64c-d92d-42f1-a9c6-b6133e08080a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"EDSZxX/u3GUQgyC67x6DwNOG8V2RsS0fns0ocB4rsLvRkoPtumF0px4AdxhWPQfOF6RLLwGBgZK7bxA55zBHlg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	997f0b85-0258-4b56-a845-37a8d48396ff	2025-12-26 07:59:25.709066	\N
70bb4eef-5919-4862-b63f-3827f6497fb2	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	63827edf-5101-4543-b7f4-e557e2113d09	2025-12-26 07:59:45.597478	\N
e2f44117-057f-48b8-bd17-7bb8919a7948	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"OrdMWB3nSO0JqPDL2T5dlnM/hogMLeTOH5YTcKabQICg6JJMUyYAHepWlGS4jqfXdHzpKeOHlRTtpVGi/yEsZA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	ba982981-affc-48cf-ac00-d5aedca441af	2025-12-26 08:09:06.505924	\N
e4ec18e8-156e-4bf8-badb-38c1c16dcec2	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"OrdMWB3nSO0JqPDL2T5dlnM/hogMLeTOH5YTcKabQICg6JJMUyYAHepWlGS4jqfXdHzpKeOHlRTtpVGi/yEsZA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	dd3aeb59-54fd-4a52-87f9-24ab32dcf25b	2025-12-26 08:09:06.505926	\N
a10d458d-e393-4533-a17c-702394a8849f	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	1de0f817-74f1-4325-9b0d-8a0160f56d41	2025-12-26 08:09:11.334518	\N
06da382a-875f-49aa-9eeb-4be5fefdc0a8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":null,\\"footerDescription\\":null,\\"footerCopyright\\":null,\\"navBrandText\\":\\"Tours\\",\\"navToursLink\\":null,\\"navBookingsLink\\":null,\\"navLoginLink\\":null,\\"navLogoutButton\\":null,\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0b84bd66-206f-45eb-a973-9d07e7288c0b	2025-12-26 08:10:14.119552	\N
26d210f7-d618-44df-a39b-777361246886	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"uwZBK9Xt5SkeMQl42blTWiPu+WrfBp8OFhBXX3VqD2T2aiGm3wOsNO003bhDm7vbgRgT68o1tT56S0dFBSS+ng==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	c1cdad9b-6030-4c71-b669-65605e268c7e	2025-12-26 08:10:29.139336	\N
fc07a139-e739-4074-94f8-b4a7e3d41ffd	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"uwZBK9Xt5SkeMQl42blTWiPu+WrfBp8OFhBXX3VqD2T2aiGm3wOsNO003bhDm7vbgRgT68o1tT56S0dFBSS+ng==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	683472d4-6fea-44be-acc4-34411560f783	2025-12-26 08:10:29.148331	\N
3629252f-0bfc-49d8-8c5d-78c70ad942f7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6ae02bad-e8c0-4f40-8b54-28fa4da52e3f	2025-12-26 08:10:32.572728	\N
98930bb9-2204-4e1f-8464-2d5cae157b69	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":\\"Tours\\",\\"footerDescription\\":null,\\"footerCopyright\\":null,\\"navBrandText\\":null,\\"navToursLink\\":null,\\"navBookingsLink\\":null,\\"navLoginLink\\":null,\\"navLogoutButton\\":null,\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	78f045e3-d32d-45bb-9935-78610a516c22	2025-12-26 08:11:00.637847	\N
e4af9f43-e851-4ca8-a53b-778436395c7a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"gmkz9YohRt5Kja3uLpqkI01W1NsqFVuQ1WGA09JtDC5PQqfMgj+tRWH5kG6pn3tx2zSWKsf2X+4VsRVj+8lVkQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	16d46ced-9a73-42a6-a798-27b8dbe7c122	2025-12-26 08:11:47.683253	\N
8cd4d03e-694e-4984-a2c2-1f7b26b112f4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"gmkz9YohRt5Kja3uLpqkI01W1NsqFVuQ1WGA09JtDC5PQqfMgj+tRWH5kG6pn3tx2zSWKsf2X+4VsRVj+8lVkQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	4f203524-cfa3-4349-acf4-f48cba684add	2025-12-26 08:11:47.868435	\N
3e0ecb2a-ba3c-416b-a2fe-8c7c6e40ba71	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	7c2e8c69-d276-47ae-a0e1-e23a05f7470a	2025-12-26 13:39:08.027571	\N
3140c3bc-748a-4843-8223-81cf9b8bde4c	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"WAgz2E+BzE5NMJcv+ax27+KFCgQ53C7QyISQJS31res5bj0zgSG7MD+fI3+ZYNB4L6xyAsHpeoxUWKTDHp+Dsg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	97e1d486-b3c8-4c5b-8a89-65fb87d78b8b	2025-12-26 13:49:30.236363	\N
2e5c8d2d-bbd6-46e2-9482-8f1416900920	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"WAgz2E+BzE5NMJcv+ax27+KFCgQ53C7QyISQJS31res5bj0zgSG7MD+fI3+ZYNB4L6xyAsHpeoxUWKTDHp+Dsg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f05bb69b-39f7-494b-90b4-ca405e41987a	2025-12-26 13:49:30.236317	\N
7b810044-c427-45ca-bc14-e41d2f503b13	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f5c9a7ae-41af-458f-a51a-c39b17d6398b	2025-12-26 13:49:37.204847	\N
2f406a03-4a64-4fc4-be44-54a23a7806c4	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":\\"Tours\\",\\"footerDescription\\":null,\\"footerCopyright\\":\\"@2026 AloticoPTY.com\\",\\"navBrandText\\":null,\\"navToursLink\\":null,\\"navBookingsLink\\":null,\\"navLoginLink\\":null,\\"navLogoutButton\\":null,\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	71576cf1-98a1-4c4e-a284-537b138da919	2025-12-26 13:50:13.962167	\N
ac6cfaa4-2a16-4d76-81c5-a9b368fd5fb2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":\\"Tours\\",\\"footerDescription\\":null,\\"footerCopyright\\":\\"@2026 AloticoPTY.com\\",\\"navBrandText\\":\\"Tours\\",\\"navToursLink\\":\\"Tours\\",\\"navBookingsLink\\":\\"Mis reservas\\",\\"navLoginLink\\":\\"Iniciar sesión\\",\\"navLogoutButton\\":\\"Cerrar sesión\\",\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0bd913e1-6964-4bc5-876c-aded7208b287	2025-12-26 13:51:39.682218	\N
91e0eedf-fa18-49c9-b2ec-60320e931473	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	UPDATE	\N	{"RequestBody": "{\\"logoUrl\\":null,\\"faviconUrl\\":null,\\"logoUrlSocial\\":null,\\"heroImageUrl\\":\\"/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg\\",\\"heroTitle\\":\\"AloticoPTY\\",\\"heroSubtitle\\":null,\\"heroSearchPlaceholder\\":null,\\"heroSearchButton\\":null,\\"toursSectionTitle\\":null,\\"toursSectionSubtitle\\":null,\\"loadingToursText\\":null,\\"errorLoadingToursText\\":null,\\"noToursFoundText\\":null,\\"footerBrandText\\":\\"Tours\\",\\"footerDescription\\":\\"Tu plataforma de confianza para descubrir Tours\\",\\"footerCopyright\\":\\"@2026 AloticoPTY.com\\",\\"navBrandText\\":\\"Tours\\",\\"navToursLink\\":\\"Tours\\",\\"navBookingsLink\\":\\"Mis reservas\\",\\"navLoginLink\\":\\"Iniciar sesión\\",\\"navLogoutButton\\":\\"Cerrar sesión\\",\\"pageTitle\\":null,\\"metaDescription\\":null}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	bef9bbb8-e5eb-4cd9-9a08-78debfa79b90	2025-12-26 13:52:42.75137	\N
618adb5a-d5d0-4fba-873c-8e4894a15dc6	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b85ccb99-829d-4041-a407-1ef05e7c3a5f	2025-12-26 13:53:26.005739	\N
4003b74b-521b-4afa-9978-4b9f3384ca48	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2c6d77ac-d4dd-4eda-95c7-9729f80b2718	2025-12-26 13:53:26.009863	\N
a008a6b1-eb87-4831-8a14-3069211fb754	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Tour	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	UPDATE	\N	{"RequestBody": "{\\"name\\":\\"Cebaco\\",\\"description\\":\\"Descripción del Tourqaqa\\\\nDescripción del Touraqaqa\\",\\"itinerary\\":\\"Descripción del Tourssss\\\\nDescripción del Tourssss\\\\nvvvvvvvvv\\\\nsssssss\\",\\"includes\\":\\"wswwswss\\\\nwswsws\\\\nwswsws\\\\nwswswsws\\\\nwswsws\\",\\"price\\":23,\\"maxCapacity\\":100,\\"durationHours\\":3,\\"location\\":\\"Panama\\",\\"tourDate\\":\\"2025-12-28T13:12:00.000Z\\",\\"isActive\\":true,\\"images\\":[\\"https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png\\",\\"https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png\\",\\"https://localhost:7009/uploads/tours/98404bd4-1166-4b6c-841d-126650b1a6bb.png\\",\\"https://localhost:7009/uploads/tours/d6a70f67-0c47-4e42-bfd1-a7640ca0ebcc.png\\"]}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	bb502564-7b3d-4345-9cb1-62dca0373676	2025-12-26 13:53:28.114685	\N
e4f39a8e-e4f1-43c3-9c37-6bbaaadfcd39	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"4DBh0A7Vj2gR47sYIdJb6t9mAvuYaQFhfXUAVBzEahfwan4sp4n5RWjhk+tVcv63TD7uuGxQB1cBQHiiBtsnpA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	9e029585-d26e-4396-9c31-8c5a96659f9a	2025-12-26 13:54:53.811974	\N
a2b27656-42d1-46b8-8265-889aff0dc73a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	0f4658fd-a2ce-4253-9a6d-ca6339f221b5	2025-12-26 13:56:23.425211	\N
cd98d9ed-b3bb-41f2-be5d-cfb7cad49064	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"countryId\\":\\"550e8400-e29b-41d4-a716-446655440010\\",\\"participants\\":[{\\"firstName\\":\\"Irving\\",\\"lastName\\":\\"Corro Mendoza\\",\\"email\\":\\"irvingcorrosk19@gmail.com\\",\\"phone\\":\\"+50765140986\\"}],\\"userId\\":\\"6093a936-f8b0-49da-bf2c-16e426df5e69\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	df92d770-5968-41a8-928a-a36fd8bf6a6e	2025-12-26 13:58:05.874173	\N
3fbfb19f-399b-485a-a93b-7b2021e39e90	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f68c13e3-4965-451a-a43f-e833ebc408ea	2025-12-26 14:15:15.701601	\N
566fcbd3-8b10-4f8c-91f8-5dde90b15ea0	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"countryId\\":\\"550e8400-e29b-41d4-a716-446655440016\\",\\"participants\\":[{\\"firstName\\":\\"Irving\\",\\"lastName\\":\\"Corro Mendoza\\",\\"email\\":\\"icorro@people-inmotion.com\\",\\"phone\\":\\"+50765140986\\"}],\\"userId\\":\\"6093a936-f8b0-49da-bf2c-16e426df5e69\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	6dd24d6d-b748-482a-9da9-312398467cab	2025-12-26 14:15:31.351663	\N
353f4376-ad80-468f-a2e9-3a1eb24c78c2	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"lIfEhLqm/aqPBUAJXxsuK8BLuiXg6+bPxyFHAUrEhEUDg5b3gTM55GgO/KXw3BKzsVUwT79zYIZ8rm21LrAYtw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	a2c66981-9a37-458e-84b8-a4c5a71a088c	2025-12-26 14:19:48.42205	\N
3ed44911-fd85-494a-883f-27a48bef52cb	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	f96bdacc-76bf-4263-b269-0c3c4d6ef8e6	2025-12-26 14:20:02.266716	\N
c10c5ddf-1b49-42fe-ba23-2a6336a55710	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"countryId\\":\\"550e8400-e29b-41d4-a716-446655440017\\",\\"participants\\":[{\\"firstName\\":\\"Irving\\",\\"lastName\\":\\"Corro Mendoza\\",\\"email\\":\\"icorro@people-inmotion.com\\",\\"phone\\":\\"+50765140986\\"}],\\"userId\\":\\"6093a936-f8b0-49da-bf2c-16e426df5e69\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	67291c2b-fb45-4066-a5fc-0d78c1e111cd	2025-12-26 14:20:17.816227	\N
61c38364-f506-4d90-86f1-bdca0fa7884b	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	3ffcb1da-7b1e-4ed6-b8a3-de80a21b76f7	2025-12-26 14:28:44.921948	\N
f2a86fea-0271-4eda-bb3d-021e96aa6663	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"countryId\\":\\"550e8400-e29b-41d4-a716-446655440002\\",\\"participants\\":[{\\"firstName\\":\\"Irving\\",\\"lastName\\":\\"Corro Mendoza\\",\\"email\\":\\"icorro@people-inmotion.com\\",\\"phone\\":\\"+50765140986\\"}],\\"userId\\":\\"6093a936-f8b0-49da-bf2c-16e426df5e69\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	bf76b374-a1f4-4803-b603-fafd78e1f1fb	2025-12-26 14:29:02.943334	\N
3067ad95-0674-41c8-b9b4-d4888b051dcd	6093a936-f8b0-49da-bf2c-16e426df5e69	Payment	00000000-0000-0000-0000-000000000000	PAYMENT	\N	{"RequestBody": "{\\"bookingId\\":\\"481cd80e-8286-427c-ae10-cc39c5694e92\\",\\"currency\\":\\"USD\\",\\"provider\\":1}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	8f44b576-bfc6-471d-b01a-b4a7ace5895d	2025-12-26 14:29:03.616945	\N
fb80bafd-436e-40e3-96d5-db38c31df424	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"U6Sr8OFBTUyOdaCnbVHEkfc6y49a0pKMHEqNoTWePQPyWUlE7vjiD+/RK2SRQpTCNbei8f/HfigeyTlLp/BVrA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	cd85515b-5acd-487b-9858-4227064c1813	2025-12-26 14:37:45.196639	\N
2237a3c2-fe79-4cd4-ac9a-972df83b6f71	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"U6Sr8OFBTUyOdaCnbVHEkfc6y49a0pKMHEqNoTWePQPyWUlE7vjiD+/RK2SRQpTCNbei8f/HfigeyTlLp/BVrA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	96ec4379-9c7e-495c-94da-a40aa9a63ee2	2025-12-26 14:37:45.256238	\N
3c208a1d-4127-4ee6-877c-22103ca673d2	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b6527d4e-bb86-43b6-9ccf-a3de1f3d898f	2025-12-26 14:37:58.64004	\N
4adf7c67-22cd-40ea-9348-20d85b710f16	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"countryId\\":\\"550e8400-e29b-41d4-a716-446655440002\\",\\"participants\\":[{\\"firstName\\":\\"Irving\\",\\"lastName\\":\\"Corro Mendoza\\",\\"email\\":\\"icorro@people-inmotion.com\\",\\"phone\\":\\"+50765140986\\"}],\\"userId\\":\\"6093a936-f8b0-49da-bf2c-16e426df5e69\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	64e28962-018d-418a-a44a-e98ed7d7302e	2025-12-26 14:38:34.594096	\N
e9135024-ab37-4506-8bbc-d4084ebc84f5	6093a936-f8b0-49da-bf2c-16e426df5e69	Payment	00000000-0000-0000-0000-000000000000	PAYMENT	\N	{"RequestBody": "{\\"bookingId\\":\\"dbda33d6-4c7f-45ca-a236-89291e3ec7ec\\",\\"currency\\":\\"USD\\",\\"provider\\":1}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	488c8054-91bd-4bcc-8749-e01ee867c59f	2025-12-26 14:38:35.281975	\N
a9e52aed-37ef-4783-89e6-b7f6186c9174	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Panama2020$\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	9f77f2b0-3971-4c30-a615-0841521e48cc	2025-12-26 14:41:21.605901	\N
248f9ed1-c589-4ffb-9c46-1ec95c30c69b	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"countryId\\":\\"550e8400-e29b-41d4-a716-446655440002\\",\\"participants\\":[{\\"firstName\\":\\"Irving\\",\\"lastName\\":\\"Corro Mendoza\\",\\"email\\":\\"icorro@people-inmotion.com\\",\\"phone\\":\\"+50765140986\\"}],\\"userId\\":\\"6093a936-f8b0-49da-bf2c-16e426df5e69\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	bc9ab526-c9dc-4c4e-ad55-79c844a5daeb	2025-12-26 14:41:36.894291	\N
8cdccefb-aea2-4d78-8760-13186c10c31b	6093a936-f8b0-49da-bf2c-16e426df5e69	Payment	00000000-0000-0000-0000-000000000000	PAYMENT	\N	{"RequestBody": "{\\"bookingId\\":\\"11c1cc4c-f53b-4d09-b204-5e3b85190d79\\",\\"currency\\":\\"USD\\",\\"provider\\":1}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	ac552652-7c19-479a-a059-e145f6aebcbf	2025-12-26 14:41:37.575968	\N
d62b0da2-4db7-4a27-9bdf-f1a604586fe6	6093a936-f8b0-49da-bf2c-16e426df5e69	Payment	00000000-0000-0000-0000-000000000000	PAYMENT	\N	{"RequestBody": "{\\"paymentIntentId\\":\\"pi_simulated_7897f32e26fd4de799bed05721bbf48c\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	b4225f49-7d24-4072-bddb-01ea833f15d7	2025-12-26 14:41:39.546589	\N
66f6e00b-c7b6-4500-b660-3da7671948b1	6093a936-f8b0-49da-bf2c-16e426df5e69	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"pTKF2aYhmaS8oraQgy+V2vUK/jX2LZVpJgxP/QH0ehGuqR66X1zDpso3rwi6erROAkq3hCcTXm36qZmx8wKnXQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	d26bd0ba-f87c-4b53-84d4-5ab4e6f2515b	2025-12-26 14:43:35.745661	\N
cd588e7b-abbb-486e-a4c2-bba2d451f3e7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	0f460d9e-fe49-4bcc-a79e-64d38c060f2b	2026-01-24 11:53:33.724611	\N
1522acbc-4ea0-4e85-8026-081282fe64a3	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	83171a5c-fe60-4dfb-b9d8-2bf6309a13c1	2026-01-24 12:11:19.151563	\N
ecaa27be-de9f-4f57-be42-c19d21219a4d	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"4KvXMPLXo/Beru7lI4/kdqJ6u79upCav2SrBTvitpzZTJdjY9pbzUc78+66j/EHnfSZqbxYacE5uElVhqO9kZQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	5d17a918-1a01-4872-8232-a50db55d55f3	2026-01-24 12:11:41.142993	\N
a881a55b-2f7d-44ba-b431-58354a7b271c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	0f3c81af-964e-4dbb-a4ad-0fe865126d51	2026-01-24 12:36:02.185799	\N
025d160a-3b03-4d39-b628-5597d8f889fb	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	8278d336-9e71-49c2-b199-495e7547b102	2026-01-24 13:15:32.522458	\N
1368184b-ad93-4842-8815-dbe96b4f4e01	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	d451d954-cc4b-43d2-bc27-6af7a64e7189	2026-01-24 13:22:26.178823	\N
58396f1d-ef7e-4f84-be3f-cb095b8db4e1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	5d27548e-3b35-439e-8c8c-af9768fd1470	2026-01-24 13:23:04.935898	\N
d1baa053-cb8d-466c-9082-5e41ac0eea5c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	434d8251-2f9e-4ec5-97d1-789e0da40e09	2026-01-24 13:28:20.679115	\N
97c975ef-1574-43e0-9770-956f43c47431	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Usuario\\",\\"phone\\":null,\\"lastName\\":\\"Prueba\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	fbd9a553-d37a-450b-8e0e-92e568bfc59a	2026-01-24 13:28:21.090674	\N
65581e23-abcb-45a3-9348-1103d67f610c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	c45bc6ce-c3b9-4543-be3d-531858a0ae0d	2026-01-24 13:32:07.542538	\N
5c6eecd6-a91a-4f34-b0e6-f3542a3f73f8	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	6a29dc17-e114-4c25-a728-89715af5a5f9	2026-01-24 13:32:07.913473	\N
67f5c2a0-ad30-4a30-93f6-7dfe83c6e5a3	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	ea293d01-6aa5-4773-8d24-a0f73a10436f	2026-01-24 13:34:20.360876	\N
4d446144-2020-4f20-aa51-2bea224dc7f6	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	13e8e9c4-a2bd-4b20-a53a-ffba0b7101ca	2026-01-24 13:34:20.495242	\N
9096287b-cb05-48df-a7b0-e9025b58ee13	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	d032e08f-1171-451f-88f9-523f2b3972fd	2026-01-24 13:35:23.524824	\N
81573068-e7fa-435e-a4f6-a39450462316	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Cliente\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	d0f455b9-b0e6-41a3-9148-cc930dfc3780	2026-01-24 13:35:23.632554	\N
ed0e53d1-3bbc-449e-b7c2-dc47e0b7a21d	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	43998594-e184-40ab-9783-8b99ecfb36d4	2026-01-24 13:35:23.927977	\N
0ce1fbac-9afa-4d56-9b7d-b0e149f41761	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	ebdf4ccd-7e35-4ca4-9e75-568030abb15f	2026-01-24 13:35:24.032017	\N
f07a5a45-5f83-41f8-8087-25561c6b7eab	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	fd083240-ca66-49f8-b3e5-eb141fd051b2	2026-01-24 13:36:22.80314	\N
f4e28c36-f000-44fb-ac7c-9a0b648b63c3	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Cliente\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	93423b49-415e-4f30-94fa-75bfc795f77d	2026-01-24 13:36:22.907306	\N
4409c923-8029-4020-bc8a-d45ae7e7e653	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	5c31e189-409f-4711-9472-ce45af724e83	2026-01-24 13:36:23.212499	\N
a97eed07-302c-4fd8-b1d8-30de2a5f6985	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	3c130a5d-352d-4c38-bcdc-f15a8b54b2f3	2026-01-24 13:36:23.312801	\N
675716d1-8f1a-48c4-8947-59df1bf5d549	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	b1f85b06-9ee5-4e0d-8a07-f67c9096d94f	2026-01-24 13:36:52.868646	\N
9914f43b-c256-4f93-be2a-ea51b218befb	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Cliente\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	d11a78c7-710f-45f4-9eec-15778bfe4e80	2026-01-24 13:36:52.966445	\N
77fc0c47-57f3-418f-a8c1-83099f68aac9	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	1de4810b-d703-4f65-9828-869e2429d86d	2026-01-24 13:36:53.307713	\N
4440769a-d1d0-457e-a0e4-02c275ce64a9	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	0c183c1e-1076-43bf-b761-2e1911ca78f8	2026-01-24 13:36:53.400838	\N
686c6e59-12fa-405b-beca-cb2d44613424	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	30eb3fc4-5f8f-4b7f-bbd4-a39e9567f01c	2026-01-24 13:45:19.738026	\N
583cab95-1628-4114-9d0c-e79fc7287c7c	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Cliente\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	866e5754-a567-406d-b79c-7a651ac73a2b	2026-01-24 13:45:19.875489	\N
b7481592-8822-44ca-a89b-92c5d7d878da	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	5f4a101c-5e00-4848-9bda-981cdc3e15e4	2026-01-24 13:45:20.188271	\N
e9d10e94-5538-4a50-9e17-4a3d233c960e	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	c52bff74-4411-48bd-b526-f62e846b94f2	2026-01-24 13:45:20.306345	\N
d1406ba7-f08d-4d69-89f8-7b11d306e493	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	5e9581ee-a12a-44dc-ac75-8ddffaa0de8e	2026-01-24 13:45:26.350591	\N
ba639df0-1cad-4357-a4a4-983382e02c9b	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Usuario\\",\\"phone\\":null,\\"lastName\\":\\"Prueba\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	0b9a2895-8d2f-479e-a086-a4eebdd18590	2026-01-24 13:45:26.461543	\N
0cdf2b76-5ebf-49aa-ab4a-05995b951044	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	9ee0be7e-3473-46c7-9b97-17ffb95c9ccc	2026-01-24 13:46:09.963246	\N
d805f321-f2b6-4a74-9cd0-6db16a1ea055	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Usuario\\",\\"phone\\":null,\\"lastName\\":\\"Prueba\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	5386b890-0c35-4dbb-aad7-5375be18cf8d	2026-01-24 13:46:10.082936	\N
a22a3cd6-acef-4c24-a31f-bdbbd2196d7f	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f2567f15-aa9c-478a-a063-35422a79caa7	2026-01-24 13:48:25.387159	\N
e003b645-d139-4a81-a74f-c26027fe8dca	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Cliente\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	983e37d9-553f-4e9a-a653-ec6bf6efae5f	2026-01-24 13:48:25.499897	\N
d7ea37d4-2f00-474b-8d35-16e424785f1c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	72819cc6-fb9d-45aa-af5f-8347ba849802	2026-01-24 13:48:25.787171	\N
1c478dbc-85d9-4f18-b98d-38479081488d	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	be8dfdda-8b46-4097-94fb-a80ab75d858b	2026-01-24 13:48:25.889824	\N
a2260d8d-40e3-4841-9811-cf0276a29ff1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"password\\":\\"Admin123!\\",\\"email\\":\\"admin@panamatravelhub.com\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	d10541bd-3174-49f2-9afe-1ddb30446b2d	2026-01-24 13:48:26.584035	\N
314dc525-db40-4df2-8ef4-0e494e47039a	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Usuario\\",\\"phone\\":null,\\"lastName\\":\\"Prueba\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	da7ce8fa-53b0-4b11-8509-6c8808cdbf0a	2026-01-24 13:48:26.689942	\N
ff8165af-874e-475f-a69c-2bbea1db8077	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	3c6fe3d8-33e3-406a-8097-996be305dd7a	2026-01-24 14:05:56.751585	\N
b837dc46-2c6e-45df-8916-6bfbd8238169	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"439c3e6a-a3cd-4286-8cf1-79499a04bbc5\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	fb15bffa-3de7-49c3-8b35-42277dc0088d	2026-01-24 14:11:48.819996	\N
b7e1e065-a3c8-4eed-a97d-26930c1fc40a	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"439c3e6a-a3cd-4286-8cf1-79499a04bbc5\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	bba3f9d3-d77f-4528-a776-330c3e128610	2026-01-24 14:11:53.907382	\N
97407269-0b83-4572-919a-b9256fdad2d3	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"5VUfzmKIGECBPujSr+JfiPPaZxp/ONaajNqfNBCt6cc+qun2rf31IugYGtf0lXqkxo52XzMxIi+ak9MfytNYXg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	16b68a32-e37f-45bf-b27f-7ece3352528e	2026-01-24 14:12:08.756998	\N
7ea7a2c6-d11f-49e7-94b5-950d3f8f8011	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	8d90540e-95ac-4731-8a64-b505156a02ac	2026-01-24 14:12:13.643086	\N
7eba4b3f-d744-48da-a33d-719c5debe3b1	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"bZIvimjf+BGlQ9tej474J9turmjBqMV15826oxmUTzsjHrjmvjAqbZNllkv+L4dd7esecXsDj8FxNc+FNZ7yNQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	a68b9a71-030b-4832-bed2-7e7e8d501947	2026-01-24 14:12:16.056244	\N
8efbe0ab-6475-4fad-91a6-70ec6472a847	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"11cb003a-49fa-4055-b327-127d1f1314e7\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	219f04a3-4106-4c8c-8717-caae02eb5125	2026-01-24 14:12:18.629617	\N
f57d441c-0439-4a1a-9a34-e60c6fdb243a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	f1916dac-4d0b-40fb-8eee-20cd18213374	2026-01-24 14:12:39.399067	\N
6acc4104-91db-4af0-a76c-7a9a904d0c55	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"gGoRXL2x+qCUpBtsFOJP8aMhKmBurZMzRE9tBi6VRvbfj4rpmyMuDQo6Xe05rcQ/ULvsSIphM3OtEwI+8nC/UQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	983304fa-a3ab-4d33-b73d-c82febe69e2d	2026-01-24 14:12:45.965026	\N
d630c894-cc93-416d-83ee-b256807317cb	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	9d553939-c2a0-4462-8b95-9b4078efefd1	2026-01-24 14:17:33.624444	\N
dcd54311-60fc-44d2-89ad-d6c1371e10eb	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	414185c6-179b-475d-b373-c1a774e77b43	2026-01-24 14:17:39.652301	\N
205c93f0-8c58-4576-a546-bc970c94878a	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	98517758-b1e0-46b7-9a08-5b08f467d5d6	2026-01-24 14:24:52.424058	\N
fb5cacd1-e8b6-4124-bf60-b12893ccf023	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	c842a3c1-140e-44db-81ba-ccd7d0354387	2026-01-24 14:25:07.629344	\N
15343cc4-5c42-45fb-b22f-703ed022eb22	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	fdbb4c26-e4a5-415b-8ce7-ad8d81e8bf78	2026-01-24 14:25:24.049812	\N
2a01f200-58d9-4043-9e2c-bc6d276e3e7b	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	0fcc5d74-8a77-47c2-9325-fdcc6f34d5bf	2026-01-24 14:25:32.866252	\N
b3599cd9-e926-4ec8-b543-d02cf6cb1e5c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	43b9fe6b-5e51-493a-8685-126bc47db80c	2026-01-26 18:01:18.771712	\N
b5be5704-178e-481c-8ea5-91a703bca252	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"euqUevn5J1RzDvLtGYFibLdJI3urOP1e5WkCNjC6BKWxYY9cDhIgWyBaE/ETcqmqojn5DlH/G+N8lcIk0Nc7rA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	b1014acc-3e35-4c1f-9a6d-881244ff324d	2026-01-26 18:01:56.276842	\N
df66196c-0d32-4ec3-955e-927a2cb48918	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	0e92f8b9-b9ac-455e-80fc-b03109106f26	2026-01-26 18:02:00.580369	\N
0efe4043-e66d-4f04-b6dc-6cca5152b828	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	34011dc7-0565-4744-a2c8-4a442be1178a	2026-01-26 18:02:36.068182	\N
c31f7799-2163-4c77-a795-791311147d53	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	589345dd-0936-4dbd-851e-2e2cbe003103	2026-01-26 18:02:55.600819	\N
ca022ac3-b678-4613-82dd-4caf82b2b297	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	709e5cab-4ac3-473a-9ff1-1b8bc0066887	2026-01-26 18:23:58.945951	\N
3b2f132d-a664-48a5-9e3c-1221be7c3168	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	cd1be402-d37b-4f89-b357-053fb452aad8	2026-01-26 18:24:32.620739	\N
c311c41d-47fc-442a-a156-28c142ecb9ff	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	3f494dce-d6c0-4749-8548-8c303d608c48	2026-01-26 18:24:50.824919	\N
1d375bbe-cc28-4846-832a-b2a062ad83cb	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	381658f2-7855-4cc7-b6f5-ebef58d26197	2026-01-26 18:57:12.228477	\N
4b46009a-4058-4fdb-b570-cf262bee6d7d	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"biTQ2H1fEtP1DEzzxe7Myq2R27mbgmilj6ijYNRFB2qgjzpIgVOehwx515qpmvcTpf+/I4lkGu2KpaW9LYRcVA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	4b33dc13-eaba-420e-ae76-105a7d323b5e	2026-01-26 18:57:43.251546	\N
8b6282c5-85df-42f5-91fe-ef9b9031c4a6	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	aff63d8a-2ffa-4b58-bf9f-4ec7f9d4c165	2026-01-26 18:57:48.508323	\N
e20d73c0-7428-4ee6-9de7-300bf5f53aee	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"MrUXmFHDc5HDBdE7esuIJekOJ+AnB84+XFuudnSyQfNvPDccRTnEBq0xqFa2nzW/2cd5lplNiy1lp3ejXD63vg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	bd075e0c-0e18-4061-baf9-80f72a2d8038	2026-01-26 19:07:21.341234	\N
b5e84711-c045-4498-ae3f-5055754cd38e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	032badf9-0ace-4444-ae68-5de4caf8087c	2026-01-26 19:07:24.87051	\N
96b6024f-26ba-4179-8094-967cc0a33614	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	009647f9-a7b8-48ca-a5a8-23c985fe07f2	2026-01-26 19:24:41.634335	\N
d764a775-0cd2-47ca-9c63-7ce34a2476b3	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	8b90d7a2-5fa7-4301-a00e-4564dbe83a45	2026-01-26 19:39:44.697177	\N
bf3f10ba-a2ac-48bc-acdf-313af86f065a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	69cc7260-6e79-4f37-baf6-f8f00648771c	2026-01-26 19:55:38.206426	\N
2deeab00-f015-45af-85e1-a3da06597eb1	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	53fe8c1b-e97d-41b2-a00f-476a992a7fc8	2026-01-26 20:06:22.304352	\N
576f2ad9-2069-4a78-a1a0-a945fd1de720	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"40a60dfc-c745-4be5-ba5c-62a7cfbda9ba\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	6836cb17-be10-4758-ba1e-c899bd82e892	2026-01-26 20:06:24.683357	\N
66756379-c3a3-4a9d-b75f-343abc4ea2f7	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"wjQlyd6m55Us+dk6RbVX4drxf1NrzFWWZWG/4WIh8e5d1I8jKbLI/Iny4SPiQ8hGg8A/pDyMYZ2enMZKgn9mKA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	72c83667-1ce0-47f5-878a-d35e7dfca609	2026-01-26 20:06:55.497377	\N
24b52820-b5c8-40ac-8234-ba0356159faa	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	60a99c0d-312f-461b-983a-a58948aa6d83	2026-01-26 20:11:08.741827	\N
1a9f5e34-ac64-44d1-8605-d4db59d0529b	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"bZC14cSDqTv2Sy9XiieqA3RQYoDu+yIxjQs9LqOlndZ4eCg89AaG+ihGUOJqGF/vF/CV2jprvOk7vzkEu/uy3Q==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	50822f51-46e1-468a-b923-3b4d1dd55db6	2026-01-26 20:11:16.903108	\N
42ecb185-bcb3-4355-8409-0ce9589d3e48	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	a51cf3d5-9fae-4bc0-84d1-c55580f063b6	2026-01-26 20:11:33.978421	\N
b44c2450-391a-4cc5-a0e8-0e05d60e86a9	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"DQJLB2jjQOJBGxM5gL25hJbAMOwm3BSYNSpASYzdjmas0eVfOGsMlRa/GjkdeJSUgaKgV0G0zlRkjc/RNumoOg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	4bd7bab1-857c-402f-b6c5-f6cb749f0dc0	2026-01-26 20:11:36.279706	\N
188f1acd-ae24-4253-a683-41a99de7e510	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	44706b67-be10-48c0-94a2-20323b6fb34d	2026-01-26 20:11:52.172335	\N
c9ddbdcd-baa3-4c45-9405-f843a7febcba	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"8jF6E2yxBb+Z9ELq4U7HC7TvyLCIZ6QtEXzADvEANZJpAliB6q6uEoBe25O+k6p3GkXpCISpWwxQtYQmtgUWxw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	afbe0e41-5356-4a79-a557-72ea67bc8dea	2026-01-26 20:20:10.67771	\N
3cecefb5-1c7a-4dc3-896b-1bccad4b1c0e	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	37ad7185-654f-485f-ae89-dacdd8390edd	2026-01-26 20:38:12.586247	\N
d9388545-ba85-401a-b6b9-81d880229486	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	6a89b73b-a64e-4083-807c-0e7fbd84349a	2026-01-27 19:36:46.287336	\N
08621f6c-4256-4804-b607-18ba0ce702c6	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"2t003M1gdTPD6zurBEdZB18Qu9x9vJXuvWJvrYkZ9d5SJ8xgD0kS1vA6a3x3U5LFe/qIDv7yptgOEo4jkKy3rw==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	45d8a335-a69e-4dac-b346-1209caca8690	2026-01-27 19:36:50.21974	\N
899eca60-7447-42eb-b21b-63c7c22ef831	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	d0ad10fc-e3df-4c7a-aca9-5f412b1b80d8	2026-01-27 19:36:55.973961	\N
9c02cb93-e02f-4ae1-8fcd-efe06495649d	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	753f48bc-029e-4ef1-b075-62fc08409dc6	2026-01-27 19:36:59.407208	\N
c203c829-b7ec-4a09-824a-16afef7dc4d2	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	6f2f5242-8a1c-413d-bdc7-eea2edebb457	2026-01-27 19:37:00.861597	\N
759c9cf8-9047-47f4-ac91-eb8dd29080ad	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	78d15ab2-7f14-499a-97f9-4952a67e5f96	2026-01-27 19:42:05.993399	\N
c3755ce0-fb5a-4d30-9d69-63cdbb6b7a72	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	40b75e7e-5ee4-4d4a-ada6-4eb907d8e460	2026-01-27 19:42:07.968557	\N
6e142ff8-5bb5-4866-9829-b2ad97abd65a	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2915a2af-f319-4868-9bea-0b242af84f77	2026-01-27 19:42:28.209202	\N
62657060-c66d-40e2-8435-61948537eb54	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	aa2e10b0-f5fd-41ce-9b7a-ae746ea3d3bd	2026-01-27 19:42:39.202699	\N
d6f56c68-6cdf-433d-bec4-835b1de2bea8	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	62de3f7d-2bab-40f6-af5f-8f246bc50dfa	2026-01-27 19:43:14.592772	\N
44097d49-9c10-47cf-8c37-6947b3b0cf91	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	68c7a74b-afdd-4ac4-9dfe-879a624ab526	2026-01-27 19:43:15.989908	\N
9b09ad19-fe1d-41d6-afb7-c4cb10b9ac55	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	12260e8d-f4f2-4566-96ae-d4522631e036	2026-01-27 19:50:28.850211	\N
1d061b68-1f42-4b13-b017-14799ab0b21f	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	75ea0d0a-f71b-4753-bddc-3e9039b759c6	2026-01-27 19:50:30.95782	\N
4aff43d6-74b6-4d50-943a-82a8b7c0cdb2	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	ea6260be-6dfe-4d09-b737-b5b3515b75df	2026-01-27 19:50:39.034372	\N
dadd2158-b3cf-4380-924b-b8ce52b42d7c	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2616892b-99c4-41a0-87f3-fc417cd30556	2026-01-27 20:03:37.14295	\N
c07ac2c9-3233-48ee-9ca7-16c41bb440b6	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	29e0fdad-04cc-4a0f-abe6-8d30b0ad86d3	2026-01-27 20:03:40.392529	\N
5b74695f-43f0-4c6e-af93-78c06926cab2	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	e73deff9-5a0f-4b53-939d-bfa5ecdf0663	2026-01-27 20:03:45.250656	\N
0140cdb1-52d8-4f85-8e93-48c7f1d690de	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	18edb800-e737-4065-a1f6-7ef7532fb046	2026-01-27 20:03:55.144755	\N
def051b7-8a32-44c9-b463-7a0a51f7b693	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	158d08fc-ab95-48e3-9b6f-71b146eeb6d5	2026-01-27 20:08:11.473848	\N
7148e3de-1fd9-4cc6-9481-16a6fe7a3e8c	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	377cebd9-56fd-411d-b725-a8b25aea67ed	2026-01-27 20:09:38.116382	\N
cec98f49-1adb-4ac2-9e6e-9ac773eb79a4	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	aa9ff150-f088-4c95-a05d-6b5c01de352e	2026-01-27 20:09:42.054225	\N
7dced989-ef56-4852-9473-c59e0e12c924	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	55ef8ce2-f6f2-4548-b50d-d3a14091e2b5	2026-01-27 20:15:51.912373	\N
f2d6e071-ea3c-41f6-a4ff-7be388d84b65	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	d2f9e53b-dd62-453d-91d4-b05fa984a6af	2026-01-27 20:23:40.199971	\N
7a99f709-350d-4ca4-b6d4-928dbd531b23	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	a04dc472-aa98-4ac2-b867-d9a62701ab57	2026-01-27 20:23:43.357041	\N
7129a98e-10cb-45f2-be30-be6bc39577bf	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	aaceac45-ba37-46a9-bcf3-9eabe974e902	2026-01-27 20:23:48.288473	\N
fd0860fc-479a-4186-bead-c7bbd26197e6	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	ab09c9f6-bc7c-4619-a88f-b57021024aa8	2026-01-27 20:23:58.883437	\N
8dc923fb-1dec-4394-b1ae-9cf25b957945	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"qBsw/NT/sq5T8nrKKB1ZCAYA7g07dO9oQ/i8FKeqDXgO1JoziIL0Wy01vKQtR6JQtiQiNXSKdMyc30RLCOd6FQ==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	50f6bae0-5e61-43ab-9c06-fc0b93a1570f	2026-01-27 20:25:31.610077	\N
49a2a0d3-ce45-4cba-bb54-99ada2f6258c	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	602349b8-5666-45a9-b4e4-538b4f8a94d5	2026-01-28 14:28:24.027685	\N
e1df2ecf-b3c6-41ab-9cc6-262b3aa2bd63	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"message\\":\\"Ver tours disponibles\\",\\"sessionId\\":\\"chat-1769639416565-prns9jqrs\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	a7cc4b8b-8cd0-469e-bb16-c1bbef123e99	2026-01-28 14:30:16.885612	\N
73556320-8004-4a2b-90c0-b98be614d4d8	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"uMNwki1HD0q3Wtone/cg+CmNWpT7SUdLf5Xx1620td74sGoXE7vp3Lu/b3Hpl+dnxwy5FtKQIqBPejE6LhoFHA==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	be782f8b-e92f-4066-b8dd-d6d9e260f5da	2026-01-28 14:33:01.6102	\N
52c0a9ef-73f8-44ef-965f-e52c52368baf	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	548adbd5-105c-4d7c-8ae5-a3e7102b88d3	2026-01-28 19:18:32.670287	\N
ee83e1a6-5d6c-4375-bb07-3d324d358e9e	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Cliente\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	25a655aa-2cc7-46ec-9575-e5e8a83cf251	2026-01-28 19:18:33.30046	\N
f4c2bc7c-ab0e-4a3a-96a8-b2ae9c7e3ec6	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Admin123!\\",\\r\\n    \\"email\\":  \\"admin@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	7d8a74ce-84e8-4196-8d4d-e01bb673b2c8	2026-01-28 19:18:34.05805	\N
9c03a290-abb8-45a7-99df-89d0449dfcd0	00000000-0000-0000-0000-000000000001	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"tourDateId\\":null,\\"numberOfParticipants\\":1,\\"couponCode\\":null,\\"participants\\":[{\\"email\\":\\"admin@panamatravelhub.com\\",\\"dateOfBirth\\":null,\\"firstName\\":\\"Admin\\",\\"phone\\":null,\\"lastName\\":\\"E2E\\"}],\\"countryId\\":null,\\"tourId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	bec790a3-4ef9-4762-80bd-4537d2cd7a83	2026-01-28 19:18:34.490687	\N
e9ae7275-de08-43e8-b993-d485cdffc7bd	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Cliente123!\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	5248e016-1687-4503-bb67-b8b09a468ba0	2026-01-28 19:18:47.464361	\N
980c254c-8b4c-40b7-9b36-78c068f91941	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Cliente123!\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	d25bdd29-8d2f-4d92-b12e-a027b3f860a8	2026-01-28 19:19:01.282484	\N
195f9de1-b0bf-4444-84f5-b34d6e8b8cc7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Cliente123!\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	7db1b971-37db-42b7-a8e8-aeb269c9ec99	2026-01-28 19:19:16.234336	\N
748942fb-815d-4642-9af6-acc191b9987a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"cliente@panamatravelhub.com\\",\\"password\\":\\"Cliente123!\\"}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	6544ac98-0946-4672-a4ad-d44621263937	2026-01-28 19:27:41.188935	\N
eecc860d-32da-42c3-8aad-29d379326299	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	a5bc3093-12e3-4b4d-9a2b-15868b382872	2026-01-28 19:45:14.630811	\N
a3095536-8670-4c33-a062-4a7401a89b78	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	d881504a-d0b6-462b-9e37-1bd8075ddfd0	2026-01-28 19:45:20.751733	\N
012ea336-17e6-4b52-b3a0-55a958e9e83a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	15d005d8-b0a8-457a-941a-249d84811827	2026-01-28 19:45:32.964412	\N
e45a6043-3b5d-4881-a37d-68ec3df83eca	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	c661af5a-0879-4d13-b4d0-333491828a59	2026-01-28 20:01:00.329995	\N
f276bf1e-aa78-4822-8337-2e678bfd0351	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	58bd6d91-2658-4611-88d6-1ad600888ef1	2026-01-28 20:17:17.757322	\N
7d5d10cb-325b-4d86-a453-3cad8135d960	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	c27e9ee7-b5e0-46ec-90d3-6adc36fcd555	2026-01-28 20:18:52.345429	\N
7d38be39-1a09-4a0a-9a5d-141d4b72c5c8	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	093e7d29-ff68-4fa6-bd7e-c5ec4031e9c4	2026-01-28 20:18:59.376493	\N
b97fb611-5b0a-41a6-9746-497fced04a79	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	5b2996b2-102a-49c0-935d-4b9fd9cb62e4	2026-01-29 17:05:54.959292	\N
a95d6723-14b2-401c-9e7d-2737034e56c7	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	63cdb897-8378-4b97-bc35-930bba3c796b	2026-01-29 17:18:24.214949	\N
89e22826-8fbe-46e8-8b3a-9f71af9437ac	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	84e81041-cf5b-4f04-9ba3-d89f86d0a0fc	2026-01-29 17:18:33.706898	\N
79953f6c-4e64-435d-a821-999821fad532	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	1913b206-b801-4677-9aaa-5acafacc6c21	2026-01-29 17:18:36.024333	\N
18829735-3c3d-410d-a09e-63e9bf3c4e88	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	32371cd1-a586-4965-b06d-c25e84f56190	2026-01-29 17:24:47.602659	\N
54fc3aa9-3391-4a2e-a461-6d45a091ec3e	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	f99fbfa5-4b70-4ac1-96af-0476dfdefa88	2026-01-29 17:24:50.592471	\N
a016ab1f-db85-4505-b96d-1bb07641d4d7	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	f5fee244-b7fa-47d9-8ca0-fa735ae33b6b	2026-01-29 17:27:05.323481	\N
882ff0b9-cbc8-4b38-9243-08a01d888024	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	eba4a6f3-44a8-483d-8eef-96ee28bc46d5	2026-01-29 17:27:08.838333	\N
7feed592-800b-4fea-affa-f229054acb48	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	8402d059-424a-4e50-b9cc-d4cc3099d20f	2026-01-29 17:28:39.721383	\N
e3e05a20-488a-4136-85f5-fe4ec7cf68d1	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	8664e432-ee3a-43bc-b9de-8014b19a6a28	2026-01-29 17:28:47.945098	\N
effb61f7-bc8c-4381-b71f-5e2520a6196a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	9f3b4c6c-fe7c-4247-bc7a-ae4e5cae3b86	2026-01-29 17:28:56.884447	\N
ea83788e-eed2-4477-8c24-dae6745d3ab9	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\r\\n    \\"tourDateId\\":  null,\\r\\n    \\"numberOfParticipants\\":  1,\\r\\n    \\"couponCode\\":  null,\\r\\n    \\"participants\\":  [\\r\\n                         {\\r\\n                             \\"email\\":  \\"cliente@panamatravelhub.com\\",\\r\\n                             \\"dateOfBirth\\":  null,\\r\\n                             \\"firstName\\":  \\"Cliente\\",\\r\\n                             \\"phone\\":  null,\\r\\n                             \\"lastName\\":  \\"QA\\"\\r\\n                         }\\r\\n                     ],\\r\\n    \\"countryId\\":  null,\\r\\n    \\"tourId\\":  \\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	67bd1ec4-6e89-468e-8d97-8a649887b514	2026-01-29 17:28:57.035468	\N
08a202dc-3bfb-4696-a24f-e778634d40b3	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	a54a1c0e-9a93-462b-8ad6-275aec260e0d	2026-01-29 17:29:05.281374	\N
f50c0fa0-22b0-496e-8459-acd583b1bb30	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\r\\n    \\"password\\":  \\"Cliente123!\\",\\r\\n    \\"email\\":  \\"cliente@panamatravelhub.com\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	efec23d2-3ce6-46ba-b82d-60477f34b230	2026-01-29 17:29:20.119352	\N
901a59f4-9097-41e3-8c20-5266180d66e1	6093a936-f8b0-49da-bf2c-16e426df5e69	Booking	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\r\\n    \\"tourDateId\\":  null,\\r\\n    \\"numberOfParticipants\\":  1,\\r\\n    \\"couponCode\\":  null,\\r\\n    \\"participants\\":  [\\r\\n                         {\\r\\n                             \\"email\\":  \\"cliente@panamatravelhub.com\\",\\r\\n                             \\"dateOfBirth\\":  null,\\r\\n                             \\"firstName\\":  \\"Cliente\\",\\r\\n                             \\"phone\\":  null,\\r\\n                             \\"lastName\\":  \\"QA\\"\\r\\n                         }\\r\\n                     ],\\r\\n    \\"countryId\\":  null,\\r\\n    \\"tourId\\":  \\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\"\\r\\n}"}	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	52d79c86-1219-4bab-88f7-91cbd07bd183	2026-01-29 17:29:20.138256	\N
72384492-db78-4b0d-a475-457fe63de3c3	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	3f064639-6fcc-4ab3-88a2-b3d92dc74cd6	2026-01-29 17:35:57.496214	\N
bbb71d40-37af-4c6c-b46d-de85caeaf7e8	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	19664fc6-1cf2-4d66-836e-2dfe0d9e7e32	2026-01-29 17:36:02.450671	\N
509d0dc9-e996-4add-8453-1d9a41b47ca1	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2723ffed-b189-40fe-bb13-3e22dd012e10	2026-01-29 17:36:06.615166	\N
cbef8127-29b6-49a8-9cde-3a07cdee353b	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	9480065d-df50-4378-b83a-a7bb5607b759	2026-01-29 17:36:17.695518	\N
0f41bd82-2505-46d0-8a34-f2073bcf2da3	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	81167b66-292e-4aef-a7d3-a9634fc9cba1	2026-01-29 17:36:18.049292	\N
cb60745b-0e91-4c39-a1b8-ad803166f509	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	d7cd70db-86eb-4bb6-b70c-1f674ba84eea	2026-01-29 17:36:27.668867	\N
5424f40e-f1d0-4aa2-807e-71ecf65ad70a	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	5f76f81a-901a-48cc-9923-b98fa9624fd1	2026-01-29 17:36:35.07222	\N
0442ffb9-8a0b-4ac7-92f1-d0e792f08d84	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	LOGOUT	\N	{"RequestBody": "{\\"refreshToken\\":\\"0lnJjNlQCcm3W1ySsZD1Q/1rWOUP6Z2M8XwFpilTZzXlx6UhxFayUPs3u2IwvvSe4K72I6GHZe1zxteJU21YTg==\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	7a075a2c-7435-49aa-8c49-6b5ba0171418	2026-01-29 17:36:43.597131	\N
57b001ad-9a1d-42db-9772-6a71423d818b	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	b3849bdd-3437-48d6-83d9-1b4566abf0e7	2026-01-29 18:17:58.952726	\N
07f5db57-d415-4a52-b42a-4ad18d42def7	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	d56f200d-df8a-4f31-b654-a42f7ee7ac5a	2026-01-29 18:18:22.402044	\N
3ba9b7d6-e6bf-4751-a2d8-9e1b8d172151	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	598ad9fd-7af0-42d2-80be-f7e7c56eae48	2026-01-29 18:18:26.382347	\N
e3f571fa-d99d-4f53-8410-44630cdd0936	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	37c16e58-1669-4f18-b747-d05e68c0265a	2026-01-29 18:18:36.306298	\N
5db4de28-48af-48a0-8ace-a6109855ee62	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2c190c7a-48f7-4d5f-87b6-17c84453c97c	2026-01-29 18:18:36.613687	\N
4cf13b0f-5a61-488e-a652-c41f3c352896	\N	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	b08536fa-a703-45d2-94ed-49f1f4d1b502	2026-01-29 18:59:20.235983	\N
ac03adf2-3cef-43be-872a-8b1f4b090c7a	\N	Unknown	00000000-0000-0000-0000-000000000000	LOGIN	\N	{"RequestBody": "{\\"email\\":\\"admin@panamatravelhub.com\\",\\"password\\":\\"Admin123!\\"}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	1e9640c8-8274-4eba-bda8-6631cefa6453	2026-01-29 18:59:26.472665	\N
0406808f-08d2-4d46-b4e4-ec8c69019c65	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"tour_viewed\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{\\"tourName\\":\\"Cebaco\\",\\"price\\":23,\\"location\\":\\"Panama\\"}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	1e9dbb8b-05fe-4c3f-bc31-bf35f5e1729d	2026-01-29 19:00:19.256882	\N
2c096b51-34a5-4c67-b8ed-ef33f04a4308	00000000-0000-0000-0000-000000000001	Unknown	00000000-0000-0000-0000-000000000000	CREATE	\N	{"RequestBody": "{\\"event\\":\\"sticky_cta_shown\\",\\"entityType\\":\\"tour\\",\\"entityId\\":\\"29ba9240-93ec-4c61-b0f5-a1bba83bd21b\\",\\"sessionId\\":\\"dd9dc4e0-874e-47b6-8f44-7e56bea119e4\\",\\"metadata\\":{}}"}	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	5aef4f88-1a5d-4630-aba5-4195c381289b	2026-01-29 19:00:31.196928	\N
\.


--
-- Data for Name: blog_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blog_comments ("Id", "BlogPostId", "UserId", "ParentCommentId", "AuthorName", "AuthorEmail", "AuthorWebsite", "Content", "Status", "AdminNotes", "UserIp", "UserAgent", "Likes", "Dislikes", "CreatedAt", "UpdatedAt") FROM stdin;
\.


--
-- Data for Name: booking_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.booking_participants (id, booking_id, first_name, last_name, email, phone, date_of_birth, special_requirements, created_at, updated_at) FROM stdin;
693edd27-e35e-4f31-b95c-a453908d0df1	00000000-0000-0000-0000-000000000000	Irving	Corro Mendoza	irvingcorrosk19@gmail.com	+50765140986	\N	\N	2025-12-26 13:58:05.688899	\N
8f17d678-ba13-4af1-83ba-f4a744a45b34	00000000-0000-0000-0000-000000000000	Irving	Corro Mendoza	icorro@people-inmotion.com	+50765140986	\N	\N	2025-12-26 14:15:31.221132	\N
3d4a255c-15b8-4a5d-8d8d-14b436227ce7	00000000-0000-0000-0000-000000000000	Irving	Corro Mendoza	icorro@people-inmotion.com	+50765140986	\N	\N	2025-12-26 14:20:17.619839	\N
b52aaa8b-7f8c-4eb6-938a-dcffcc59c198	00000000-0000-0000-0000-000000000000	Irving	Corro Mendoza	icorro@people-inmotion.com	+50765140986	\N	\N	2025-12-26 14:29:02.815635	\N
37f9a45e-ebbd-4be2-9742-2aa1469c0162	00000000-0000-0000-0000-000000000000	Irving	Corro Mendoza	icorro@people-inmotion.com	+50765140986	\N	\N	2025-12-26 14:38:34.442484	\N
30f2a9de-772b-4e69-af0c-ad36d81b867f	00000000-0000-0000-0000-000000000000	Irving	Corro Mendoza	icorro@people-inmotion.com	+50765140986	\N	\N	2025-12-26 14:41:36.715069	\N
c2c3f38c-9cd8-4efe-861c-e0b7e9ea899f	00000000-0000-0000-0000-000000000000	Usuario	Prueba	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:28:20.98965	\N
eaff3055-1945-4188-8e1d-023f3f414679	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:32:07.899795	\N
30db6c3b-0c91-41cf-a332-03e49c0a1b38	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:34:20.484753	\N
ec17aaad-0f51-4395-98d0-c04752350084	00000000-0000-0000-0000-000000000000	Cliente	E2E	cliente@panamatravelhub.com	\N	\N	\N	2026-01-24 13:35:23.62127	\N
ad9d04b4-c866-4e0f-840d-371dcb40afed	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:35:24.022077	\N
5d236afa-442e-4fd9-81b0-9119a01fe9ee	00000000-0000-0000-0000-000000000000	Cliente	E2E	cliente@panamatravelhub.com	\N	\N	\N	2026-01-24 13:36:22.896358	\N
93f7dbca-9377-4989-baff-e22a4f5f513e	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:36:23.302705	\N
a2f01b78-8f0f-43e7-b7d1-7b5b422ec522	00000000-0000-0000-0000-000000000000	Cliente	E2E	cliente@panamatravelhub.com	\N	\N	\N	2026-01-24 13:36:52.956207	\N
daabd987-4cd9-4b73-ba1d-ee7932654795	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:36:53.390439	\N
5d18f015-a9d2-4185-bb85-2006b1c6f718	00000000-0000-0000-0000-000000000000	Cliente	E2E	cliente@panamatravelhub.com	\N	\N	\N	2026-01-24 13:45:19.85655	\N
6253b828-85a0-4179-ad84-506d0b7eaef0	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:45:20.295525	\N
065c7522-0f50-434e-90e1-38c2e5366062	00000000-0000-0000-0000-000000000000	Usuario	Prueba	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:45:26.451614	\N
5aacd74b-27c1-4fc2-902a-e5690ca6ffcb	00000000-0000-0000-0000-000000000000	Usuario	Prueba	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:46:10.069817	\N
c45dcfe9-98be-451b-a226-4fbc9af522a2	00000000-0000-0000-0000-000000000000	Cliente	E2E	cliente@panamatravelhub.com	\N	\N	\N	2026-01-24 13:48:25.488159	\N
a9f1c8c5-6664-48de-97a0-7188e870407b	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:48:25.880866	\N
db75ea39-b2bd-4d16-9b51-22e14be85d4d	00000000-0000-0000-0000-000000000000	Usuario	Prueba	admin@panamatravelhub.com	\N	\N	\N	2026-01-24 13:48:26.680924	\N
40427ae8-a164-4a92-a242-1c9a8538608e	00000000-0000-0000-0000-000000000000	Cliente	E2E	cliente@panamatravelhub.com	\N	\N	\N	2026-01-28 19:18:33.190052	\N
c29a8f4e-2f29-4c07-8036-8ee10cb533ed	00000000-0000-0000-0000-000000000000	Admin	E2E	admin@panamatravelhub.com	\N	\N	\N	2026-01-28 19:18:34.476172	\N
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, user_id, tour_id, tour_date_id, status, number_of_participants, total_amount, expires_at, notes, created_at, updated_at, country_id, allow_partial_payments, payment_plan_type) FROM stdin;
c053dbda-c3ff-4f64-8e85-94330d7c974e	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2025-12-27 13:58:05.623375	\N	2025-12-26 13:58:05.624154	\N	550e8400-e29b-41d4-a716-446655440010	f	0
1b760082-5127-4e84-8521-5c767f53a5a7	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2025-12-27 14:15:31.139371	\N	2025-12-26 14:15:31.14018	\N	550e8400-e29b-41d4-a716-446655440016	f	0
f4303a4c-30b4-48d1-ad0e-be2f9ee721f3	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2025-12-27 14:20:17.536758	\N	2025-12-26 14:20:17.537606	\N	550e8400-e29b-41d4-a716-446655440017	f	0
481cd80e-8286-427c-ae10-cc39c5694e92	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2025-12-27 14:29:02.743991	\N	2025-12-26 14:29:02.744822	\N	550e8400-e29b-41d4-a716-446655440002	f	0
dbda33d6-4c7f-45ca-a236-89291e3ec7ec	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2025-12-27 14:38:34.361235	\N	2025-12-26 14:38:34.36209	\N	550e8400-e29b-41d4-a716-446655440002	f	0
11c1cc4c-f53b-4d09-b204-5e3b85190d79	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	2	1	23.00	2025-12-27 14:41:36.641963	\N	2025-12-26 14:41:36.643027	\N	550e8400-e29b-41d4-a716-446655440002	f	0
2e508e19-a69a-4690-a400-7a718469150d	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:28:20.896727	\N	2026-01-24 13:28:20.898081	\N	\N	f	0
4c8a7054-5187-46f6-bf97-d2f85a44b969	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:32:07.898681	\N	2026-01-24 13:32:07.898773	\N	\N	f	0
f0141700-48d2-4f94-9d3c-2d68a2946202	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:34:20.483937	\N	2026-01-24 13:34:20.483942	\N	\N	f	0
05e7be14-89bf-46af-acff-581772530ccb	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:35:23.620401	\N	2026-01-24 13:35:23.620408	\N	\N	f	0
d4138dce-8449-484c-af52-c0dbadeeafd7	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:35:24.021274	\N	2026-01-24 13:35:24.021279	\N	\N	f	0
c37afc81-ff14-47b8-827e-c4ad236110f0	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:36:22.895474	\N	2026-01-24 13:36:22.895479	\N	\N	f	0
976a37f3-4ff1-4102-afb2-6014728b79a1	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:36:23.30199	\N	2026-01-24 13:36:23.301996	\N	\N	f	0
99369256-fa4c-4ed2-ac58-3033c9f7b3f5	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:36:52.955481	\N	2026-01-24 13:36:52.955487	\N	\N	f	0
b2e967b1-3797-461e-bcc6-f14458f60867	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:36:53.389777	\N	2026-01-24 13:36:53.38978	\N	\N	f	0
549a43ea-ecc8-485a-ac2a-59ddc6f73b92	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:45:19.85526	\N	2026-01-24 13:45:19.855264	\N	\N	f	0
c5a38e1a-5f88-4529-8080-a94ad4dc5955	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:45:20.294846	\N	2026-01-24 13:45:20.294849	\N	\N	f	0
2ecf0d34-c3d1-440b-9f76-3db7d0edecc6	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:45:26.450795	\N	2026-01-24 13:45:26.450798	\N	\N	f	0
485d1df6-2996-4c66-84a2-ec94a1c0c5e7	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:46:10.068281	\N	2026-01-24 13:46:10.068286	\N	\N	f	0
7e80be84-809c-40b6-b0f1-59ac8fd3fee4	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:48:25.487327	\N	2026-01-24 13:48:25.487331	\N	\N	f	0
b9ab954c-857f-41c9-ab80-fdfe5a34d8e6	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:48:25.88015	\N	2026-01-24 13:48:25.880156	\N	\N	f	0
02bfcf9e-1cfe-499b-bb21-3bfae01d17e9	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-25 13:48:26.680296	\N	2026-01-24 13:48:26.6803	\N	\N	f	0
d9036a12-ef4b-4f1e-b839-7b35a8cecfc9	6093a936-f8b0-49da-bf2c-16e426df5e69	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-29 19:18:33.090737	\N	2026-01-28 19:18:33.09293	\N	\N	f	0
6f0d7454-3b7b-43ee-a78d-e940d4a227dc	00000000-0000-0000-0000-000000000001	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	\N	1	1	23.00	2026-01-29 19:18:34.47498	\N	2026-01-28 19:18:34.475042	\N	\N	f	0
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.countries (id, code, name, is_active, display_order, created_at, updated_at) FROM stdin;
550e8400-e29b-41d4-a716-446655440001	CR	Costa Rica	t	1	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440002	PA	PanamÃ¡	t	2	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440003	US	Estados Unidos	t	3	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440004	MX	MÃ©xico	t	4	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440005	CO	Colombia	t	5	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440006	GT	Guatemala	t	6	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440007	HN	Honduras	t	7	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440008	NI	Nicaragua	t	8	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440009	SV	El Salvador	t	9	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440010	BZ	Belice	t	10	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440011	CA	CanadÃ¡	t	11	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440012	ES	EspaÃ±a	t	12	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440013	AR	Argentina	t	13	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440014	CL	Chile	t	14	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440015	BR	Brasil	t	15	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440016	PE	PerÃº	t	16	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440017	EC	Ecuador	t	17	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440018	VE	Venezuela	t	18	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440019	UY	Uruguay	t	19	2025-12-25 16:38:08.610707	\N
550e8400-e29b-41d4-a716-446655440020	PY	Paraguay	t	20	2025-12-25 16:38:08.610707	\N
\.


--
-- Data for Name: coupon_usages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coupon_usages (id, coupon_id, user_id, booking_id, discount_amount, original_amount, final_amount, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.coupons (id, code, description, discount_type, discount_value, minimum_purchase_amount, maximum_discount_amount, valid_from, valid_until, max_uses, max_uses_per_user, current_uses, is_active, is_first_time_only, applicable_tour_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.email_notifications (id, user_id, booking_id, type, status, to_email, subject, body, sent_at, retry_count, error_message, scheduled_for, created_at, updated_at) FROM stdin;
6d032a40-c8da-45b5-bbd7-2682ab6d65c8	6093a936-f8b0-49da-bf2c-16e426df5e69	f4303a4c-30b4-48d1-ad0e-be2f9ee721f3	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">f4303a4c-30b4-48d1-ad0e-be2f9ee721f3</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2025-12-26 14:38:24.886453	2025-12-26 14:20:17.743482	2025-12-26 14:38:39.771781
373f8f35-c23c-43ff-be87-88894b6c6156	6093a936-f8b0-49da-bf2c-16e426df5e69	c053dbda-c3ff-4f64-8e85-94330d7c974e	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">c053dbda-c3ff-4f64-8e85-94330d7c974e</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2025-12-26 14:24:52.051901	2025-12-26 13:58:05.811399	2025-12-26 14:28:22.794083
0205f40f-661f-4d0d-a407-42021e322fc2	6093a936-f8b0-49da-bf2c-16e426df5e69	1b760082-5127-4e84-8521-5c767f53a5a7	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">1b760082-5127-4e84-8521-5c767f53a5a7</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2025-12-26 14:38:23.947445	2025-12-26 14:15:31.290579	2025-12-26 14:38:38.820258
ab009ef3-7e83-4186-9733-254d52984edf	6093a936-f8b0-49da-bf2c-16e426df5e69	11c1cc4c-f53b-4d09-b204-5e3b85190d79	3	3	cliente@panamatravelhub.com	Confirmación de Pago - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Pago</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #10b981 0%, #059669 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .payment-info {\r\n            background-color: #f0fdf4;\r\n            border-left: 4px solid #10b981;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .highlight {\r\n            color: #059669;\r\n            font-weight: 600;\r\n            font-size: 18px;\r\n        }\r\n        .success-icon {\r\n            font-size: 48px;\r\n            text-align: center;\r\n            margin: 20px 0;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Pago Confirmado</h1>\r\n        </div>\r\n        <div class="content">\r\n            <div class="success-icon">💳</div>\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>Tu pago ha sido procesado exitosamente.</p>\r\n            \r\n            <div class="payment-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Monto Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Método de Pago:</span>\r\n                    <span class="info-value">Stripe</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">ID de Transacción:</span>\r\n                    <span class="info-value">ch_simulated_01ab6a489ba5418680b2089687478559</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha de Pago:</span>\r\n                    <span class="info-value">26/12/2025 22:41</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Reserva:</span>\r\n                    <span class="info-value">11c1cc4c-f53b-4d09-b204-5e3b85190d79</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p>Tu reserva está ahora <strong>confirmada</strong> y lista para el tour.</p>\r\n            \r\n            <p>Recibirás un email de confirmación con todos los detalles de tu reserva en breve.</p>\r\n            \r\n            <p>Si tienes alguna pregunta sobre tu pago, no dudes en contactarnos.</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-17 13:28:43.640745	2025-12-26 14:41:39.495999	2026-01-24 10:42:52.762877
ae876f6a-041a-4684-9a62-a2d6ad235cd9	6093a936-f8b0-49da-bf2c-16e426df5e69	481cd80e-8286-427c-ae10-cc39c5694e92	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">481cd80e-8286-427c-ae10-cc39c5694e92</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2025-12-26 14:46:07.529696	2025-12-26 14:29:02.884358	2026-01-17 13:18:40.57533
594f8a69-a35a-4fde-976b-82eb4c54d1b7	6093a936-f8b0-49da-bf2c-16e426df5e69	dbda33d6-4c7f-45ca-a236-89291e3ec7ec	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">dbda33d6-4c7f-45ca-a236-89291e3ec7ec</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-17 13:28:41.835448	2025-12-26 14:38:34.525284	2026-01-24 10:42:50.840855
2cb6fc25-e197-48c5-9ef8-4530137090c5	6093a936-f8b0-49da-bf2c-16e426df5e69	11c1cc4c-f53b-4d09-b204-5e3b85190d79	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">11c1cc4c-f53b-4d09-b204-5e3b85190d79</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-17 13:28:42.804535	2025-12-26 14:41:36.824876	2026-01-24 10:42:51.870848
d505399f-9980-4440-862a-1d881083da18	6093a936-f8b0-49da-bf2c-16e426df5e69	11c1cc4c-f53b-4d09-b204-5e3b85190d79	1	3	cliente@panamatravelhub.com	Reserva Confirmada - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">11c1cc4c-f53b-4d09-b204-5e3b85190d79</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2025 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-17 13:28:44.564452	2025-12-26 14:41:39.522851	2026-01-24 10:42:53.666716
23e463ae-a60b-4f19-b7fc-7b4ff03fb69a	00000000-0000-0000-0000-000000000001	2e508e19-a69a-4690-a400-7a718469150d	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">2e508e19-a69a-4690-a400-7a718469150d</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:43:44.769918	2026-01-24 13:28:21.060893	2026-01-24 13:43:57.627733
108d62e0-1fff-49be-88d4-301407ed14e0	6093a936-f8b0-49da-bf2c-16e426df5e69	05e7be14-89bf-46af-acff-581772530ccb	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">05e7be14-89bf-46af-acff-581772530ccb</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:50:53.01706	2026-01-24 13:35:23.628508	2026-01-24 13:51:07.696725
b390716f-0a0a-42bf-bef0-c4af769247e3	00000000-0000-0000-0000-000000000001	f0141700-48d2-4f94-9d3c-2d68a2946202	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">f0141700-48d2-4f94-9d3c-2d68a2946202</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:49:52.246994	2026-01-24 13:34:20.49181	2026-01-24 13:50:04.643375
53515025-df10-4b51-a7e7-24c0660b54e0	00000000-0000-0000-0000-000000000001	4c8a7054-5187-46f6-bf97-d2f85a44b969	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">4c8a7054-5187-46f6-bf97-d2f85a44b969</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:47:19.828004	2026-01-24 13:32:07.908748	2026-01-24 13:47:31.497411
db64ebec-c717-495b-b2f5-ae5360d0fd76	00000000-0000-0000-0000-000000000001	d4138dce-8449-484c-af52-c0dbadeeafd7	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">d4138dce-8449-484c-af52-c0dbadeeafd7</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:50:53.758044	2026-01-24 13:35:24.028249	2026-01-24 13:51:08.490408
9f5aad85-f803-4155-9a06-03da5754d3b5	6093a936-f8b0-49da-bf2c-16e426df5e69	c37afc81-ff14-47b8-827e-c4ad236110f0	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">c37afc81-ff14-47b8-827e-c4ad236110f0</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:51:54.503316	2026-01-24 13:36:22.903942	2026-01-24 13:52:09.961805
d2e2ab6c-5fb6-4e23-873f-03ff94ce7154	00000000-0000-0000-0000-000000000001	976a37f3-4ff1-4102-afb2-6014728b79a1	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">976a37f3-4ff1-4102-afb2-6014728b79a1</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:51:55.300312	2026-01-24 13:36:23.308891	2026-01-24 13:52:10.729648
dd2fbe0b-6ffc-40ad-a563-b0dc60b7a297	6093a936-f8b0-49da-bf2c-16e426df5e69	99369256-fa4c-4ed2-ac58-3033c9f7b3f5	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">99369256-fa4c-4ed2-ac58-3033c9f7b3f5</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:52:26.073303	2026-01-24 13:36:52.962407	2026-01-24 13:52:41.529919
4f4913dd-8625-4bcf-a2b5-907e28e792d9	00000000-0000-0000-0000-000000000001	c5a38e1a-5f88-4529-8080-a94ad4dc5955	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">c5a38e1a-5f88-4529-8080-a94ad4dc5955</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:00:36.14221	2026-01-24 13:45:20.302289	2026-01-24 14:05:03.47407
26926f14-2dec-4f5e-9a81-f67b51df7149	00000000-0000-0000-0000-000000000001	2ecf0d34-c3d1-440b-9f76-3db7d0edecc6	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">2ecf0d34-c3d1-440b-9f76-3db7d0edecc6</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:00:36.942511	2026-01-24 13:45:26.458231	2026-01-24 14:05:03.529254
dd7ba056-409c-416e-8303-6c56ac9c7434	00000000-0000-0000-0000-000000000001	b2e967b1-3797-461e-bcc6-f14458f60867	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">b2e967b1-3797-461e-bcc6-f14458f60867</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 13:52:26.825854	2026-01-24 13:36:53.396369	2026-01-24 13:52:42.264566
e769ab7b-dcb0-4511-99d6-05cc9ca0ea6b	6093a936-f8b0-49da-bf2c-16e426df5e69	7e80be84-809c-40b6-b0f1-59ac8fd3fee4	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">7e80be84-809c-40b6-b0f1-59ac8fd3fee4</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:06:11.849429	2026-01-24 13:48:25.495136	2026-01-24 14:09:09.749983
778c41cf-00fe-4d62-a8d4-cd4a19b3bad7	00000000-0000-0000-0000-000000000001	485d1df6-2996-4c66-84a2-ec94a1c0c5e7	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">485d1df6-2996-4c66-84a2-ec94a1c0c5e7</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:01:39.220454	2026-01-24 13:46:10.078445	2026-01-24 14:05:03.608755
bb5d54f5-891e-4d69-9166-b6eab9c88bd2	6093a936-f8b0-49da-bf2c-16e426df5e69	549a43ea-ecc8-485a-ac2a-59ddc6f73b92	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">549a43ea-ecc8-485a-ac2a-59ddc6f73b92</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:00:35.433518	2026-01-24 13:45:19.866774	2026-01-24 14:05:03.33148
a2af3a36-6b34-48b6-8e9f-114af9079309	00000000-0000-0000-0000-000000000001	b9ab954c-857f-41c9-ab80-fdfe5a34d8e6	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">b9ab954c-857f-41c9-ab80-fdfe5a34d8e6</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:06:12.801409	2026-01-24 13:48:25.886775	2026-01-24 14:09:09.922366
53c74150-78fa-4523-b117-2afb584cfa89	00000000-0000-0000-0000-000000000001	02bfcf9e-1cfe-499b-bb21-3bfae01d17e9	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">02bfcf9e-1cfe-499b-bb21-3bfae01d17e9</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-24 14:06:13.59163	2026-01-24 13:48:26.68701	2026-01-24 14:09:09.964484
4b674dfd-1cd4-47e1-8ca3-d98081031372	00000000-0000-0000-0000-000000000001	6f0d7454-3b7b-43ee-a78d-e940d4a227dc	1	3	admin@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>Admin System</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">6f0d7454-3b7b-43ee-a78d-e940d4a227dc</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-28 19:34:03.32413	2026-01-28 19:18:34.48466	2026-01-28 19:34:03.691508
c034b45f-6ed7-41a6-8acd-83f375bde577	6093a936-f8b0-49da-bf2c-16e426df5e69	d9036a12-ef4b-4f1e-b839-7b35a8cecfc9	1	3	cliente@panamatravelhub.com	Confirmación de Reserva - Cebaco	<!DOCTYPE html>\r\n<html lang="es">\r\n<head>\r\n    <meta charset="UTF-8">\r\n    <meta name="viewport" content="width=device-width, initial-scale=1.0">\r\n    <title>Confirmación de Reserva</title>\r\n    <style>\r\n        body {\r\n            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;\r\n            line-height: 1.6;\r\n            color: #333;\r\n            margin: 0;\r\n            padding: 0;\r\n            background-color: #f4f4f4;\r\n        }\r\n        .email-container {\r\n            max-width: 600px;\r\n            margin: 0 auto;\r\n            background-color: #ffffff;\r\n            box-shadow: 0 2px 4px rgba(0,0,0,0.1);\r\n        }\r\n        .header {\r\n            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);\r\n            color: white;\r\n            padding: 30px 20px;\r\n            text-align: center;\r\n        }\r\n        .header h1 {\r\n            margin: 0;\r\n            font-size: 28px;\r\n            font-weight: 600;\r\n        }\r\n        .content {\r\n            padding: 30px 20px;\r\n        }\r\n        .booking-info {\r\n            background-color: #f9fafb;\r\n            border-left: 4px solid #2563eb;\r\n            padding: 20px;\r\n            margin: 20px 0;\r\n            border-radius: 4px;\r\n        }\r\n        .info-row {\r\n            display: flex;\r\n            justify-content: space-between;\r\n            padding: 10px 0;\r\n            border-bottom: 1px solid #e5e7eb;\r\n        }\r\n        .info-row:last-child {\r\n            border-bottom: none;\r\n        }\r\n        .info-label {\r\n            font-weight: 600;\r\n            color: #6b7280;\r\n        }\r\n        .info-value {\r\n            color: #111827;\r\n            text-align: right;\r\n        }\r\n        .button {\r\n            display: inline-block;\r\n            padding: 12px 30px;\r\n            background-color: #2563eb;\r\n            color: white;\r\n            text-decoration: none;\r\n            border-radius: 6px;\r\n            margin: 20px 0;\r\n            font-weight: 600;\r\n        }\r\n        .footer {\r\n            background-color: #f9fafb;\r\n            padding: 20px;\r\n            text-align: center;\r\n            color: #6b7280;\r\n            font-size: 12px;\r\n        }\r\n        .footer a {\r\n            color: #2563eb;\r\n            text-decoration: none;\r\n        }\r\n        .highlight {\r\n            color: #2563eb;\r\n            font-weight: 600;\r\n        }\r\n    </style>\r\n</head>\r\n<body>\r\n    <div class="email-container">\r\n        <div class="header">\r\n            <h1>✅ Reserva Confirmada</h1>\r\n        </div>\r\n        <div class="content">\r\n            <p>Hola <strong>irving corro</strong>,</p>\r\n            <p>¡Gracias por tu reserva! Tu tour ha sido confirmado exitosamente.</p>\r\n            \r\n            <div class="booking-info">\r\n                <div class="info-row">\r\n                    <span class="info-label">Tour:</span>\r\n                    <span class="info-value"><strong>Cebaco</strong></span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Fecha y Hora:</span>\r\n                    <span class="info-value">Por confirmar</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Participantes:</span>\r\n                    <span class="info-value">1</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Total Pagado:</span>\r\n                    <span class="info-value highlight">$23.00</span>\r\n                </div>\r\n                <div class="info-row">\r\n                    <span class="info-label">Número de Reserva:</span>\r\n                    <span class="info-value">d9036a12-ef4b-4f1e-b839-7b35a8cecfc9</span>\r\n                </div>\r\n            </div>\r\n\r\n            <p><strong>Próximos pasos:</strong></p>\r\n            <ul>\r\n                <li>Recibirás un recordatorio 24 horas antes del tour</li>\r\n                <li>Llega 15 minutos antes de la hora programada</li>\r\n                <li>Trae una identificación válida</li>\r\n            </ul>\r\n\r\n            <p>Si tienes alguna pregunta, no dudes en contactarnos.</p>\r\n            \r\n            <p>¡Esperamos que disfrutes tu experiencia en Panamá!</p>\r\n            \r\n            <p>Saludos,<br>\r\n            <strong>El equipo de Panama Travel Hub</strong></p>\r\n        </div>\r\n        <div class="footer">\r\n            <p>&copy; 2026 Panama Travel Hub. Todos los derechos reservados.</p>\r\n            <p>Este es un email automático, por favor no respondas a este mensaje.</p>\r\n        </div>\r\n    </div>\r\n</body>\r\n</html>\r\n\r\n	\N	3	Error al enviar email	2026-01-28 19:34:03.320174	2026-01-28 19:18:33.266971	2026-01-28 19:34:03.687716
\.


--
-- Data for Name: email_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.email_settings (id, smtp_host, smtp_port, smtp_username, smtp_password, from_address, from_name, enable_ssl, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: home_page_content; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.home_page_content (id, hero_title, hero_subtitle, hero_search_placeholder, hero_search_button, tours_section_title, tours_section_subtitle, loading_tours_text, error_loading_tours_text, no_tours_found_text, footer_brand_text, footer_description, footer_copyright, nav_brand_text, nav_tours_link, nav_bookings_link, nav_login_link, nav_logout_button, page_title, meta_description, created_at, updated_at, logo_url, favicon_url, logo_url_social, hero_image_url) FROM stdin;
293baed3-de72-41ec-bd62-e9ce183d2391	AloticoPTY									Tours	Tu plataforma de confianza para descubrir Tours	@2026 AloticoPTY.com	Tours	Tours	Mis reservas	Iniciar sesión	Cerrar sesión			2025-12-25 07:04:26.964582	2025-12-26 13:52:42.740192	\N	\N	\N	/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg
\.


--
-- Data for Name: invoice_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoice_sequences (year, current_value) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoices (id, invoice_number, booking_id, user_id, currency, subtotal, discount, taxes, total, language, issued_at, pdf_url, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: login_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.login_history (id, user_id, ip_address, user_agent, is_successful, failure_reason, location, "UserId1", created_at, updated_at) FROM stdin;
21f4fd7c-2ca5-41c9-8cc1-3fadc0c73a04	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 11:51:34.389292-08	\N
d0db3a1c-93f2-4bed-ad46-7043a3b6229f	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 11:52:11.678402-08	\N
eb94828b-676e-4700-83dc-05821bf751cb	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 11:52:49.55118-08	\N
1fccb029-013a-411c-815e-9c9fab56693e	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 11:53:15.023437-08	\N
3d320e45-dbac-46d3-ab02-681cbf8a7ae3	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 11:53:33.608301-08	\N
86b20875-4203-4ed0-ab11-3eeca522b801	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 12:11:18.874429-08	\N
88b44f5f-f4b0-4640-ac29-7eaa62871412	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 12:36:01.972286-08	\N
d7556de3-409e-455b-9cf1-19a4a27febdb	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:15:32.398244-08	\N
87278d71-246e-40c4-a757-636ecad4ded9	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:19:47.659982-08	\N
c4c3a1e5-09fe-480b-9c54-1a7fdbc562e5	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:22:26.169774-08	\N
2aeaa405-8c32-4266-85f4-9da6de838d11	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:23:04.928686-08	\N
32b662b0-3fa8-4be1-bd08-a70d619da1ed	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:28:20.663253-08	\N
b9a1c54b-c8bb-46bb-85ae-9d6c11bc7016	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 13:32:07.235879-08	\N
3e790572-01fa-4c9a-a814-84226e82c0cf	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:32:07.533105-08	\N
289f049d-6b14-4594-8177-08b83e46e0a6	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 13:32:54.774763-08	\N
71c26362-de77-4851-bc88-442a02c7ec7f	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 13:34:19.364873-08	\N
5a8b740e-713c-4eea-b2ba-fcddb999b606	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	f	Password incorrecto	\N	\N	2026-01-24 13:34:19.627024-08	\N
128ca144-d09d-4bfe-917f-ae7396632109	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:34:20.351707-08	\N
5afe46f4-bfb2-439a-b230-b17a8298d587	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:35:23.513048-08	\N
9c99ab90-87d7-4266-bd18-99d4f616be09	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:35:23.920774-08	\N
93e2bbd7-40f6-4268-a168-ee2816c4db38	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:36:22.794779-08	\N
13e6d84c-9fad-446e-8bd2-ba3006dee08d	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:36:23.205635-08	\N
759805e4-94b3-4093-b658-13d32a063c30	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:36:52.860641-08	\N
be2a1d5f-2b11-49a0-aaa0-676776284c2c	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:36:53.301297-08	\N
0352ac6f-a7ac-4b27-be52-3d644c73e32c	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:45:19.724874-08	\N
f93dd099-a839-4ee2-9919-81b331a7a459	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:45:20.178145-08	\N
901aa8c3-3ef4-4c5d-a8c7-023ba53d7e45	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:45:26.342264-08	\N
fdaa9411-5301-40d1-b088-49ebb55374a1	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:46:09.956311-08	\N
4eb3f12e-dc1e-4dde-a300-8ab669248941	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:48:25.379615-08	\N
f9408e8a-1e4a-4210-a23e-b2f2cf22d674	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:48:25.77999-08	\N
d707352e-24df-419a-9825-f9fbbc628a5e	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-24 13:48:26.577047-08	\N
0614a6e7-2ad4-46e7-8b41-f5e87bb89e9f	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 14:05:56.530238-08	\N
75f2185e-1fd9-4d2f-bd59-99374e8e3a9b	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 14:12:13.502556-08	\N
ecbf081f-184d-41b5-93fd-e73dd482d5d0	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 14:12:39.31522-08	\N
d7903086-4196-47e7-8831-f43aa867a23a	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 14:25:23.808108-08	\N
8f1a1b9c-6d32-4297-ae29-0c7c896caff3	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-24 14:25:32.790012-08	\N
35301cb3-ac24-4b0e-94f8-62cd4478f287	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 18:01:18.595779-08	\N
6c51a3d5-0984-466a-a541-4ceaa7e4314f	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 18:02:00.524678-08	\N
2531f529-a208-40f9-828a-f5d93f05b14a	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 18:23:58.534935-08	\N
0d8bc299-f672-4d2d-b8c2-a3a5acb559d9	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 18:57:11.979172-08	\N
d82d822e-be67-4c39-9ede-983a48f1843b	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 18:57:48.416747-08	\N
fdd989cd-9d3e-4f5f-af99-712b9405e8fa	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 19:07:24.728874-08	\N
44207d27-3029-45dc-8b3b-2a31141cfacc	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 19:24:41.476535-08	\N
89b759c5-495a-4680-b498-24bd8f5b7307	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 19:39:44.528794-08	\N
b55c1e7a-fdd9-41d2-bf41-8b4abbd1a6c3	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 19:55:38.035946-08	\N
28b28d40-de76-4850-a543-f7cb2102767a	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 20:11:08.537757-08	\N
5c332c19-7e7e-439b-aac8-24e582f2b159	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 20:11:33.921797-08	\N
a279d6ea-08cc-467a-948f-3aed0488a4e1	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 20:11:52.113188-08	\N
bc301fba-d231-4c43-9f2d-e86aee37362f	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-26 20:38:12.312026-08	\N
9d8b35c6-0504-4bf6-95f1-339e81c58c32	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-27 19:36:46.081272-08	\N
81585e3b-6c44-4d09-b78c-832f9cea9d62	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-27 19:36:55.891107-08	\N
aa2be9fd-4083-4992-969c-613c79b24553	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-27 20:03:40.264073-08	\N
75987bd0-9845-4688-bf88-0de376e4a8c1	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-27 20:23:43.218236-08	\N
88076be9-a0bb-4ac2-adef-6a21e59d8c1a	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-28 14:28:23.757189-08	\N
f7cffe1c-0553-4f9c-afc5-c2b84f82cf34	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-28 19:18:32.507473-08	\N
9f108f49-903a-4f73-b49e-1d4a3818e192	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-28 19:18:34.045775-08	\N
dbbe0297-c854-40a5-b590-abefccb0b986	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-28 19:18:47.454631-08	\N
eab3b6fa-408f-46a6-8509-339c97212890	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-28 19:19:01.267702-08	\N
540fa3f9-80f2-43ab-8e9d-868bd0e10c19	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-28 19:19:16.227052-08	\N
7abb4a3b-0c9b-4a0f-8617-d7eeb0df5b28	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-28 19:27:41.175425-08	\N
6e3cc482-7917-4800-9bfb-2a070afdb32d	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-28 19:45:32.791848-08	\N
fa407b97-815c-4a1b-91de-cb05c3d69eaf	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-28 20:01:00.132113-08	\N
57ad7d0d-b74b-41d6-a221-d5fd07ae9da6	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-28 20:17:17.542865-08	\N
2f6af068-2abd-490d-b091-3edc6565aa88	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-29 17:05:54.727605-08	\N
1a01ae36-a417-49d1-a909-731373c85790	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-29 17:18:23.99079-08	\N
7c2fda90-6144-4818-8eba-6e2292ef3416	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-29 17:28:39.620986-08	\N
d0f49ca8-69e4-40da-b8cf-e07e2afde639	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-29 17:28:47.933914-08	\N
6579bfcc-ef6b-40c6-af2d-1aac5233a4d8	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-29 17:28:56.874635-08	\N
ae5055d6-552c-4e60-b4ff-f2e2de2f5aaf	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-29 17:29:05.272897-08	\N
c626401e-9407-4a98-a3c4-bfb89fa0f7aa	6093a936-f8b0-49da-bf2c-16e426df5e69	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	t	\N	\N	\N	2026-01-29 17:29:20.111188-08	\N
e6b08113-9de3-4517-b0ed-d849a564f161	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-29 17:35:57.194119-08	\N
001323a0-7b36-4794-a860-fdfe8a953f14	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-29 18:17:58.67048-08	\N
4909bf46-64d7-45be-a025-e33a75173c8f	00000000-0000-0000-0000-000000000001	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	t	\N	\N	\N	2026-01-29 18:59:26.32429-08	\N
\.


--
-- Data for Name: media_files; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.media_files (id, file_name, file_path, file_url, mime_type, file_size, alt_text, description, category, is_image, width, height, uploaded_by, created_at, updated_at) FROM stdin;
8fce7383-117c-41b4-bd4f-1c7cb7a81f8d	Firefly_Gemini Flash_coloca la imagen de referencia en el vaso bien profesional  785326.png	C:\\Proyectos\\PanamaTravelHub\\PanamaTravelHub\\src\\PanamaTravelHub.API\\wwwroot\\uploads\\media\\b6d97804-e2bc-4ad1-8dda-9a65aa422fc8.png	/uploads/media/b6d97804-e2bc-4ad1-8dda-9a65aa422fc8.png	image/png	1428621	\N	\N	cms	t	\N	\N	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2025-12-25 16:12:51.228884	\N
5c3c9e05-5c27-4cdb-ad65-90454604e124	Firefly_Gemini Flash_sanataclos orefiendo helados el pequenio igloo usq, las imagenes de referencia 785326.png	C:\\Proyectos\\PanamaTravelHub\\PanamaTravelHub\\src\\PanamaTravelHub.API\\wwwroot\\uploads\\media\\e42444c1-ad63-4475-9895-4dadd82aa922.png	/uploads/media/e42444c1-ad63-4475-9895-4dadd82aa922.png	image/png	1480776	\N	\N	cms	t	\N	\N	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2025-12-25 16:13:04.296208	\N
aced37e8-5fe5-4738-a794-d12f11f8d91c	WhatsApp Image 2025-11-29 at 8.43.11 AM.jpeg	C:\\Proyectos\\PanamaTravelHub\\PanamaTravelHub\\src\\PanamaTravelHub.API\\wwwroot\\uploads\\media\\f0b22f29-d65b-4aef-8768-9dcbc3482bb3.jpeg	/uploads/media/f0b22f29-d65b-4aef-8768-9dcbc3482bb3.jpeg	image/jpeg	313763	\N	\N	cms	t	\N	\N	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2025-12-25 18:16:13.316404	\N
0fa7f4eb-0813-46ef-973a-28c459e2cd04	WhatsApp Image 2025-11-29 at 8.43.11 AM.jpeg	C:\\Proyectos\\PanamaTravelHub\\PanamaTravelHub\\src\\PanamaTravelHub.API\\wwwroot\\uploads\\media\\183bc447-353a-4109-bafa-d2c3cca501eb.jpeg	/uploads/media/183bc447-353a-4109-bafa-d2c3cca501eb.jpeg	image/jpeg	313763	\N	\N	cms	t	\N	\N	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2025-12-25 18:16:32.310627	\N
81903f5a-9136-4007-a89e-96c8257a0956	WhatsApp Image 2025-11-29 at 8.43.11 AM.jpeg	C:\\Proyectos\\PanamaTravelHub\\PanamaTravelHub\\src\\PanamaTravelHub.API\\wwwroot\\uploads\\media\\663184e9-1d96-4a30-bb56-ffa09284dcd5.jpeg	/uploads/media/663184e9-1d96-4a30-bb56-ffa09284dcd5.jpeg	image/jpeg	313763	\N	\N	cms	t	\N	\N	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2025-12-25 18:24:43.427309	\N
e8dc3318-4cfb-4271-b756-3ff6aa856552	WhatsApp Image 2025-11-29 at 8.43.11 AM.jpeg	C:\\Proyectos\\PanamaTravelHub\\PanamaTravelHub\\src\\PanamaTravelHub.API\\wwwroot\\uploads\\media\\254d4445-92cd-477f-860f-235460265361.jpeg	/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg	image/jpeg	313763	\N	\N	cms	t	\N	\N	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2025-12-25 18:36:19.874559	\N
\.


--
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pages (id, title, slug, content, excerpt, meta_title, meta_description, meta_keywords, is_published, published_at, template, display_order, created_by, updated_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_tokens (id, user_id, token, expires_at, is_used, used_at, ip_address, user_agent, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, provider, status, amount, provider_transaction_id, provider_payment_intent_id, currency, authorized_at, captured_at, refunded_at, failure_reason, metadata, created_at, updated_at, is_partial, installment_number, total_installments, parent_payment_id) FROM stdin;
784b64ce-70f1-47fd-86ec-1dd8331674ae	481cd80e-8286-427c-ae10-cc39c5694e92	1	1	23.00	\N	pi_simulated_a06993a572954710ada8ea6c1a366da0	USD	\N	\N	\N	\N	\N	2025-12-26 14:29:03.596199	\N	f	\N	\N	\N
58c582d7-4280-4840-a5fb-e1b4555f18b7	dbda33d6-4c7f-45ca-a236-89291e3ec7ec	1	1	23.00	\N	pi_simulated_80dd194bc84b43ee8b4e2cdc401d6119	USD	\N	\N	\N	\N	\N	2025-12-26 14:38:35.260751	\N	f	\N	\N	\N
82c45dc6-0cb3-4635-a4fc-7331eb31f08f	11c1cc4c-f53b-4d09-b204-5e3b85190d79	1	3	23.00	ch_simulated_01ab6a489ba5418680b2089687478559	pi_simulated_7897f32e26fd4de799bed05721bbf48c	USD	\N	2025-12-26 14:41:39.462129	\N	\N	\N	2025-12-26 14:41:37.55638	\N	f	\N	\N	\N
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.refresh_tokens (id, user_id, token, expires_at, is_revoked, revoked_at, replaced_by_token, ip_address, user_agent, created_at, updated_at) FROM stdin;
fe182f12-b035-489a-a11f-6fcdf53c92bc	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	cLRrTS+lKVdruS6GpRXquXB4LJXH1X3VETcPUHSZIy5ryXKmlwlTNfaJ5rrzf5RNwckcRFAJgJjZaYmEwZE9Yw==	2026-01-01 03:48:56.463247	t	2025-12-25 03:53:21.973152	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 03:48:56.531996	\N
3ebbce0a-0d73-4090-a3e6-7016df51bd3a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	+YMuOYYxKi4OXJQw+G9ZHTGEhrhmVR7lu/mgN4UFL1Uam5Ts6LpuSH0bXkLQs3qd9cMNRHIf8oLrv4/AXaCjYQ==	2026-01-01 03:53:22.169022	t	2025-12-25 03:56:14.552043	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 03:53:22.205713	\N
e2739ead-feec-4afb-b864-0e4f5adde9b8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Dh9Z5clYEkjLCL1TNzlaTFcH/7RMqh078Ad3qDFcwTiulaumQl00OuIHZb28TU42EMwytT8XuJLJgSm5EbC17A==	2026-01-01 03:56:14.720513	t	2025-12-25 03:57:53.164715	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 03:56:14.754575	\N
43d4670e-aecc-4eb9-971d-b0aeb0fa8129	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Ew56jwZOWP37FRI3ho/JofQ2ntPaZYXNappF1ijt4qBDAz16TaA5br56WRCfFL7sqnNwQCGOSSRROpsN0QOY4g==	2026-01-01 03:57:53.20612	t	2025-12-25 04:04:40.854711	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 03:57:53.207966	\N
44b6115a-4a9c-4964-91d6-86e85763a8df	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	/Ez1K0rG0/z9BXmxasKNlvSDDNJzPKZIeclY748GZ2FhzM9IcuHC+JhVTe2920+Bfn6g3QnPgcE51A2OCJ0DpQ==	2026-01-01 04:04:41.041919	t	2025-12-25 04:09:33.61796	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:04:41.077667	\N
81749595-265a-4573-8f39-e6c770bf23c2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2nY3a3/iUcxSdoDE5wdKJo9EiCW1SA1SEeFJyRjtTCcGurFF0mTQeYvZaE/0EZ6TP+zY3/Shyi3OwYdcpxgE2w==	2026-01-01 04:09:33.818559	t	2025-12-25 04:10:53.394114	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:09:33.858983	\N
0f794f6a-c683-4bfb-a76d-47d71f92b176	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	9thF5dztz9it4GhhkMNTw8jWoQhab9ghHjG3J25VDZ/AJsehRVsiAuscsT2c22K1KnOmSe06l+3L+Y0d8gNJPw==	2026-01-01 04:10:53.451966	t	2025-12-25 04:14:13.126401	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:10:53.454019	\N
3d3d8111-c2e6-4b61-9744-5b60b29a452f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	V44iOE3S3vxP01ziaOCNqDY2JbOmrALJqAycOPHxQfUP+qiTpZqXpORtIQbv1yXI8ujErFWx6ePR03zrXE36RA==	2026-01-01 04:19:53.534657	t	2025-12-25 04:21:40.485033	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:19:53.590006	\N
2d5318dd-b512-4b5f-a9a7-4406b7636d8a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	LcQWgsXWif1yf9hP2O331b4mg9N3sSZqO5p+itvxRUeiuxnZBZNWk5UzdH+eaKB4opwjOJFo19v5mgWUC6RLEQ==	2026-01-01 04:21:43.248829	t	2025-12-25 04:22:11.992131	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:21:43.251164	\N
45437fd9-5483-4b82-88e6-40e8e9d03941	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	ego1jPrsRwnBuvvTg6/5MzALLrgahb8pmz7r9O5UU6U9TCAKXDVmfygQqmIhgVXc6TZNHe5VTN9F+zyLXJpD8w==	2026-01-01 04:23:17.833993	t	2025-12-25 04:25:40.076168	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:23:17.834965	\N
f84b2c3d-7258-4295-a791-babc57be7b1d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Nstmk7ZAY2/We/kvAmzlOUCqE4vlfwgvbLzEaaXGcQVqLjqeFXtZQiojjHKjsI3kDIjDREijviOgzQXgvH2kZA==	2026-01-01 04:25:42.363898	t	2025-12-25 04:39:26.553196	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:25:42.399302	\N
e4193ccf-4d08-4f02-a966-d8fb05be1073	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	m2C531Tn7BF6Jqbhz3fYgMhwKdupXDTsKTYJKjp+/p6uRXSqYl5RfktCSoVUbDQbf3Aqre2dA9l/VkWDBs/Xew==	2026-01-01 04:39:28.432271	t	2025-12-25 04:40:00.306016	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:39:28.469348	\N
8530bea1-438b-45b5-8122-a9dfe0de10e7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	p0DzhstnIzdyEgFgmQFW5Bh+ZjnzdCMHKLi77gquDmLpDOlaSb2Qg0Gt3YKsp44+oVuHcWNGSxan2LJhAt6h5w==	2026-01-01 04:40:00.548354	t	2025-12-25 04:43:48.667553	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:40:00.550228	\N
12376a2a-c970-44f1-b98d-d21016913bc8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	uLLxc0grNtYAAVKJmanE6iQ+wu3ITcDlAuClxgumkRA34I/NxG5S8c+RL/jq7cvOLtC7mB1elB5v8cjSyVyiTg==	2026-01-01 04:43:48.876315	t	2025-12-25 04:46:28.336182	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:43:48.913146	\N
d203e35c-397d-4032-917b-fdb35f83a625	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	TeytiCvnBnCJKDtGStFhhIWNCNBxQbgKq3h6M9Dmvnj5Mf59BPlh3+Ti8/E/3iV4jiKs9VcBQ/d4c0zYUQipKg==	2026-01-01 04:46:28.536363	t	2025-12-25 04:48:46.698078	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:46:28.570912	\N
d13007b0-e53a-46e9-ade6-c17f972ce01d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	jCV6z0wVhMJ+WhDWbJxGNPa7GlpdUkvhQyDzClxJH6oTrjhH3jY8J04n9xZxuGgKDrobACVNOgrcyzzEW/vYkw==	2026-01-01 04:48:46.933653	t	2025-12-25 04:55:18.057192	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:48:46.978174	\N
c5d113d2-6cc4-4c4c-9463-b6a5ec0f6ac1	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	ZNBspY7vYH719o6MgnNvHOlFXkstPjKtGfhNgP7vyXysRt+IqgfzC747Yx2dUaDd46cvyuJvuv3J/EAnb8IEsQ==	2026-01-01 04:55:18.254722	t	2025-12-25 05:05:08.883832	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 04:55:18.291021	\N
c67a5b8d-5660-4d59-bdb5-5404932d0316	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	t/V1cr/EWX/DSFoPzoZu8mrmCCAdDe0kh+gYbDzRYy1MJBrBrVn4EzJ4L6gCHBiE0l7Fbz78MnHaRBbYEKE35g==	2026-01-01 05:05:09.08154	t	2025-12-25 05:06:40.697515	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:05:09.11832	\N
ece5cbc7-2368-4ce8-bd2a-70f62dc16eb2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	qhd2vWU4Thn8Io6qb5qcLoAoq/k322EDTSfxDhaGtqYzrB4HojRMyrou7UP+YcWZx0M3HQ7/sAnYJFZNd/1qlQ==	2026-01-01 05:06:40.755633	t	2025-12-25 05:09:57.068109	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:06:40.757219	\N
2d0b292d-8707-43af-b46d-2341b931f3a9	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	12NSlBft7vft74AcC2chTIgV93u5WCwZ16b/phCyfuqsbFw2sn6QquP5Q2l8t5WkZZrVBzi66rnjYlCQ13mU0g==	2026-01-01 05:09:57.251176	t	2025-12-25 05:15:23.323756	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:09:57.289018	\N
33e4e3d7-e2ae-4f7a-92a1-4532e49cf50d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Jxt9ruYdAQH+9yp5HLzeL2DFEdctkkFfcpF5DZ7yDrLIR4wBQFU3Fcu1Zj9aN/nhL/Z6F1/NzzsqDLcSFXKcQg==	2026-01-01 05:15:23.516562	t	2025-12-25 05:20:37.980446	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:15:23.56325	\N
47fd1243-399b-4db0-9312-0412d6cfcad6	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Kwe5rsWQkIvi3gYwwkwODubzqV6KTjreYnFbc3yBF5InujeJbDwEttbxtXonLxWg2lAZnaL42cCb3ilsMKNY4Q==	2026-01-01 05:20:38.180823	t	2025-12-25 05:22:56.862373	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:20:38.220172	\N
5142a0eb-2c06-4076-89c4-0cfccaf20fad	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	+TWotV8bSBdfivdzPz25iTNpu2G13CSfPKbKNGgAacCyT67FtJFAR2RJxaWWnnRbZ4DvgOU4sPPqidEzfP47tg==	2026-01-01 05:22:57.229022	t	2025-12-25 05:30:33.886164	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:22:57.2916	\N
88ff9e37-3629-4283-87e9-4161c223c836	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	MwZp2l/udgFOXjrh6lgPn3riIPBZxFmZJ9+xMIlO+zpCEUD3Tn3dgA5LvJbG5M+ajk3pFJE+sBC1W0Fk3YFUDA==	2026-01-01 05:30:34.096872	t	2025-12-25 05:34:37.433327	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:30:34.135837	\N
bb97e1c9-fbab-4e19-aa4c-c5cb55b7a7c5	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	mPA/gsDpZ1qzE3YVwcMGTJdyxgvTXZ8pFTTE1ZdcgPJWH+STiy4hKmT4sccvj0mHfu17IAk1Ixmte5Z9aBRKKQ==	2026-01-01 05:34:37.6836	t	2025-12-25 05:41:35.603548	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:34:37.718922	\N
8bd738eb-b845-43a4-bfa3-696bd96e1705	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	+n6BeAt0Iz0aGkB1tlp+CS7JI+XqLX09qNunjvZ/iuxzV7vHgyktVqGVZi+7QHxg3edjQ/L0J3J1eETgiEw5cQ==	2026-01-01 05:41:35.874484	t	2025-12-25 05:43:33.335576	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:41:35.910435	\N
704aaf2e-59a5-4f97-a184-7c0571b9efd2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Or8hoOyD34rAiUCwSpQ+N7Rsh3H5mcNo2vM4uIZAi38wbQroAIv+pmEph6Lj9YmlhdJKpz8c9Z38wtoKT7KFHA==	2026-01-01 05:43:33.60446	t	2025-12-25 05:47:07.860452	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:43:33.639066	\N
21dbed60-ad22-4485-b0e8-1f2856f7cb7c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	74+UtWHxhf1d5KwVR9yOudtc35zsmR5SUVNtz6Ez7H+iKw63GaEfmjGv7Fu/bIqabz9f52J5vx8fxZTGzxibMg==	2026-01-01 05:47:08.127296	t	2025-12-25 05:57:01.531834	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:47:08.163378	\N
c211f710-86fa-4216-a9a8-5cba17bd1527	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	vggu94HvFdKunHkYoyWVsKgKZ3KgVW9exJHuiUAo1snJ46Pu/pGa7wKdlzcOoHM52xrhfzsxaEcKYFlwHQGS1A==	2026-01-01 05:57:01.981788	t	2025-12-25 06:00:16.499121	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 05:57:02.01733	\N
0a357269-5d55-4558-ab1d-30da7ea672ce	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	PhdCNkmzGdhD43ot4qXwcH1RkD8BSUyFGT7eN8JB7LPmhCBq2Kdgo7sQEWjL1iIGxoUWT92sxdLeFXbvAY34Bg==	2026-01-01 06:00:16.848115	t	2025-12-25 06:02:21.805742	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:00:16.884415	\N
f020e3a0-5a83-4e86-bea4-f60874c2a041	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	7wmCaY3l91hcKe+JCLieb3tY1DiHPcAX3ux75yOyYblZeqWXLbHOx+34gFmVb6VsJX1uOV4SBS8mkCzlPnVG6g==	2026-01-01 06:02:22.155745	t	2025-12-25 06:02:26.710621	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:02:22.191359	\N
222eabcf-f131-41bf-9e88-81f96f7d472a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	2+gD+GcLI/KL65ruvgz3rP9HDj2j3+y8VGKZqrvfcpdV8fud7OXEWsg7TjE44NkIm6tUC1NOBOGbmvMp/tFOSA==	2026-01-01 06:02:26.960676	t	2025-12-25 06:03:00.342055	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:02:26.962364	\N
5a2843fd-fb15-469a-9c93-fbb2267762d2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	sEKmj1SGtWSL2pq7V3jYYjFI0hKjkZiE8wHoXzxS3useCrIHZMaRoI2BBk3vPAbtk2aAzXNqJwf/5dHRVUPHTg==	2026-01-01 06:03:00.564665	t	2025-12-25 06:03:03.430959	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:03:00.565511	\N
22093f89-0bb0-49e8-89e2-59c01383b32c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	GgdBvH8a2c1AYTFJq5gviJNiC29yk7RmfKTTy/0QvWgkppqQVOxLHtrX99cRRUb7Wr74PdiXUfGZAFdcrq/Jww==	2026-01-01 06:03:03.687354	t	2025-12-25 06:14:08.866321	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:03:03.688175	\N
5d8b402f-507e-4acf-ab89-62bab78593fd	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	1zC7RtVzuv93oShvkiovINZr4Y0vLHL84gIQlKRUiabQoins6AWSIHueI0T5UwPM9t8NhpRJYX4Mus4m+lSZDg==	2026-01-01 06:14:09.200458	t	2025-12-25 06:14:13.970254	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:14:09.235667	\N
52d0be85-ad24-4b12-878b-45a94bdccde3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	8QE8Z1hw6AnSXmjAL92qvWvtWTseFdohjdzmBhp+CNhPZgmztJiZamS31+qcVaqTosYF4RPRIbKHH80VZgGOXg==	2026-01-01 06:14:14.175098	t	2025-12-25 06:15:58.390355	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:14:14.176544	\N
3ff71793-7f57-4d84-a911-1c84bb047942	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	oSuQe2c8kXBbl/ksiCgUW4DUV5Oe74LJi3Eb2CKSLgC3zrtQk2Xmxysrg474rM2JAomkBhZosVSJ2CYoZ9cP8A==	2026-01-01 06:15:58.726663	t	2025-12-25 06:19:57.250422	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:15:58.759722	\N
cd05c449-cfb5-4b0a-ad15-70162d7965a0	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	c3bw6to2RoLOvHmGjPDhaBbowLUVtNQjgLIWki1rCDuko/i+l3+JizvqNLrFJYDfPW1h/1MuI2kAvkNOBfElpA==	2026-01-01 06:19:57.580462	t	2025-12-25 06:31:43.467391	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:19:57.615401	\N
d7062c25-f571-40fe-9257-2014f12e50b8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	G1TaKrynkMW9GJJ5V4NDlIcPakosAXeKCLM842DlwF5CCUjecpN+w+hDSX1qFiOJqyLtB5wdgU1IHTmK7sj07g==	2026-01-01 06:31:43.664729	t	2025-12-25 06:33:38.941053	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:31:43.698788	\N
1c4fb65f-a742-4669-a6e3-9e16062f32b8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Vxhn6KwAwJKpyN3l2vHeV5s5iiE0CnkuMwsrq4cBS6wRJkxkAPM3dTsaAEwNQJtpwr9LU9xGGjdmPzpP2F7XEg==	2026-01-01 06:33:39.161366	t	2025-12-25 06:34:21.084589	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:33:39.207917	\N
52ec7e6d-b6d8-4a9b-80eb-4b4c9bb78c87	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	0NGlYK8IdjHS1Obsx7WlPVemAjitYBAHG7xU13dxExjesoe5fFAIK+HhE2nSVQ7coA4CmUY9XlBIUSGpLYfwNA==	2026-01-01 06:34:21.276679	t	2025-12-25 06:37:49.478529	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:34:21.315821	\N
c456127f-82fa-45a8-8d72-8fa7c71e3e60	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	1Jjlr0o3UwQMuuWqN8Pk0L0UjOKT+Q2U4+cNytdWNghbzHVWchyj2y5Bg9AtPuiR2cdqXFDCFdj4gXT8eN+p9g==	2026-01-01 06:37:49.68021	t	2025-12-25 06:42:06.843255	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:37:49.716453	\N
89b94a34-8ab3-4c4e-bc12-59ca29172931	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	DuCxl6VZA6eiEPt6qGj6BKAOsNYDscKB4R4Jfst7SZQHTPfzI7SuHz06cbBsV8n2718idz5sL3LTMXJkbKVktw==	2026-01-01 06:42:07.05265	t	2025-12-25 06:46:21.693076	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:42:07.085965	\N
7149691a-d24a-446f-87bf-70c995d05577	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	6oDZ7+7v9fWOCRa5wvmGToAmXKCbsPJ457zZZ3eMPZcpQUsuZUcza+AYrSLSczONVzNGlRA/ODT4yxaCFnW1LA==	2026-01-01 06:46:21.889618	t	2025-12-25 07:04:22.032024	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 06:46:21.928468	\N
b890ab78-148b-44b6-a7e5-4209aab89480	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	QkWSJyKav/nA2csaHC9Tvt0/Fc3YJoOgtEEF0cwskzMwOpj2iH28OdD7Y8iQx5XfiAbidRKL1n6HcGbKwArWiA==	2026-01-01 07:04:22.202673	t	2025-12-25 07:13:05.651457	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 07:04:22.237066	\N
9e54b645-1f21-47cd-9109-5302eac7b71b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	QuWUF5wPEpdQmS06910QVD+IQ9EOZyjDTNc4/Jj/6V/d8Mk+6tYnF4cgijX4QnZsk5itEvXNvhu+DLadHInUVg==	2026-01-01 07:13:09.201597	t	2025-12-25 07:15:48.075414	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 07:13:09.216487	\N
d88f1aa3-71cd-42dd-9c78-87daa1bc83c7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	VALeAuJQJl3/OAx02NeAPRTy6hljE3fCidX33NFtX1OTE/8IEKazJXEklWr8jWvaIuBfM/glQzwKuPbapD48GA==	2026-01-01 07:15:53.697463	t	2025-12-25 07:19:46.096043	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 07:15:53.698297	\N
514b6ba6-d070-4a05-8701-cb4831bc04f8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	A1OyszIKMlLT6SKLyO7NMrdnTSzcmp/vVRmdfU20XEQthfkg9ny4eVY7khRIj4V1gsfXPS+yZRkcxTir0popiA==	2026-01-01 07:37:49.761401	t	2025-12-25 09:07:45.54811	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 07:37:49.837695	\N
b086298a-3d21-4d3f-b72f-ed941b1c0495	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	sVw+7D0F3Oc2oZOagqDYWj+Pa1m/kR0NNoX4RUyeZ9bmh8BzmWEITLoTC69ntl6F8MlCu3MdJV/2nNDaoO9Wzw==	2026-01-01 09:07:45.778469	t	2025-12-25 09:24:31.093321	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 09:07:45.818694	\N
b3c2efd6-c80a-43e7-b4a9-94a04aeec783	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	EwxzuiTjY9ugvP41a0+C0BFc+a3/DxoajOUb9eMOPnQq2InBfkJk0wnU3Lx+oK0UQUnObkMDirSsRkth4K9R4w==	2026-01-01 09:24:31.40951	t	2025-12-25 15:40:04.62907	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 09:24:31.447755	\N
8cd2d65b-906b-403c-98ce-2ef37c475a5a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	u5Sv+UwAw2fjkyMHkVeOxFh5mfNNe/dIr2S2PUQS/l59i9hYiPLDs5MjApPNnzwGzfy7uGQLHiCmhKXswm91gA==	2026-01-01 15:40:04.814031	t	2025-12-25 15:56:24.897681	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 15:40:04.850596	\N
52cb2b25-3bd9-4b69-a362-458ea46ed5dc	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	a5U+u402+5tkUkZGjCiJ7+9t/NkF7YkK7UmAmKT8T/hNDga7fPCzH6TOBtnl/krMwgOIN54CTBwicwPByK4aNg==	2026-01-01 15:56:25.200112	t	2025-12-25 16:02:14.8493	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 15:56:25.236407	\N
99a23a48-cf2b-4734-8066-f09c342392cb	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	RYrwALeFkJcaRoY9i9VDr4cMfi0NgzU7fDcaM9GtyhXmsLv8s2FvY6sPNqzX3fYUjx/FihucU7mtRbZUwwkCaA==	2026-01-01 16:02:20.878596	t	2025-12-25 16:06:57.07483	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:02:20.894275	\N
80a23820-2538-4671-b899-87401e3a80a1	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	c2NoKAkutZQV6vhwUptWAkQoArppNGWry1RYrpiVPJ9lKYhj9XJh9udCvs7udray4aRUXcnOI4ACcAp0jK9MXA==	2026-01-01 16:07:03.216166	t	2025-12-25 16:08:24.85122	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:07:03.231805	\N
7aa2dc28-965a-406d-95dd-27110a65612b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	qPeNerdPgQ/gSM4+EEOuws76Nblx4hlfoU10gDk5RfYOxayofiFp5LecQX/xcd7gSFiUXmJUd5UwQ9SGvm2jWA==	2026-01-01 16:11:43.858333	t	2025-12-25 16:24:48.719991	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:11:43.96411	\N
038a2ab0-aef0-4f5b-a01c-9b53686e9871	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	+uaWS+DIK7gpZWOA7IMEmfkTe3Bq8LJu7FNKY/pIvrFYctGZbYhYExO+YwxPH8/5TPxvxRvIWw7T11QSgY9C4g==	2026-01-01 16:42:57.570389	t	2025-12-25 16:46:44.396647	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:42:57.627241	\N
a6767435-7af9-4ca6-8a4b-6b9690e5ce0b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	cQoKptj3tCbUV2JVsrl1qZWiLF3AFO+RXhphq9l00cl/3S/pE9+JHe9sluGAZAQg4qR5/nsSYxX/WIHaZE2KJA==	2026-01-01 16:24:57.242079	t	2025-12-25 16:36:54.939498	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:24:57.256072	\N
60e95d04-c75a-4b27-8879-3bb0f54f9259	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	yijU23lcP5367pXKROlJcsCLHEpORaoiHK9CFD/7gZQg4QcxZJAdBF/R8lh7tx/qnkaJlROCYB7peDAPLKeT9Q==	2026-01-01 16:36:59.022023	t	2025-12-25 16:39:47.580131	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:36:59.036377	\N
f39dfb48-2519-4705-89e0-f739e8ba6634	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	r4Nyd3Ju87nUJXIeuW1UNdeW8cNXYLADORM8HriF/LoQbFCC0B7IjQ3/O3h4MPuo2P0ihLL9S3yM7YY6Tv/0KA==	2026-01-01 16:39:51.610027	t	2025-12-25 16:41:38.342615	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:39:51.624982	\N
f81cb3d4-d54a-4092-aa24-1335814da612	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	SSPvEuLqkoLNIrnoYflyIRVHdrJrH0xZhMfnxJDZhV5KLdQGh6f/gWvTXaoVlgQJc4VF7U76dQ+mLN3ZUklQpQ==	2026-01-01 17:06:03.408688	t	2025-12-25 17:09:17.71747	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:06:03.422792	\N
5e49c3bc-5a64-4a44-a4f0-fd0dcc780ed7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	u0iHgpb5cDVAO6gjHm3s1EZOxszBqLm59Viimm2Pc+DKblblBwdTP/fFc2TkxgRCGA2EFc0+mwXLozo1OpdmAA==	2026-01-01 16:46:47.495013	t	2025-12-25 16:49:30.135685	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:46:47.516629	\N
4aa454d3-e892-4b50-a2ec-0e831009a10c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	iLqAWRUScqJkXymr79O/OUEIWjkq40TqIUBWEEQJ9AljstsvRNlgZxFZX7m1hknGXdRiNyUFcM2KjursCCTd+w==	2026-01-01 16:49:36.719315	t	2025-12-25 16:53:29.916027	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:49:36.735372	\N
62c901db-33fb-4774-84e0-e275bd1e4729	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	uv5AJ+pnEK7iKoHpHKtVWAsebHoozCsziFYS2WxuKSol5senn970ytF6HcKeyjKynAhG76IojJGMk7FTMbrCpw==	2026-01-01 16:53:33.09599	t	2025-12-25 16:59:47.558428	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:53:33.109816	\N
c4f09d77-271b-458b-af51-9e4f5e1c21c8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	aUFvd4QQyp7u+iTPwMiVLbTqaXno6np5LSH5/SliIcoJtned8IP+P5Zta98MnA6rO8MgXBqP7FWirVgxUJGiog==	2026-01-01 16:59:57.714189	t	2025-12-25 17:05:32.719795	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 16:59:57.727223	\N
6a1e5b91-e8c5-478d-80d6-31c406b65b41	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	SX5VD136odk1QcHmkpSfMg0Z4HA8ZfwOf86hBoYLmxUE0PFcEQ/Dd6nioNM5BMZGNFFNpKE2GZOaovgLtyXUFQ==	2026-01-01 17:09:24.262234	t	2025-12-25 17:09:45.820651	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:09:24.277157	\N
27109061-b5c3-40b7-9b79-da84cee93388	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	JYmGED0Vd9nsApEiLHDa/bNwb6uWtPH0SMpyHZplTeSRFbYfnOqeFK99MtjZ9dxd+EYS9JAcpfAdR5Mviuk2kw==	2026-01-01 17:17:21.822169	t	2025-12-25 17:23:52.36924	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:17:21.837265	\N
777cb779-ba88-4a58-b447-c63c711f3fcd	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	OK3b2jTARaSo7lugaxA3t4QZEBwsrzR5ZGzSM+TRcqipP00Ca/EP4qY/ktFRhNZP3pSYuY+WWfyPARdRE6m2ag==	2026-01-01 17:09:48.89189	t	2025-12-25 17:17:18.329701	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:09:48.89328	\N
d965dce8-8938-4089-abb0-362a1591f804	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	WiijtW3ZQYfxro7ighy4feHtjQ3AHnPH0nKYjJ+SIRfFmvwBcrTuWMlnEDCZH1lY2Nm1ON/D7T4Gi1YNDFnORw==	2026-01-01 17:28:52.336323	t	2025-12-25 17:29:49.159813	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:28:52.351238	\N
232d4001-74b3-4dd1-8242-7f5d5c45b9a7	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	DRaHwE6fGMGuyIHi3sZvJo6JcW5SkFE2gQc7eTN5Ztmtuw0tZCjJXvYwdx6t9X60vdZ/yszP45V+7ecKbg8k2Q==	2026-01-01 17:24:07.796128	t	2025-12-25 17:26:41.711914	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:24:07.810619	\N
69e3559a-bc3b-425f-93a8-20ae5225a35d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	0kamo/iEPNzgzuKvnXRDtC8wwBpwGWtUobdFvJSLbtgI8siAU6o3Qk7osfMTD5vX7M549gytyHizQ/PkMFsvSg==	2026-01-01 17:26:44.850921	t	2025-12-25 17:28:48.725779	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:26:44.866141	\N
01bc7829-19b5-4f8d-9fda-68980399921a	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	0Kzbvgkmrp0dsQafB8BGyc8wmZeOHb+YEIzhNWXHak4Tzjop0i54lJVohGwhI7C1XP1UxqfDOIQTlx1/M6sf9g==	2026-01-01 17:33:15.162267	t	2025-12-25 17:37:32.062652	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:33:15.237103	\N
16616d78-cf65-4bdf-9cab-5a31cad5d911	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	FThxZ2UJqZEjPYhhRl4E3nwNgyU+37cithqIUaFhBrdYD83sWLHVU19dFS7rvlj3z8xUeFvt+Vp4/n/QXm4rWg==	2026-01-01 17:37:39.349022	t	2025-12-25 17:49:41.497945	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:37:39.361846	\N
f8ae804e-c45e-417f-8a6a-eb0e82ecc74b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Dqas8nA9k0TVRAK2h+W3GLtvtyyIAoEE6lS1nU25a4hqLEMsxwf/HoTxY3fYzRfKM63ya5hU6A/OszOFwxjjRA==	2026-01-01 17:49:45.854576	t	2025-12-25 17:54:34.81125	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:49:45.869779	\N
aa17bed9-8643-4a89-ac9b-b2db96e9dc6d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Sc7bs7sGB87jBbtT4Y9N/alwPY3qUMewq8dzlryvt5+K9CgiWWAFdTPuG0uRiM1a+mxATBS7/B0p8cfQ4HyHfA==	2026-01-01 17:54:38.733633	t	2025-12-25 17:55:30.162756	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:54:38.749045	\N
ad4d88e7-72e5-4413-bc50-31c49ef42db9	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	EvWQlIjOv49lxlFLcZDApZSoQ6DZ1FcaEEIc3th8K7Or6WpmkeU8jut9SOfNXMHD+RHmYnGAqxWE3vpCUp8ltg==	2026-01-01 17:56:06.224342	t	2025-12-25 17:56:42.887423	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:56:06.22518	\N
984ec696-35f2-4d9d-b9bb-59a57382a671	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Y+flu6KsH88WVCIMUT/s3iY89kaoTXcLFeIu76n9Cuz+38za+WJvhfJ8gRgbUzGM5/wXRh86NtptZo4peV2/Sg==	2026-01-01 17:56:42.950426	t	2025-12-25 17:57:02.440485	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:56:42.951376	\N
438d5944-1e24-48f4-b510-008ef0a4490f	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	amohzuLsyJuQiTrEI38uahRIdE+OzPsVPP0bp3Y97Ynbox24vNZBMbUdQe0sOjvaMEeTGHqZq28bRXN30m+CQw==	2026-01-01 17:57:25.802258	t	2025-12-25 18:08:11.095556	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 17:57:25.803033	\N
93f2b33b-e7fc-4612-9242-cab6d83a36a8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	P604JDZ+YSJs66gRxqJpt+gZ2OLH35PsfECk2yRbJyphPF4vOlTV6k2hqYRgJSxP6FuYuvsPtnf+47KIpl/g5Q==	2026-01-01 18:08:11.275613	t	2025-12-25 18:15:01.887857	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:08:11.314034	\N
05093b11-bacf-469c-aa61-fba3ab9bdfe3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	woxGg9HKQnPMw2vJc5b2oLOzh/qsnAJCOYpszDSFg4YNcCd9tkFU/sFfs5s14zUCXVGJ0lqG4uGHitcUwflISg==	2026-01-01 18:15:02.063348	t	2025-12-25 18:15:53.280222	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:15:02.099762	\N
41c48b00-e04e-40ea-acf2-a2dceab21c5d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	qaL/sXuGwErWjWe8J7DKh88rnRAf9R99e414gc3fe+T4iep5/Jzwcy9H16NRIkmwDIujtqJl3V3EaD4PGAPGlA==	2026-01-01 18:15:55.608852	t	2025-12-25 18:24:25.213808	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:15:55.609747	\N
a4fd82fd-02cd-4c1e-b3d4-e58ce6883b43	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Hi51ovHVPelKyu1TzeTMu0aitJCqgwl9x+zgbUb5pw4wlaY5E9NiTy83a2vUkgNuAfFM6KcRM8kHR4EzYQ1eNg==	2026-01-01 18:35:37.590309	t	2025-12-25 18:37:10.711207	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:35:37.604341	\N
def39d0d-593c-4723-8d96-84bf35fc9735	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	DJDzB8oYHrsNmc5PxnV/t+LLh2pffWItryIE/3tjJskin4XfuSeXrZxba/u1rgHAk25xZzPINoQ0f9xnWYPGKA==	2026-01-01 18:24:25.410204	t	2025-12-25 18:28:58.782998	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:24:25.451138	\N
7f9df5d5-89cb-4680-b0f0-2fdc9c1cdd14	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	B/PC4URpfSvItzsPkXnNsZ/TNfRL9/sjRfVRYnrP0IveNbEXbxReqhiPOM2MNURt7ZXIzAOFX2Md1veFEvXHnA==	2026-01-01 18:29:02.316463	t	2025-12-25 18:35:31.731926	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:29:02.31744	\N
7be9aad6-a741-4bdf-9330-ba8807cef3f2	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	4P9FRa9jKmwY7aPZtm3JUJbN9BCCZKZqqGLddz3QfDRnu9p7aT8jHkzHFdB30fmj28HRkWonWqi41J+3josmvg==	2026-01-01 18:37:15.083215	t	2025-12-25 18:45:18.105681	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:37:15.084219	\N
3e0d4028-6ee7-4273-99b7-d116cb642716	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	0VnOYD5SWIYKa+VLyM8yIxhxoHf8ydTACORnrA2Kt0hCmdiD4S/2lAGqfELL4THtUYFczU0gOGb5Llyc+yO+FA==	2026-01-02 02:55:29.103115	t	2025-12-26 02:55:57.184508	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 02:55:29.165498	\N
80b41dbb-337a-405f-9100-a583cf0a645c	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	ISAfIb7KuEqgFSoX6tojtzSCb0/T5L+GqKtlrZcgna5ptysZLDmP2dp1LC742QSpjrZqbcKGrl+C1sDGKtBXsg==	2026-01-01 18:45:21.456816	t	2025-12-25 18:52:25.057474	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:45:21.472464	\N
0d35e694-e82b-47ba-8e33-062c66cc8b90	44261c54-dd97-4858-b686-a0076e3943e6	KuRTTj0IRhNZDhJ0gmOkOBua+PN5YJv6SyiWVhJ4nfiVUdKn8TaYtQ/7jzjNmNWXSva2/jomgh0/1QkoyZFFXg==	2026-01-01 18:59:26.873185	t	2025-12-26 02:56:31.498105	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:59:26.875153	\N
d41de2bf-922d-40db-8bbb-05e3f8ee35fc	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	GqzuirteapJF/lWUtr9zncqYrikrdGBw30PlkwhddMz8S0OTPCRczBmiZO3GVVf/QplTY618XAcFF0rBxBUFGw==	2026-01-01 18:52:29.41545	t	2025-12-25 18:53:32.673678	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:52:29.429922	\N
ae6fcb8b-4c8c-45f1-ad58-ad96307a02a8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	VGhoNmX48elxH3KIHKFGK3U318iEXEFVwt8FLNHVkSHZXp2Srn3n52/Gx6HLTybQb5U5vEBtOoGbkMaPvg3TQw==	2026-01-01 18:53:35.971887	t	2025-12-25 18:53:47.518035	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:53:35.972998	\N
14c8b8d2-1d62-4666-8d6c-e1afae980ab6	41c7ace7-2509-4407-8fe5-eab7745754a7	vn5x5zmHTeCosqRdE+yd3t68XPQI45xD+Bym7+HLAixYsVAT4W8HgaTklxMZpnyVGb2blwJiKT2qv1H2SRkG2Q==	2026-01-01 18:59:01.285923	f	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 18:59:01.326739	\N
16100250-ddf6-45de-ba5d-c936301804a0	44261c54-dd97-4858-b686-a0076e3943e6	/1Cz+rgRVLrlsE6+8Qvl656xWiW9Js+3gnlJBuTTqebchqUMVDJotkYaQqBb67UPvZfL7aQ7d8EO+kO8r0ZeUQ==	2026-01-02 02:56:31.631687	t	2025-12-26 03:07:30.050658	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 02:56:31.632866	\N
67c2fb79-c8d6-4026-8f35-c5e574e525e1	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	aJ/1SvfhfmZ/85uzgJ8DzWGLMJZuiqkQAszmlXRaEVi1U5ctZe0uU385+PeQg48gkJOZvf2kN7kELkbLy3wQPg==	2026-01-02 02:57:26.110867	t	2025-12-26 03:06:58.712123	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 02:57:26.112023	\N
89b35ee0-f286-4640-a565-096fd57b3b7e	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	zUpcckgkOIMT5XhTjTlaRL4PA3pRM7MRSyTGD8JhjGnHw1l4+s3R4rUIbKb4+Kfp4n99jW/tJyAlXJtk0DzoCQ==	2026-01-02 03:08:35.123518	t	2025-12-26 03:12:24.938968	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 03:08:35.124531	\N
af91c51d-4c42-4250-83d5-a2ae2e944ff3	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	K1gDhPeaRIQ9f723jXIMRJxB+UcwpBgfF9vZxk6UUTcQIktb1m9blVvvAFZPin2BQJTnYDkNqhYpjxfPmrLBmA==	2026-01-02 03:12:28.413813	t	2025-12-26 03:13:13.598941	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 03:12:28.437098	\N
4e67e8ca-ec90-49bb-9a6e-698e44fe5539	44261c54-dd97-4858-b686-a0076e3943e6	XbI7gRl3wj3phu3O6BSWBepMdfH/2Yjp6VMPI8gXGUnQZTqFM17/QmATKUdy+0VuS/NlDi8IDX9HuBV+OYyDDA==	2026-01-02 03:07:30.148192	t	2025-12-26 03:15:25.526378	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 03:07:30.162247	\N
7b4b4ceb-1d06-49fa-a78d-7456fe3e0f45	44261c54-dd97-4858-b686-a0076e3943e6	TEAFQIffitURsA0VOfhmBAnZick3Xu1ht3PeiWTIHHho32Vb13THIXxFLOZKIdG7fJ5GeD+NMq0wTxPvyIXIEg==	2026-01-02 03:15:25.755933	f	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 03:15:25.801172	\N
88782dfb-d2db-44a5-95f9-dcc7ebd89950	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	oAfN7+oH2y4awxD3Zl4aEBiyy0X40x986PKW1RREMsedYSOWLWQcXVMmYd4bnTH9bHzC2DUObHqXE+CrDNnM7w==	2026-01-02 05:44:25.491312	t	2025-12-26 05:58:28.012805	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 05:44:25.561072	\N
b99b40ed-a1a8-4288-bed4-e8c98b49259d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	+nHkgYSV8XSdk5qR9iyX0DAG7LOLjhwEV8Yr6xnkE9ucfH4vxdcJVhZyFns8RHoDvddVGRfkI3KD0jCnrAZ4XA==	2026-01-02 05:58:47.97757	t	2025-12-26 06:02:25.156222	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 05:58:47.992971	\N
3dc7b2f1-4a21-4ecd-83e7-a393cb4d09d8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	CjNuDmk/efaEG+H5C3K1rI6g9d0cfnTNX/Bu3QCVmpzzT34pH97v6+5ARmuqDdqja+/C53suR4gEN6YrDn60Qw==	2026-01-02 06:02:29.184253	t	2025-12-26 06:04:43.655036	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:02:29.19852	\N
d57bdf77-7793-452e-a437-3c043ce50133	6093a936-f8b0-49da-bf2c-16e426df5e69	33R4wsUzBJS+8x4vvxLLa814qDBLZRvWMoBftpjSifS3q65oaBl0dzWC6UbONo1LNeMcRE8ErBWzZ14phz5GmA==	2026-01-02 06:33:49.336867	t	2025-12-26 06:39:15.51122	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:33:49.373097	\N
eba15d0e-7c6c-48b2-acae-1e24e5284587	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	Qvh49AMI8rSK65hyVlg3/AbEVxBmQbIT+g2PZ2kxxu0eBxyNcpw9Se1LzpO7U8QQBaltvGYzlrAKGeQ5vv8Dtg==	2026-01-02 06:04:52.362666	t	2025-12-26 06:07:29.877902	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:04:52.377937	\N
3cc6ac71-da9c-4ef6-b897-e1d84bb354ff	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	NMcyfuGzKi9/LzXUMZnggBqeuRWK1ZFmZa3qxgR+f7QaQ9kUELCM9WFVV1N8EDbnmUYtGR+V/KYlYuHSsDpsxg==	2026-01-02 06:07:36.240788	t	2025-12-26 06:14:34.582814	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:07:36.25796	\N
75524775-be8e-43ee-a1c9-767d5cee22a1	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	ZZYPVuqgFfCn4pNdhlxkvBkxSrzNdauttrE+/l5nr8ybVv9H6NxJ/ODUzB2TmJrmlxLS+kfEs9mBI90D+sdwFA==	2026-01-02 06:14:39.08708	t	2025-12-26 06:20:07.696737	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:14:39.102553	\N
f663fea5-7f0a-4608-b10e-5249b4fa0cff	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	yKdLmZNFuziEHhPf7rQtyVMvovLJNajRPtwED9mExl5sGXBjM57yUIUmM3x9n5BnxBbKfKE4kSLM3lhcXx6mNQ==	2026-01-02 06:20:10.530912	t	2025-12-26 06:24:25.923832	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:20:10.545537	\N
be356d0d-cc19-4b7d-949f-f5c1b6a7e71d	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	VTHHGnOvk9s2953/WrrTKnYVWaxPE/NsXcpOhFaEQueJv7uGNZIwx5K4Hy75hpWP8vlLX07t+jpydc1BD7F1jA==	2026-01-02 06:24:30.324889	t	2025-12-26 06:27:32.134713	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:24:30.337747	\N
fb707d33-e437-40bc-840e-8e571f4629a4	6093a936-f8b0-49da-bf2c-16e426df5e69	29occQi12O6Sv2Nn5GL7zSFPdRbITmWun6YYRcFs8ApowRdq+EC9WOMvIcY/dA5pvzuAOSPx86ElTRoOOJyiOw==	2026-01-02 06:28:14.03286	t	2025-12-26 06:28:38.52837	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:28:14.038061	\N
fbc90ff6-bdc2-4f22-b1f9-85dbf1acf211	6093a936-f8b0-49da-bf2c-16e426df5e69	4uvMN3zGYz3CknAIi0ITxrho3li0FZvddXUloRBhLwNfK1LGiPH558mv/fhLabijjZeDslHtl7y5xEmFB3CqsA==	2026-01-02 06:28:38.669218	t	2025-12-26 06:33:49.133319	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:28:38.670411	\N
93d5dc67-ab10-4bda-a284-9db761dcfec9	6093a936-f8b0-49da-bf2c-16e426df5e69	Q1o9Ao58RlU+YwNIz/fWQUDGfglyL9niKKCD7QG1Dwh+KyT0rdeDFtHmE8y45cSZRxfIoGHfl28+TsMhdHXe5w==	2026-01-02 07:03:43.557722	t	2025-12-26 07:07:50.857589	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:03:43.571412	\N
a46b60d7-a924-454a-b0b6-b83a4849ac79	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	BbgpdR7VllgUZY40XukiIq+nT8QKlJOnX6UPSbU1O58+Tnhcfk1vtz+g8G2gvbzOzIB6KKHnh/8Qfw2OMVcVHw==	2026-01-02 06:40:33.258963	t	2025-12-26 06:49:29.915095	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:40:33.260231	\N
730b208d-b6a9-483d-92cf-8bd5feb25cec	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	V0tmrLMmdsqHQ7WoUT0YF70vBbrxNKGeYztSE+KUOXdZ9nE3w7MXFR2qAOwXnx3fsWTrCgkCnLj31CFjZZRXFQ==	2026-01-02 06:49:34.816236	t	2025-12-26 06:49:49.193302	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:49:34.850907	\N
20bdfdf1-c183-428f-b3d6-f1687a1b7a3d	6093a936-f8b0-49da-bf2c-16e426df5e69	2R2hsKlHL2QtNxVDe7cLhlqMj/RMC6EP+P86rEUvpvPpzCtUw/21zvA5RZ6G5bmQCQUJN+jufdCDIU0z7GezrQ==	2026-01-02 06:39:37.509858	t	2025-12-26 06:56:33.873781	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:39:37.525512	\N
2d473841-f8bc-4aaa-8228-a9e6889b51bf	6093a936-f8b0-49da-bf2c-16e426df5e69	ItKyypMjv+3eJt9j/BSoWn38J1NHyNzcpWqoIyp2xxDGucdvbpd0gyfa/O++rHalqstPksrgEP7a34BJZVwehw==	2026-01-02 06:56:34.132026	t	2025-12-26 07:03:24.182222	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 06:56:34.169824	\N
eff99230-2360-436a-8bf6-27a6fe025792	6093a936-f8b0-49da-bf2c-16e426df5e69	1MhK6t5+r0y4cxBZhQJfFmIRm+67OAeo6Xkmaq4vP+gO9PAm2/gghbd4Cx6ajRLxVyefrPCA/MXpBIvjEHpLAA==	2026-01-02 07:20:11.38964	t	2025-12-26 07:59:45.527064	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:20:11.39064	\N
b7c4b9d1-1eb4-4977-85a8-4b1425214478	6093a936-f8b0-49da-bf2c-16e426df5e69	G6+PzW7eVY78IlB5BSFv6sUP99rNwnHXN2FjhEndW0kutzsUMWD/64fmszi305EOzfGrGYRWMTH68MGipmYD8g==	2026-01-02 07:08:05.04368	t	2025-12-26 07:19:35.68061	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:08:05.061739	\N
23b0a03b-ac6f-4da5-87c3-a9197e60731b	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	rSOPFC6FHnsYYqrDHnu030kiBlGtVVIVmRA0zrDBpxUnET0b2SYb2Ua7nKvcuBDzEAvXYVNIN9PBefU4EzcTgQ==	2026-01-02 07:19:42.656652	t	2025-12-26 07:19:48.340162	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:19:42.670992	\N
56a27865-07f9-49a4-86a5-0bb42f3c8788	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	bzwn8onjEoKgfI1+RXQDtEi8rJ/YqIUaG6mURcFm5Bl3z57pMoSlzNy6bpZ6x52ke+vDPxQiy2JkoBDVOL1/RQ==	2026-01-02 07:45:06.924478	t	2025-12-26 07:59:08.403343	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:45:06.993951	\N
6af47395-2f24-4961-ac4e-ba8a67b996bd	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	EDSZxX/u3GUQgyC67x6DwNOG8V2RsS0fns0ocB4rsLvRkoPtumF0px4AdxhWPQfOF6RLLwGBgZK7bxA55zBHlg==	2026-01-02 07:59:11.781408	t	2025-12-26 07:59:25.68705	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:59:11.796174	\N
71be1963-503a-4f0e-bd7b-9e6cb813ffff	6093a936-f8b0-49da-bf2c-16e426df5e69	OrdMWB3nSO0JqPDL2T5dlnM/hogMLeTOH5YTcKabQICg6JJMUyYAHepWlGS4jqfXdHzpKeOHlRTtpVGi/yEsZA==	2026-01-02 07:59:45.582525	t	2025-12-26 08:09:06.238563	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 07:59:45.583398	\N
0a4b9407-d671-4a84-98aa-df19e776a155	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	uwZBK9Xt5SkeMQl42blTWiPu+WrfBp8OFhBXX3VqD2T2aiGm3wOsNO003bhDm7vbgRgT68o1tT56S0dFBSS+ng==	2026-01-02 08:09:11.292482	t	2025-12-26 08:10:29.013118	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 08:09:11.306989	\N
489f85b8-e3a0-4f9b-93af-2d15db2808f8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	gmkz9YohRt5Kja3uLpqkI01W1NsqFVuQ1WGA09JtDC5PQqfMgj+tRWH5kG6pn3tx2zSWKsf2X+4VsRVj+8lVkQ==	2026-01-02 08:10:32.552942	t	2025-12-26 08:11:47.613996	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 08:10:32.554226	\N
1caa24de-98b6-4770-9f3c-fd1c889a95c1	6093a936-f8b0-49da-bf2c-16e426df5e69	WAgz2E+BzE5NMJcv+ax27+KFCgQ53C7QyISQJS31res5bj0zgSG7MD+fI3+ZYNB4L6xyAsHpeoxUWKTDHp+Dsg==	2026-01-02 13:39:07.817684	t	2025-12-26 13:49:30.016443	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:39:07.899594	\N
9dec8909-ad4f-4879-ac0f-634b24ad48c8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	4DBh0A7Vj2gR47sYIdJb6t9mAvuYaQFhfXUAVBzEahfwan4sp4n5RWjhk+tVcv63TD7uuGxQB1cBQHiiBtsnpA==	2026-01-02 13:49:37.162185	t	2025-12-26 13:54:53.790769	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:49:37.1766	\N
46481b85-3bf1-4219-ab2b-58584cfb9a78	6093a936-f8b0-49da-bf2c-16e426df5e69	MCmTcLR9TN5t6ESAeGAZEPtzzwswlKnEsa2Ns5AHe90ZOwtcuzKtVgxI7c//HVr2V0SmT5w+pNN8F+gCWUax5g==	2026-01-02 13:56:23.410905	t	2025-12-26 14:15:15.53197	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 13:56:23.411733	\N
07269aab-845c-434e-9d73-aa386c0fa7f4	6093a936-f8b0-49da-bf2c-16e426df5e69	lIfEhLqm/aqPBUAJXxsuK8BLuiXg6+bPxyFHAUrEhEUDg5b3gTM55GgO/KXw3BKzsVUwT79zYIZ8rm21LrAYtw==	2026-01-02 14:15:15.601816	t	2025-12-26 14:19:48.221351	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 14:15:15.636976	\N
cd5a69c9-22f4-4ca2-b9f4-bbca5a43d073	6093a936-f8b0-49da-bf2c-16e426df5e69	amQHKLW2j7U+rk85LnGXsNWQfGu+iTtGH5b4dP3Mcq82jL8UNRy1Vxo+mslyqiIemhJMOXlhsNDyrCM1LRr4YQ==	2026-01-02 14:20:02.228212	t	2025-12-26 14:28:44.740526	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 14:20:02.241442	\N
fb99389c-6cbf-4278-8519-806073bf065b	00000000-0000-0000-0000-000000000001	tc/SMqeayHJylNY2qdaBdT76vdPtzuLK8f2rQhDExLInYbDWGReljcnqVgEiLZ6MJJLgPpmzIzgdDSHCMXxzuQ==	2026-01-31 13:19:47.670036	t	2026-01-24 13:22:26.16852	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:19:47.670814	\N
5e64bc29-c384-44de-89dd-6852761fc4c6	6093a936-f8b0-49da-bf2c-16e426df5e69	U6Sr8OFBTUyOdaCnbVHEkfc6y49a0pKMHEqNoTWePQPyWUlE7vjiD+/RK2SRQpTCNbei8f/HfigeyTlLp/BVrA==	2026-01-02 14:28:44.819988	t	2025-12-26 14:37:45.059248	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 14:28:44.858191	\N
468842fe-99b9-43cf-9144-f59681201ce1	6093a936-f8b0-49da-bf2c-16e426df5e69	/BgTcm6hrM381BPjAxQ0GRpW4LarVugO1gEFtt6DI1tLlNFcvKicWQnsGBoTmGE9QG802YrRu1L2kTDRj5W/+w==	2026-01-02 14:37:58.602211	t	2025-12-26 14:41:21.334435	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 14:37:58.616654	\N
c408aecf-5411-4c12-968b-21c23277cb88	6093a936-f8b0-49da-bf2c-16e426df5e69	pTKF2aYhmaS8oraQgy+V2vUK/jX2LZVpJgxP/QH0ehGuqR66X1zDpso3rwi6erROAkq3hCcTXm36qZmx8wKnXQ==	2026-01-02 14:41:21.496665	t	2025-12-26 14:43:35.589298	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-26 14:41:21.532522	\N
7a5b9845-c30f-45bb-8d31-fc5e5f81577e	00000000-0000-0000-0000-000000000001	hwJCwOeCu54ReZt/IAysyq2mzFSwGk+iPY7eaUoUPq5M8VbXVKSmjEJhHipJQTxlVhxlwGSrIa3uaUr2GDAWoQ==	2026-01-31 11:53:33.643525	t	2026-01-24 12:11:18.754729	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 11:53:33.671476	\N
1027d61b-fb2d-4847-abb4-47d96dcd1742	00000000-0000-0000-0000-000000000001	4KvXMPLXo/Beru7lI4/kdqJ6u79upCav2SrBTvitpzZTJdjY9pbzUc78+66j/EHnfSZqbxYacE5uElVhqO9kZQ==	2026-01-31 12:11:19.044992	t	2026-01-24 12:11:41.095651	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 12:11:19.060738	\N
664b5429-fb33-47d3-90c2-d21888c959d1	00000000-0000-0000-0000-000000000001	ovxxsQGQTROXoS4aN3Rt6riQQ4Mey0JCoPidB383+eEMRkpqUNDcKhYK1QMVxi22gjG4u9O40YIbO0WtLf4Wbw==	2026-01-31 12:36:02.078757	t	2026-01-24 13:15:32.291687	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 12:36:02.113931	\N
0f2ea5f5-943b-4556-a6d3-96f8d86e8d72	00000000-0000-0000-0000-000000000001	xic9uswONNdZoaQUTe/2ZC92YVnm6iZsSO6F8uBIBqZAksJ0Jnqf8p5wHd1G/WzfSJzNTxe6gi7WAEQrY+dbyw==	2026-01-31 13:15:32.458012	t	2026-01-24 13:19:47.658778	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:15:32.468755	\N
d170b65b-f0b7-464e-ae0a-5206aab36255	00000000-0000-0000-0000-000000000001	Bx5WTP7+duLGvOgLWd7rVJA5xbElF7KW7QybA4NxFMKciDmp7FDCAAeS8Ae6PSkax80EBDS814fUVCdmV2I6IQ==	2026-01-31 13:22:26.173347	t	2026-01-24 13:23:04.92753	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:22:26.174425	\N
0c7ab7e7-e6d9-4ff5-afd1-2940abf5e31f	00000000-0000-0000-0000-000000000001	Hcv0MCo6mGKf/HnjdsD8G+Enmhzkf2aCj7jppl3u+UeSXFB+0vLjsdSKVmq6drCVMjFc9nPGoBjZ84xEdCKJtg==	2026-01-31 13:23:04.932066	t	2026-01-24 13:28:20.662335	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:23:04.932781	\N
8f0307cc-02a7-4812-82cf-4d31e351a566	00000000-0000-0000-0000-000000000001	kMDn9g3whTy5FyJHbzZeBTQuL0pwBB/OMAruN8KV/QGqNRqIWq3kb65uXRCvgNupC2MEYL9hNGihO/w0ihRxNA==	2026-01-31 13:28:20.67439	t	2026-01-24 13:32:07.532238	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:28:20.675062	\N
8deb66b2-9b04-4147-b3b2-1a73498a01dd	00000000-0000-0000-0000-000000000001	iQMZa1lt09mkm4oJmtAUHAqweg681pF2howJP8fu7QTFTD577poICt53BykQiTtW7in2ghw/4QFZ9s+ws0OebQ==	2026-01-31 13:32:07.536881	t	2026-01-24 13:34:20.351071	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:32:07.537814	\N
99508324-62d4-4b37-accc-2b84fbef81ab	00000000-0000-0000-0000-000000000001	tG7CdSD7RyPTy2Ur7wgDyAjdF0jufoX2hDd2bAf/NiowZdzGebyFLMidl4b9T/KhF3YE9dHyjdtXa6lofcrKog==	2026-01-31 13:34:20.356371	t	2026-01-24 13:35:23.920069	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:34:20.357259	\N
b849c971-9aad-46c0-8214-363553a72b33	6093a936-f8b0-49da-bf2c-16e426df5e69	mvP8Z7CoRlKPZed+qh1sxhi9zFl3hy66D5ire9XwnEanigIIwap0zVDm7m0EJII7EAKYwgJfulj3vwyfSUI+hw==	2026-01-31 13:35:23.52025	t	2026-01-24 13:36:22.794143	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:35:23.520975	\N
aa5f06e4-98ae-4405-8af7-03a664829744	00000000-0000-0000-0000-000000000001	tNBQod0DuOxjaUU1NYnPb+ekcwLPuZopa3jREb9JliGhzvrm0BDFNRbBgrEYfMvdS/TAhCXX3LOh68QtHoUuNw==	2026-01-31 13:35:23.924204	t	2026-01-24 13:36:23.204895	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:35:23.92484	\N
c3e11d60-0067-4eca-8c33-6c12420e479f	6093a936-f8b0-49da-bf2c-16e426df5e69	x8N0SVNjmoTpSOXl+g1vGC1UK3LFUDOvAeXqM/ogMTsWjZqkuyCifblA18b2/QmKnDQnAHAySB4p4qDqIeghGw==	2026-01-31 13:36:22.798883	t	2026-01-24 13:36:52.859814	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:36:22.799858	\N
f19e1c51-6128-4597-9d69-f54d1a8e82f3	00000000-0000-0000-0000-000000000001	FW6XAGk+HK4am7dWEE4a95GFxHq9Scp5GjZsP+ozqHs+ISdbXaWnk5aoBSpOENk2ElRDIm7aG5eF97LVqE0yPg==	2026-01-31 13:36:23.208866	t	2026-01-24 13:36:53.300729	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:36:23.209309	\N
91580fc3-0e63-4570-9aa6-6fb2909b7c88	6093a936-f8b0-49da-bf2c-16e426df5e69	ujikb687Hdta6JuZB8Jm75WniuDFqK0rhgHxILlK54pmseJreqoUQLbTAZS+dt8VctV7gVlP4bhoyfKHhGh1rg==	2026-01-31 13:36:52.864096	t	2026-01-24 13:45:19.724209	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:36:52.864661	\N
44903685-5072-445c-86ae-e1a4f23827ad	00000000-0000-0000-0000-000000000001	vHlkWY9bSp/kXmP2Ev5NoseKipxwTCP60YoHSZVkkN8b4SCeAxYgKiNxafSQPPjUjq/o7hUZ+RU4UN0FJsIFRQ==	2026-01-31 13:36:53.304319	t	2026-01-24 13:45:20.177552	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:36:53.304862	\N
9e3a7522-cb53-4a84-8665-bb9f3be92667	00000000-0000-0000-0000-000000000001	y0/aaQBuZQ3f2V2+1IrK/O+QWwg+kQrW9rp7nHwiUXC6xqJtXyept3kCqGb2t+05qXMxheRUABPsRJklvJx4Zw==	2026-01-31 13:45:20.182508	t	2026-01-24 13:45:26.341699	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:45:20.183151	\N
11793def-e1d0-42c8-842f-a2cc84fa2e2f	6093a936-f8b0-49da-bf2c-16e426df5e69	MPLCkidQD0GGJqu8gr4Gr/qMEXLwFAZApj6lDWn1B55y6SlbaN9Axc2EnqXeNe5ElrhyFZZb+2EmMMLT2gI+Ng==	2026-01-31 13:45:19.732809	t	2026-01-24 13:48:25.37873	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:45:19.733362	\N
a6bc1dbf-50b2-45ee-9f41-9c3b775fd2ba	00000000-0000-0000-0000-000000000001	hD3b6I2A0WiH7BeCtuHK2v8LHA54r4tnMSheiWk0pFGmmC0eML6FKqjVe5FGHdvn94bhUSShVMVfSxNuMQraOA==	2026-01-31 13:45:26.345972	t	2026-01-24 13:46:09.955783	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:45:26.346407	\N
d3ac1604-c98c-4e3b-9116-85f02509976e	00000000-0000-0000-0000-000000000001	G7ZwZF6BNsnq6GJbgQ1bizNXbpPzjT7cETeZx/L9UP0djNXCa+zQ3hs+gLjmQ2RkAhd3Khv7gLUi91mLLfNCzQ==	2026-01-31 13:46:09.959907	t	2026-01-24 13:48:25.779516	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:46:09.96044	\N
0ded1047-edf0-46ef-a570-64eb5c25b958	00000000-0000-0000-0000-000000000001	pR3NYyTINGd/W1nAsPcwVoYNgkeVRxvDkK7QKP2AeOdSOVnsB6VI+lSKM5RmsYHh1W18tNhmPuyvWsTfsF8aNw==	2026-01-31 13:48:25.784241	t	2026-01-24 13:48:26.576516	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:48:25.784693	\N
30a91600-1b27-4da2-a9cb-b2539964cbc3	00000000-0000-0000-0000-000000000001	dp2dO6s6U387Ysmjnv2uLYNGBY91LD3Fi1jSyWSZ6894jHql5AsKfF+MaLhtS2w2rFCPqQHW5LgZN2J4oIqD8g==	2026-01-31 13:48:26.580536	t	2026-01-24 14:05:56.479298	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:48:26.581038	\N
e97892d6-86dd-4bb0-84e0-983816686a77	00000000-0000-0000-0000-000000000001	5VUfzmKIGECBPujSr+JfiPPaZxp/ONaajNqfNBCt6cc+qun2rf31IugYGtf0lXqkxo52XzMxIi+ak9MfytNYXg==	2026-01-31 14:05:56.660527	t	2026-01-24 14:12:08.701019	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 14:05:56.674209	\N
f910b133-ea4d-49d7-b266-0dca1a0a3ead	00000000-0000-0000-0000-000000000001	bZIvimjf+BGlQ9tej474J9turmjBqMV15826oxmUTzsjHrjmvjAqbZNllkv+L4dd7esecXsDj8FxNc+FNZ7yNQ==	2026-01-31 14:12:13.597833	t	2026-01-24 14:12:16.020333	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 14:12:13.611568	\N
a50e3cf2-599f-41ca-a955-ac7797bb207c	00000000-0000-0000-0000-000000000001	gGoRXL2x+qCUpBtsFOJP8aMhKmBurZMzRE9tBi6VRvbfj4rpmyMuDQo6Xe05rcQ/ULvsSIphM3OtEwI+8nC/UQ==	2026-01-31 14:12:39.375632	t	2026-01-24 14:12:45.934489	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 14:12:39.37647	\N
3381f4ce-71e9-483a-92ea-db53f12086e5	00000000-0000-0000-0000-000000000001	S0FQKsNvuMPjsFFYu8N5U2Z2L/qlsiizn9MUZl1HkJimqcWhZaH9jT2KYLnzm2YSmFQsdn4WG+ZSd9NMWFmUkg==	2026-01-31 14:25:23.978723	t	2026-01-24 14:25:32.788359	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 14:25:24.015975	\N
6e328c9a-5d22-450a-9bc9-18454145107e	00000000-0000-0000-0000-000000000001	uVwmidFPLh+TKwktliC90y7Faw2j2eh6I4e5aTGkYrCIf6juWEw1lric75EwUGiRXa601q0TDwX47giYokGAGw==	2026-01-31 14:25:32.842916	t	2026-01-26 18:01:18.470423	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-24 14:25:32.844413	\N
962fcd7b-d4d6-434d-b4dd-2c209aa6d65f	00000000-0000-0000-0000-000000000001	euqUevn5J1RzDvLtGYFibLdJI3urOP1e5WkCNjC6BKWxYY9cDhIgWyBaE/ETcqmqojn5DlH/G+N8lcIk0Nc7rA==	2026-02-02 18:01:18.696059	t	2026-01-26 18:01:56.253737	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 18:01:18.709682	\N
0f48d8ed-15ed-4d07-bd8c-d6204834ff79	00000000-0000-0000-0000-000000000001	6fUSJRSKScnqXvcl4TRQbAklP2dg/mtWjNxUWj/6firKWTNOo+YV573LE87rVcGqtg1jMDCNjB1BiH0JIdTBXQ==	2026-02-02 18:02:00.565146	t	2026-01-26 18:23:58.414842	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 18:02:00.566591	\N
4db6cdaa-a49c-4f7d-8ee9-d0a7c3b4958b	00000000-0000-0000-0000-000000000001	rhnRQTrL2VJssdOzC1rUIFhKWX6VqJZ1Oy34qgrliJx0pgx3BG3JfM1isjBRmpEp7iMitJaIPCP+l8tYimUwSw==	2026-02-02 18:23:58.819286	t	2026-01-26 18:57:11.852817	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 18:23:58.832406	\N
e08e7759-73d4-4d52-9de1-7be3cdefa88d	00000000-0000-0000-0000-000000000001	biTQ2H1fEtP1DEzzxe7Myq2R27mbgmilj6ijYNRFB2qgjzpIgVOehwx515qpmvcTpf+/I4lkGu2KpaW9LYRcVA==	2026-02-02 18:57:12.140275	t	2026-01-26 18:57:43.210324	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 18:57:12.154938	\N
b6ec34ca-3233-4797-89cc-730f6de90f31	00000000-0000-0000-0000-000000000001	MrUXmFHDc5HDBdE7esuIJekOJ+AnB84+XFuudnSyQfNvPDccRTnEBq0xqFa2nzW/2cd5lplNiy1lp3ejXD63vg==	2026-02-02 18:57:48.480336	t	2026-01-26 19:07:21.152317	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 18:57:48.481333	\N
28bb33c0-d905-4920-b953-603ad39c5303	00000000-0000-0000-0000-000000000001	qr+grZqz+/VWpOpxJ9ohTENz5L4MuI/GDGz0CJQNsrV4TYuosWuNDpie9bwNyDQp4d/SEoZwDWMLjKxrXUA+9Q==	2026-02-02 19:07:24.82559	t	2026-01-26 19:24:41.362623	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 19:07:24.83944	\N
61b59dfe-933b-41f6-998a-e8705183b30c	00000000-0000-0000-0000-000000000001	8v2Hcgf8+hp4QYMFcPCeDminEjGrhjxI151j9jop++r2h8ivzsLNmXhueYZtraHoiuZgC+OFJ8PspyAFpwVvHA==	2026-02-02 19:24:41.561924	t	2026-01-26 19:39:44.418874	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 19:24:41.575317	\N
2ae01be2-8e2a-443f-87f0-2a38bf158fd2	00000000-0000-0000-0000-000000000001	Jkyseq1uU4rPa6c8mlWMQJBk/FgDs3sWqTZpKTO1qk1mkyFc7RBaEXOZHGH2SAxdbmLlBXmtPDmbk4fy25SF5w==	2026-02-02 19:39:44.621274	t	2026-01-26 19:55:37.915433	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 19:39:44.636146	\N
bfc2ea06-d8f5-4f16-b545-90b306a9908f	00000000-0000-0000-0000-000000000001	wjQlyd6m55Us+dk6RbVX4drxf1NrzFWWZWG/4WIh8e5d1I8jKbLI/Iny4SPiQ8hGg8A/pDyMYZ2enMZKgn9mKA==	2026-02-02 19:55:38.134764	t	2026-01-26 20:06:55.450614	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 19:55:38.148834	\N
95b989cb-8a6f-4fbb-8915-b485165a13d5	00000000-0000-0000-0000-000000000001	bZC14cSDqTv2Sy9XiieqA3RQYoDu+yIxjQs9LqOlndZ4eCg89AaG+ihGUOJqGF/vF/CV2jprvOk7vzkEu/uy3Q==	2026-02-02 20:11:08.650843	t	2026-01-26 20:11:16.702876	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 20:11:08.680817	\N
cd2eb850-bb23-4f03-aa61-307c2eaec6d6	00000000-0000-0000-0000-000000000001	DQJLB2jjQOJBGxM5gL25hJbAMOwm3BSYNSpASYzdjmas0eVfOGsMlRa/GjkdeJSUgaKgV0G0zlRkjc/RNumoOg==	2026-02-02 20:11:33.961784	t	2026-01-26 20:11:36.257022	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 20:11:33.962746	\N
09786247-fe3d-4a8b-b2c5-bfa0c2ff6372	00000000-0000-0000-0000-000000000001	8jF6E2yxBb+Z9ELq4U7HC7TvyLCIZ6QtEXzADvEANZJpAliB6q6uEoBe25O+k6p3GkXpCISpWwxQtYQmtgUWxw==	2026-02-02 20:11:52.154425	t	2026-01-26 20:20:10.423755	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 20:11:52.155254	\N
2b46d82c-a752-429d-b229-4a34d93afae8	00000000-0000-0000-0000-000000000001	DRCoWs3w6Wt9ure82i3aODe7aFwMd2qhhYMMLEslCniIjBVw4zEIzHtTvrAVTip+ktlHjqsxrL3UDgvM5XsyaA==	2026-02-02 20:38:12.483844	t	2026-01-27 19:36:45.967329	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-26 20:38:12.521441	\N
7abf08d4-de11-4297-bc2b-69534953f240	00000000-0000-0000-0000-000000000001	2t003M1gdTPD6zurBEdZB18Qu9x9vJXuvWJvrYkZ9d5SJ8xgD0kS1vA6a3x3U5LFe/qIDv7yptgOEo4jkKy3rw==	2026-02-03 19:36:46.201937	t	2026-01-27 19:36:50.06913	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-27 19:36:46.21642	\N
8b78d5bc-bda6-48d4-85bc-e8aea631b81b	00000000-0000-0000-0000-000000000001	fFjxIesZdiDAF7rBaxrlz+X1d3DYgmpkAi7LHaqkun2mE1m7tCr/zIuCaFMRX+0+YoKpIC7aiZTMzdss7MXwDQ==	2026-02-03 19:36:55.950562	t	2026-01-27 20:03:40.225491	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-27 19:36:55.951926	\N
446e61f5-41a9-4b7f-bda3-cc927333dcbd	6093a936-f8b0-49da-bf2c-16e426df5e69	/A6BwA++S7LZnjAWlHGU+IyqvTMTP5DhvpzDlhevdZ4Bdunhsztxgx7nt0zHdD77dVHcF+YfiGkGZW2IcngZMA==	2026-01-31 13:48:25.383587	t	2026-01-28 19:18:32.411113	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-24 13:48:25.38425	\N
008a1a96-ca87-4b5b-94b5-4360f90bafb6	00000000-0000-0000-0000-000000000001	2H5y1Mx2S1vODWscLnEpwRFO1+pIKG3VayTCQIbXxYLo0uEvDHMmBLUmOE3eIiiEtxgTb5ZmIkX/V2QjcqrSTA==	2026-02-03 20:03:40.350234	t	2026-01-27 20:23:43.16849	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-27 20:03:40.363909	\N
67d692c2-a5ba-4f00-ae4c-7c4b71f2b7c9	00000000-0000-0000-0000-000000000001	qBsw/NT/sq5T8nrKKB1ZCAYA7g07dO9oQ/i8FKeqDXgO1JoziIL0Wy01vKQtR6JQtiQiNXSKdMyc30RLCOd6FQ==	2026-02-03 20:23:43.309245	t	2026-01-27 20:25:31.564069	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-27 20:23:43.324179	\N
25b80b84-2497-4812-8f77-8784ebefa4a9	00000000-0000-0000-0000-000000000001	uMNwki1HD0q3Wtone/cg+CmNWpT7SUdLf5Xx1620td74sGoXE7vp3Lu/b3Hpl+dnxwy5FtKQIqBPejE6LhoFHA==	2026-02-04 14:28:23.920438	t	2026-01-28 14:33:01.123901	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-28 14:28:23.964828	\N
92b1760e-b297-4213-8b77-30d856649eba	6093a936-f8b0-49da-bf2c-16e426df5e69	8/6yglZKWvz89ooLIK6hIUGaNpr1LW9Mfsd4Y7QzVmW+S6kkJsTIz7DC/KVYUXN+lE7JqPI1epxSDOmwCus7tQ==	2026-02-04 19:18:32.58762	t	2026-01-28 19:18:47.452153	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-28 19:18:32.608426	\N
e5bb93da-0702-4b5e-abc9-fe33e44e1a06	6093a936-f8b0-49da-bf2c-16e426df5e69	nodFrKcttU0Nz/8pfv8jp4dXD7NsHLnc4+ulq/a+/tCgq1g6nyrB8caWpSkIyNsXP51qsF4LgSyt7y8x+n/SjA==	2026-02-04 19:18:47.458893	t	2026-01-28 19:19:01.266319	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-28 19:18:47.460048	\N
afb5e491-6ce5-4f7c-9ddc-123b1556374e	6093a936-f8b0-49da-bf2c-16e426df5e69	/X/uut4CCkT5JHHH2FLSwtVCMMyVxShE19NVrCSAVWYrtUHq1ojv4a3gN/XVRx389SkptBScjhGHtXORt8Op3Q==	2026-02-04 19:19:01.277725	t	2026-01-28 19:19:16.226116	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-28 19:19:01.278551	\N
feb4f0e0-eb32-4198-b867-4bb76401f0c2	6093a936-f8b0-49da-bf2c-16e426df5e69	arz3r/mBxltyHd3NVF7EKWhu3Ko5e7SIrqMYKP1oVvjAeXsdkJvpn0x0MIiQbcKzlQ4K3BWy1FykEVV999SkMQ==	2026-02-04 19:19:16.230318	t	2026-01-28 19:27:41.174217	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-28 19:19:16.231007	\N
ba580b09-5d67-4071-99f3-0925455bb444	00000000-0000-0000-0000-000000000001	hVfZmTXt7XzbBpWemgfPT7kUPzMNq9ZotZS/TFzsfE+z8Kod0LJqfQIotqhV4iaswmmeDxwWWz3b0UIDmHMNJg==	2026-02-04 19:18:34.050908	t	2026-01-28 19:45:32.741323	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-28 19:18:34.052059	\N
66741717-3d31-47a8-94d3-b2d5fd1a2aa7	00000000-0000-0000-0000-000000000001	eFG/jPx32Jzh7DVAZJqiZ7PwfvBDjWbbWH6LjbpEDTGE9QClT0wwuF1PPxRCwIPtvyH1Xy80XXp/ZsWJf7fv2A==	2026-02-04 19:45:32.907483	t	2026-01-28 20:01:00.014552	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-28 19:45:32.923647	\N
a999fe3b-017a-4ff7-9b2b-eba5eb06173c	00000000-0000-0000-0000-000000000001	A9kgiBBkooZr1uQWRJZUth9USsHmH97TLp5TF+tsX4UR1g/+4ZSMAP9kONAzE/doTAwjuN7l4T12fXCqRu6/zg==	2026-02-04 20:01:00.246691	t	2026-01-28 20:17:17.431771	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-28 20:01:00.263315	\N
88e63d1e-e778-45d9-b8a4-64d4f026ffa5	00000000-0000-0000-0000-000000000001	VixcG3HlMGgIDDcg72YHU+nX2dzLIfIsuPpL5h64uu/QqgZMMu991k4kZVbNfTI6LzkgHyolrHvyQMub8un2zA==	2026-02-04 20:17:17.666576	t	2026-01-29 17:05:54.587776	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-28 20:17:17.683182	\N
05c6e2a0-1904-4494-b516-98214add586b	00000000-0000-0000-0000-000000000001	Lh2W7WyKhChU8LY8iUZmxuUf60pnFepHeAy/z45dNOfZ++sg2JtkYA2uzhoPa87188g6QOJtEvADd+lKHyggHQ==	2026-02-05 17:05:54.869336	t	2026-01-29 17:18:23.846188	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-29 17:05:54.883853	\N
a7766fce-7780-4421-b51b-28b8827a2a60	6093a936-f8b0-49da-bf2c-16e426df5e69	LQlp8WzXn1NkxDk//umTxuTIACmRM+oLfdBN840R8wyNywAltOqA1dxDR1sMeF36cKOLLJvNKHa1uaa+7kpxOg==	2026-02-04 19:27:41.183703	t	2026-01-29 17:28:39.533852	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-28 19:27:41.18433	\N
a78d0af0-1903-48f6-9c70-7addc843aa30	6093a936-f8b0-49da-bf2c-16e426df5e69	fqe59gMkKeQ5AmXBb0Za1W9SbrLuk4Al0vaCm17yJtoubFPX/EL1pWWXS2jtXWd0GJrig51sdQBXKC96dfD9mw==	2026-02-05 17:28:39.663852	t	2026-01-29 17:28:47.932414	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-29 17:28:39.675401	\N
2f28349e-7b80-4981-aa29-dd1f27a608f7	6093a936-f8b0-49da-bf2c-16e426df5e69	H0hWoUQk1M5g5KVVrroHT2GLE9CPigpAuHvf5D8oYYXqV6LeylOftbB8agQ+HAlkhgHBzLOV2Nsj8OdHFaAVvQ==	2026-02-05 17:28:47.938442	t	2026-01-29 17:28:56.873654	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-29 17:28:47.939499	\N
f644a108-ede0-4b92-9652-36dfe1da6fac	6093a936-f8b0-49da-bf2c-16e426df5e69	3x4L8OAZmGQQLRUouo1JHA+3p3vt4hQPV3cTen8SN1Pj8/ANeJj98cV14vBGOEWhMdGMZPi/lTtqDHSv5+cakw==	2026-02-05 17:28:56.87936	t	2026-01-29 17:29:05.271708	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-29 17:28:56.880386	\N
55bcdac8-2a99-48e9-a3a6-96b7ae0dcc70	6093a936-f8b0-49da-bf2c-16e426df5e69	jLpLuXYeCyUFnWmZbManSQm+1w/BIwl1yFrVupZst3IOW34AafKuzlhxBIlSafpOm2KxWgE1XbJrvS0gg9KdCw==	2026-02-05 17:29:05.276823	t	2026-01-29 17:29:20.109834	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-29 17:29:05.278148	\N
b82fa7b4-3b4a-4928-915f-64325343dd0d	6093a936-f8b0-49da-bf2c-16e426df5e69	xd3qoQbc4DYJj+xI8pxLEOswghEbpQHh6d2BQ8y5Xlicyp7MrBN6/B0sfBrqiypiT3sDJg4GRRQf4/AGvsMjRw==	2026-02-05 17:29:20.115103	f	\N	\N	::1	Mozilla/5.0 (Windows NT; Windows NT 10.0; es-MX) WindowsPowerShell/5.1.22000.2538	2026-01-29 17:29:20.115738	\N
a0307b25-c607-407d-8d23-8956a50028dd	00000000-0000-0000-0000-000000000001	etkA9D0Mw2Kp+7Bf507U6v6Ghp157B/j7sO5P0IjJkmEWZz6EXMhwNXjhdAtjgVfb4gzxcwrIr0F4ZbAUmoCVw==	2026-02-05 17:18:24.125298	t	2026-01-29 17:35:57.082053	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-29 17:18:24.139738	\N
2b823cf9-d440-447a-9a87-2a63ef4b6012	00000000-0000-0000-0000-000000000001	0lnJjNlQCcm3W1ySsZD1Q/1rWOUP6Z2M8XwFpilTZzXlx6UhxFayUPs3u2IwvvSe4K72I6GHZe1zxteJU21YTg==	2026-02-05 17:35:57.3255	t	2026-01-29 17:36:43.388062	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-29 17:35:57.343029	\N
fefbd545-995c-49e5-bccb-c361c1fdb65c	00000000-0000-0000-0000-000000000001	kUD2PtAkOMxwRAGs6Q6RR/gEGiOjo4+aYLRnxtcGTwQxSWkh0BrtzLfQSs65dsoRV4BYeWuGmznVBG2FdpsY5Q==	2026-02-05 18:17:58.829968	t	2026-01-29 18:59:26.279333	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-29 18:17:58.866147	\N
b8e45c6d-7cd2-47b5-a868-2a5a8e5e95a7	00000000-0000-0000-0000-000000000001	mIr+7QaBHWjQVW3LaomjNFlkHvuGFdCCF6YMCfXdRITTVndyoOOHK2X4tyyN7awsEbsPHQHCJ26Wjfjw0+69WA==	2026-02-05 18:59:26.425129	f	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	2026-01-29 18:59:26.438345	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, name, description, created_at, updated_at) FROM stdin;
65a8d225-6334-4ee1-ad4d-4f08e25e0b19	Admin	Administrador del sistema	2025-12-25 03:22:07.892489	\N
fd3015ee-40f9-4291-946d-12f81f8bf023	Customer	Cliente del sistema	2025-12-25 03:22:07.892489	\N
\.


--
-- Data for Name: sms_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sms_notifications (id, user_id, booking_id, type, status, to_phone_number, message, sent_at, retry_count, error_message, scheduled_for, provider_message_id, provider_response, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tour_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_categories (id, name, slug, description, display_order, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tour_category_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_category_assignments (id, tour_id, category_id, created_at, "UpdatedAt") FROM stdin;
\.


--
-- Data for Name: tour_dates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_dates (id, tour_id, tour_date_time, available_spots, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tour_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_images (id, tour_id, image_url, alt_text, display_order, is_primary, created_at, updated_at) FROM stdin;
cb8ab1f6-4594-4456-9998-0905093d4721	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/01c01705-7c19-4822-85ae-6aa48488529b.jpeg	\N	3	f	2025-12-25 17:18:32.896184	\N
26522bef-c4f4-4642-afb3-4d549c0f1ad9	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/1e151d0a-1303-4699-b2bc-a257ad576650.jpeg	\N	4	f	2025-12-25 17:18:32.896184	\N
8d7f2c22-7e2d-4296-a49f-11ffef291b92	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/bcf906db-381c-40a9-b3a8-c6abf7aa8cb8.png	\N	1	f	2025-12-25 17:18:32.896184	\N
639bbff8-a7d4-472c-b8b9-29bcb1766a5d	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/4063f549-0b60-48be-8933-1d5e2801a7d9.png	\N	2	f	2025-12-25 17:18:32.896184	\N
add811f0-515c-465f-b4c7-1b731d83229f	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/0ea7d517-d587-4e1f-865b-55c04dd204b8.png	\N	0	t	2025-12-25 17:18:32.896184	\N
a648f10a-dae3-4b63-9608-c84ffd69fb36	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/79ec717d-86f8-4607-9d15-b14fb3e7845f.png	\N	0	t	2025-12-25 17:38:42.729817	\N
d0486a20-919d-43bf-8c05-cc218e74b212	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/2001d789-3c71-44a2-a674-558a70b5ce94.png	\N	2	f	2025-12-25 17:38:42.729817	\N
2888a978-d2c9-4ec6-94cd-342ba6258437	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/01a74ce4-d1a8-43f1-afc9-5ea416de6b2c.png	\N	1	f	2025-12-25 17:38:42.729817	\N
1c694f69-5b1c-401c-b852-f306289559f4	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/47fce5a0-1aec-46a6-a276-649debc5f802.jpeg	\N	4	f	2025-12-25 17:38:42.729817	\N
4fb28c74-2a3a-4000-8970-745bb20f9c0c	00000000-0000-0000-0000-000000000000	https://localhost:7009/uploads/tours/2438f038-a3d7-4c8d-8b27-6f7edef814a7.jpeg	\N	3	f	2025-12-25 17:38:42.729817	\N
04949aaf-8c02-472a-a148-fee32fe5819e	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	https://localhost:7009/uploads/tours/98404bd4-1166-4b6c-841d-126650b1a6bb.png	\N	2	f	2025-12-26 13:53:28.071305	\N
516d52b5-49c1-42b1-829d-a4fd322449d5	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png	\N	1	f	2025-12-26 13:53:28.071305	\N
d1743637-2c9f-43f8-9504-96168f79cef7	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	https://localhost:7009/uploads/tours/d6a70f67-0c47-4e42-bfd1-a7640ca0ebcc.png	\N	3	f	2025-12-26 13:53:28.071305	\N
53a8f488-a728-4b48-9ebc-ab473ff4d3ac	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png	\N	0	t	2025-12-26 13:53:28.071305	\N
\.


--
-- Data for Name: tour_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_reviews (id, tour_id, user_id, booking_id, rating, title, comment, is_approved, is_verified, "TourId1", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tour_tag_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_tag_assignments (id, tour_id, tag_id, created_at, "UpdatedAt") FROM stdin;
\.


--
-- Data for Name: tour_tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tour_tags (id, name, slug, created_at, "UpdatedAt") FROM stdin;
\.


--
-- Data for Name: tours; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tours (id, name, description, itinerary, price, max_capacity, duration_hours, location, is_active, available_spots, created_at, updated_at, includes, tour_date, available_languages, hero_title, hero_subtitle, hero_cta_text, social_proof_text, has_certified_guide, has_flexible_cancellation, highlights_duration, highlights_group_type, highlights_physical_level, highlights_meeting_point, story_content, includes_list, excludes_list, map_coordinates, map_reference_text, final_cta_text, final_cta_button_text, block_order, block_enabled) FROM stdin;
29ba9240-93ec-4c61-b0f5-a1bba83bd21b	Cebaco	Descripción del Tourqaqa\nDescripción del Touraqaqa	Descripción del Tourssss\nDescripción del Tourssss\nvvvvvvvvv\nsssssss	23.00	100	3	Panama	t	75	2025-12-25 17:38:42.669668	2026-01-28 19:18:34.468686	wswwswss\nwswsws\nwswsws\nwswswsws\nwswsws	2025-12-28 05:12:00	\N	\N	\N	Ver fechas disponibles	\N	t	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	¿Listo para vivir esta experiencia?	Ver fechas disponibles	\N	\N
\.


--
-- Data for Name: user_favorites; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_favorites (id, user_id, tour_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_roles (id, user_id, role_id, created_at, updated_at) FROM stdin;
10be8bb8-6133-4e18-868b-8e485e6d5a15	6093a936-f8b0-49da-bf2c-16e426df5e69	fd3015ee-40f9-4291-946d-12f81f8bf023	2025-12-26 06:28:13.968189	\N
00000000-0000-0000-0000-000000000001	00000000-0000-0000-0000-000000000001	65a8d225-6334-4ee1-ad4d-4f08e25e0b19	2026-01-24 11:38:33.545505	\N
\.


--
-- Data for Name: user_two_factor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_two_factor (id, user_id, secret_key, is_enabled, backup_codes, phone_number, is_sms_enabled, enabled_at, last_used_at, "UserId1", created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, email, password_hash, first_name, last_name, phone, is_active, failed_login_attempts, locked_until, last_login_at, created_at, updated_at, email_verified, email_verified_at, email_verification_token) FROM stdin;
6093a936-f8b0-49da-bf2c-16e426df5e69	cliente@panamatravelhub.com	$2a$11$QSpUJnyC7yWvOTDXVMYny.X1g6m6ddQO7qVLBXweK/NzPGmHvMMgG	irving	corro	\N	t	0	\N	2026-01-29 17:29:20.107215	2025-12-26 06:28:13.867754	\N	f	\N	\N
d350d305-f8c1-4372-ab09-9e3e43dfc497	irvingcorrosk19@gmail.com	$2a$12$jh9xDrV7BEukZH4L1/PPb.JdrNoj5JwnvQgj/kPjYPfZ/UPQUscXm	Irving Isaac	Corro Mendoza	\N	t	0	\N	\N	2026-01-29 17:37:14.97611	\N	f	\N	c5b0e591ee5846aab10adc65969bfa84
ff14879f-c23f-4343-a0ac-024b8023b7e4	irvingcorrosks19@gmail.com	$2a$12$Ty48fgWrEIZcVDS25oG2teaa5WCaPkxIjG1EJfRxifiOwR/PbnE/e	Irving Isaac	Corro Mendoza	\N	t	0	\N	\N	2026-01-29 17:37:42.140644	\N	f	\N	67015960e9bd467b80dd8114acfcc0f6
00000000-0000-0000-0000-000000000001	admin@panamatravelhub.com	$2a$12$kaxsUszZmsDNBElMIhwRseRWzyKXoC06h/pCxptQaE/FkB9IL226u	Admin	System	\N	t	0	\N	2026-01-29 18:59:26.218825	2026-01-24 11:38:22.260748	2026-01-24 11:49:35.240272	t	2026-01-24 11:38:22.260748	\N
\.


--
-- Data for Name: waitlist; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.waitlist (id, tour_id, tour_date_id, user_id, number_of_participants, is_notified, notified_at, is_active, priority, created_at, updated_at) FROM stdin;
\.


--
-- Name: DataProtectionKeys_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."DataProtectionKeys_Id_seq"', 1, false);


--
-- Name: analytics_events PK_analytics_events; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT "PK_analytics_events" PRIMARY KEY (id);


--
-- Name: blog_comments PK_blog_comments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT "PK_blog_comments" PRIMARY KEY ("Id");


--
-- Name: bookings PK_bookings; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT "PK_bookings" PRIMARY KEY (id);


--
-- Name: coupon_usages PK_coupon_usages; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupon_usages
    ADD CONSTRAINT "PK_coupon_usages" PRIMARY KEY (id);


--
-- Name: coupons PK_coupons; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT "PK_coupons" PRIMARY KEY (id);


--
-- Name: email_settings PK_email_settings; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_settings
    ADD CONSTRAINT "PK_email_settings" PRIMARY KEY (id);


--
-- Name: invoice_sequences PK_invoice_sequences; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_sequences
    ADD CONSTRAINT "PK_invoice_sequences" PRIMARY KEY (year);


--
-- Name: invoices PK_invoices; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "PK_invoices" PRIMARY KEY (id);


--
-- Name: login_history PK_login_history; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT "PK_login_history" PRIMARY KEY (id);


--
-- Name: pages PK_pages; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pages
    ADD CONSTRAINT "PK_pages" PRIMARY KEY (id);


--
-- Name: sms_notifications PK_sms_notifications; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications
    ADD CONSTRAINT "PK_sms_notifications" PRIMARY KEY (id);


--
-- Name: tour_categories PK_tour_categories; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_categories
    ADD CONSTRAINT "PK_tour_categories" PRIMARY KEY (id);


--
-- Name: tour_category_assignments PK_tour_category_assignments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_category_assignments
    ADD CONSTRAINT "PK_tour_category_assignments" PRIMARY KEY (id);


--
-- Name: tour_dates PK_tour_dates; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_dates
    ADD CONSTRAINT "PK_tour_dates" PRIMARY KEY (id);


--
-- Name: tour_reviews PK_tour_reviews; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT "PK_tour_reviews" PRIMARY KEY (id);


--
-- Name: tour_tag_assignments PK_tour_tag_assignments; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_tag_assignments
    ADD CONSTRAINT "PK_tour_tag_assignments" PRIMARY KEY (id);


--
-- Name: tour_tags PK_tour_tags; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_tags
    ADD CONSTRAINT "PK_tour_tags" PRIMARY KEY (id);


--
-- Name: tours PK_tours; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT "PK_tours" PRIMARY KEY (id);


--
-- Name: user_favorites PK_user_favorites; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT "PK_user_favorites" PRIMARY KEY (id);


--
-- Name: user_two_factor PK_user_two_factor; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor
    ADD CONSTRAINT "PK_user_two_factor" PRIMARY KEY (id);


--
-- Name: users PK_users; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_users" PRIMARY KEY (id);


--
-- Name: waitlist PK_waitlist; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waitlist
    ADD CONSTRAINT "PK_waitlist" PRIMARY KEY (id);


--
-- Name: countries countries_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_code_key UNIQUE (code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: IX_analytics_events_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_analytics_events_created_at" ON public.analytics_events USING btree (created_at);


--
-- Name: IX_analytics_events_entity_type_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_analytics_events_entity_type_entity_id" ON public.analytics_events USING btree (entity_type, entity_id);


--
-- Name: IX_analytics_events_event; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_analytics_events_event" ON public.analytics_events USING btree (event);


--
-- Name: IX_analytics_events_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_analytics_events_session_id" ON public.analytics_events USING btree (session_id);


--
-- Name: IX_analytics_events_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_analytics_events_user_id" ON public.analytics_events USING btree (user_id);


--
-- Name: IX_blog_comments_BlogPostId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_blog_comments_BlogPostId" ON public.blog_comments USING btree ("BlogPostId");


--
-- Name: IX_blog_comments_BlogPostId_Status_CreatedAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_blog_comments_BlogPostId_Status_CreatedAt" ON public.blog_comments USING btree ("BlogPostId", "Status", "CreatedAt");


--
-- Name: IX_blog_comments_CreatedAt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_blog_comments_CreatedAt" ON public.blog_comments USING btree ("CreatedAt");


--
-- Name: IX_blog_comments_ParentCommentId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_blog_comments_ParentCommentId" ON public.blog_comments USING btree ("ParentCommentId");


--
-- Name: IX_blog_comments_Status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_blog_comments_Status" ON public.blog_comments USING btree ("Status");


--
-- Name: IX_blog_comments_UserId; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_blog_comments_UserId" ON public.blog_comments USING btree ("UserId");


--
-- Name: IX_coupon_usages_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupon_usages_booking_id" ON public.coupon_usages USING btree (booking_id);


--
-- Name: IX_coupon_usages_coupon_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupon_usages_coupon_id" ON public.coupon_usages USING btree (coupon_id);


--
-- Name: IX_coupon_usages_coupon_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupon_usages_coupon_id_user_id" ON public.coupon_usages USING btree (coupon_id, user_id);


--
-- Name: IX_coupon_usages_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupon_usages_user_id" ON public.coupon_usages USING btree (user_id);


--
-- Name: IX_coupons_applicable_tour_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupons_applicable_tour_id" ON public.coupons USING btree (applicable_tour_id);


--
-- Name: IX_coupons_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_coupons_code" ON public.coupons USING btree (code);


--
-- Name: IX_coupons_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupons_is_active" ON public.coupons USING btree (is_active);


--
-- Name: IX_coupons_valid_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupons_valid_from" ON public.coupons USING btree (valid_from);


--
-- Name: IX_coupons_valid_until; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_coupons_valid_until" ON public.coupons USING btree (valid_until);


--
-- Name: IX_invoices_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_invoices_booking_id" ON public.invoices USING btree (booking_id);


--
-- Name: IX_invoices_invoice_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_invoices_invoice_number" ON public.invoices USING btree (invoice_number);


--
-- Name: IX_invoices_issued_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_invoices_issued_at" ON public.invoices USING btree (issued_at);


--
-- Name: IX_invoices_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_invoices_user_id" ON public.invoices USING btree (user_id);


--
-- Name: IX_login_history_UserId1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_login_history_UserId1" ON public.login_history USING btree ("UserId1");


--
-- Name: IX_login_history_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_login_history_created_at" ON public.login_history USING btree (created_at);


--
-- Name: IX_login_history_ip_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_login_history_ip_address" ON public.login_history USING btree (ip_address);


--
-- Name: IX_login_history_is_successful; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_login_history_is_successful" ON public.login_history USING btree (is_successful);


--
-- Name: IX_login_history_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_login_history_user_id" ON public.login_history USING btree (user_id);


--
-- Name: IX_login_history_user_id_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_login_history_user_id_created_at" ON public.login_history USING btree (user_id, created_at);


--
-- Name: IX_tour_reviews_TourId1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_tour_reviews_TourId1" ON public.tour_reviews USING btree ("TourId1");


--
-- Name: IX_tour_reviews_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_tour_reviews_booking_id" ON public.tour_reviews USING btree (booking_id);


--
-- Name: IX_tour_reviews_is_approved; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_tour_reviews_is_approved" ON public.tour_reviews USING btree (is_approved);


--
-- Name: IX_tour_reviews_rating; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_tour_reviews_rating" ON public.tour_reviews USING btree (rating);


--
-- Name: IX_tour_reviews_tour_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_tour_reviews_tour_id" ON public.tour_reviews USING btree (tour_id);


--
-- Name: IX_tour_reviews_tour_id_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_tour_reviews_tour_id_user_id" ON public.tour_reviews USING btree (tour_id, user_id);


--
-- Name: IX_tour_reviews_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_tour_reviews_user_id" ON public.tour_reviews USING btree (user_id);


--
-- Name: IX_user_favorites_tour_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_user_favorites_tour_id" ON public.user_favorites USING btree (tour_id);


--
-- Name: IX_user_favorites_user_id_tour_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_user_favorites_user_id_tour_id" ON public.user_favorites USING btree (user_id, tour_id);


--
-- Name: IX_user_two_factor_UserId1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_user_two_factor_UserId1" ON public.user_two_factor USING btree ("UserId1");


--
-- Name: IX_user_two_factor_is_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_user_two_factor_is_enabled" ON public.user_two_factor USING btree (is_enabled);


--
-- Name: IX_user_two_factor_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "IX_user_two_factor_user_id" ON public.user_two_factor USING btree (user_id);


--
-- Name: IX_waitlist_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_waitlist_is_active" ON public.waitlist USING btree (is_active);


--
-- Name: IX_waitlist_is_notified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_waitlist_is_notified" ON public.waitlist USING btree (is_notified);


--
-- Name: IX_waitlist_tour_date_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_waitlist_tour_date_id" ON public.waitlist USING btree (tour_date_id);


--
-- Name: IX_waitlist_tour_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_waitlist_tour_id" ON public.waitlist USING btree (tour_id);


--
-- Name: IX_waitlist_tour_id_tour_date_id_is_active_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_waitlist_tour_id_tour_date_id_is_active_priority" ON public.waitlist USING btree (tour_id, tour_date_id, is_active, priority);


--
-- Name: IX_waitlist_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "IX_waitlist_user_id" ON public.waitlist USING btree (user_id);


--
-- Name: idx_bookings_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bookings_country_id ON public.bookings USING btree (country_id) WHERE (country_id IS NOT NULL);


--
-- Name: idx_countries_active_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_countries_active_order ON public.countries USING btree (is_active, display_order);


--
-- Name: idx_countries_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_countries_code ON public.countries USING btree (code);


--
-- Name: idx_sms_notifications_booking_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sms_notifications_booking_id ON public.sms_notifications USING btree (booking_id);


--
-- Name: idx_sms_notifications_provider_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sms_notifications_provider_id ON public.sms_notifications USING btree (provider_message_id);


--
-- Name: idx_sms_notifications_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sms_notifications_status ON public.sms_notifications USING btree (status);


--
-- Name: idx_sms_notifications_status_scheduled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sms_notifications_status_scheduled ON public.sms_notifications USING btree (status, scheduled_for);


--
-- Name: idx_sms_notifications_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sms_notifications_user_id ON public.sms_notifications USING btree (user_id);


--
-- Name: idx_tour_categories_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_categories_active ON public.tour_categories USING btree (is_active);


--
-- Name: idx_tour_categories_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_tour_categories_slug ON public.tour_categories USING btree (slug);


--
-- Name: idx_tour_category_assignments_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_category_assignments_category ON public.tour_category_assignments USING btree (category_id);


--
-- Name: idx_tour_category_assignments_tour; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_category_assignments_tour ON public.tour_category_assignments USING btree (tour_id);


--
-- Name: idx_tour_tag_assignments_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_tag_assignments_tag ON public.tour_tag_assignments USING btree (tag_id);


--
-- Name: idx_tour_tag_assignments_tour; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tour_tag_assignments_tour ON public.tour_tag_assignments USING btree (tour_id);


--
-- Name: idx_tour_tags_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_tour_tags_slug ON public.tour_tags USING btree (slug);


--
-- Name: idx_tours_tour_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tours_tour_date ON public.tours USING btree (tour_date) WHERE (tour_date IS NOT NULL);


--
-- Name: idx_users_email_verification_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_email_verification_token ON public.users USING btree (email_verification_token);


--
-- Name: uq_tour_category; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_tour_category ON public.tour_category_assignments USING btree (tour_id, category_id);


--
-- Name: uq_tour_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_tour_tag ON public.tour_tag_assignments USING btree (tour_id, tag_id);


--
-- Name: analytics_events FK_analytics_events_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_events
    ADD CONSTRAINT "FK_analytics_events_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: blog_comments FK_blog_comments_blog_comments_ParentCommentId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT "FK_blog_comments_blog_comments_ParentCommentId" FOREIGN KEY ("ParentCommentId") REFERENCES public.blog_comments("Id") ON DELETE CASCADE;


--
-- Name: blog_comments FK_blog_comments_pages_BlogPostId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT "FK_blog_comments_pages_BlogPostId" FOREIGN KEY ("BlogPostId") REFERENCES public.pages(id) ON DELETE CASCADE;


--
-- Name: blog_comments FK_blog_comments_users_UserId; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT "FK_blog_comments_users_UserId" FOREIGN KEY ("UserId") REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: coupon_usages FK_coupon_usages_bookings_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupon_usages
    ADD CONSTRAINT "FK_coupon_usages_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;


--
-- Name: coupon_usages FK_coupon_usages_coupons_coupon_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupon_usages
    ADD CONSTRAINT "FK_coupon_usages_coupons_coupon_id" FOREIGN KEY (coupon_id) REFERENCES public.coupons(id) ON DELETE CASCADE;


--
-- Name: coupon_usages FK_coupon_usages_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupon_usages
    ADD CONSTRAINT "FK_coupon_usages_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: coupons FK_coupons_tours_applicable_tour_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.coupons
    ADD CONSTRAINT "FK_coupons_tours_applicable_tour_id" FOREIGN KEY (applicable_tour_id) REFERENCES public.tours(id) ON DELETE SET NULL;


--
-- Name: invoices FK_invoices_bookings_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "FK_invoices_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE RESTRICT;


--
-- Name: invoices FK_invoices_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "FK_invoices_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: login_history FK_login_history_users_UserId1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT "FK_login_history_users_UserId1" FOREIGN KEY ("UserId1") REFERENCES public.users(id);


--
-- Name: login_history FK_login_history_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.login_history
    ADD CONSTRAINT "FK_login_history_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: sms_notifications FK_sms_notifications_bookings_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications
    ADD CONSTRAINT "FK_sms_notifications_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL;


--
-- Name: sms_notifications FK_sms_notifications_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications
    ADD CONSTRAINT "FK_sms_notifications_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tour_category_assignments FK_tour_category_assignments_tour_categories_category_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_category_assignments
    ADD CONSTRAINT "FK_tour_category_assignments_tour_categories_category_id" FOREIGN KEY (category_id) REFERENCES public.tour_categories(id) ON DELETE CASCADE;


--
-- Name: tour_category_assignments FK_tour_category_assignments_tours_tour_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_category_assignments
    ADD CONSTRAINT "FK_tour_category_assignments_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES public.tours(id) ON DELETE CASCADE;


--
-- Name: tour_reviews FK_tour_reviews_bookings_booking_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT "FK_tour_reviews_bookings_booking_id" FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE SET NULL;


--
-- Name: tour_reviews FK_tour_reviews_tours_TourId1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT "FK_tour_reviews_tours_TourId1" FOREIGN KEY ("TourId1") REFERENCES public.tours(id);


--
-- Name: tour_reviews FK_tour_reviews_tours_tour_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT "FK_tour_reviews_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES public.tours(id) ON DELETE CASCADE;


--
-- Name: tour_reviews FK_tour_reviews_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT "FK_tour_reviews_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: tour_tag_assignments FK_tour_tag_assignments_tour_tags_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_tag_assignments
    ADD CONSTRAINT "FK_tour_tag_assignments_tour_tags_tag_id" FOREIGN KEY (tag_id) REFERENCES public.tour_tags(id) ON DELETE CASCADE;


--
-- Name: tour_tag_assignments FK_tour_tag_assignments_tours_tour_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tour_tag_assignments
    ADD CONSTRAINT "FK_tour_tag_assignments_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES public.tours(id) ON DELETE CASCADE;


--
-- Name: user_favorites FK_user_favorites_tours_tour_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT "FK_user_favorites_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES public.tours(id) ON DELETE CASCADE;


--
-- Name: user_favorites FK_user_favorites_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_favorites
    ADD CONSTRAINT "FK_user_favorites_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_two_factor FK_user_two_factor_users_UserId1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor
    ADD CONSTRAINT "FK_user_two_factor_users_UserId1" FOREIGN KEY ("UserId1") REFERENCES public.users(id);


--
-- Name: user_two_factor FK_user_two_factor_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_two_factor
    ADD CONSTRAINT "FK_user_two_factor_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: waitlist FK_waitlist_tour_dates_tour_date_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waitlist
    ADD CONSTRAINT "FK_waitlist_tour_dates_tour_date_id" FOREIGN KEY (tour_date_id) REFERENCES public.tour_dates(id) ON DELETE SET NULL;


--
-- Name: waitlist FK_waitlist_tours_tour_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waitlist
    ADD CONSTRAINT "FK_waitlist_tours_tour_id" FOREIGN KEY (tour_id) REFERENCES public.tours(id) ON DELETE CASCADE;


--
-- Name: waitlist FK_waitlist_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.waitlist
    ADD CONSTRAINT "FK_waitlist_users_user_id" FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bookings fk_bookings_country_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT fk_bookings_country_id FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict Z5mBRPBsw3rwvhgCvq2OVyWVsdadaNAfgGpMawtba3tOHV7kM1tmarXCAeWsyW5

