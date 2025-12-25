--
-- PostgreSQL database dump
--

\restrict R8t8z32I7ueafb4F0KXeua63gMg7WHYmQzRWJZjL9Otkch0WZt22nXatWnq50UF

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

DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_roles;
DROP TABLE IF EXISTS public.tours;
DROP TABLE IF EXISTS public.tour_images;
DROP TABLE IF EXISTS public.tour_dates;
DROP TABLE IF EXISTS public.roles;
DROP TABLE IF EXISTS public.refresh_tokens;
DROP TABLE IF EXISTS public.payments;
DROP TABLE IF EXISTS public.password_reset_tokens;
DROP TABLE IF EXISTS public.pages;
DROP TABLE IF EXISTS public.media_files;
DROP TABLE IF EXISTS public.home_page_content;
DROP TABLE IF EXISTS public.email_notifications;
DROP TABLE IF EXISTS public.bookings;
DROP TABLE IF EXISTS public.booking_participants;
DROP TABLE IF EXISTS public.audit_logs;
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
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: release_tour_spots(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.release_tour_spots(p_tour_id uuid, p_tour_date_id uuid, p_participants integer) OWNER TO postgres;

--
-- Name: reserve_tour_spots(uuid, uuid, integer); Type: FUNCTION; Schema: public; Owner: postgres
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


ALTER FUNCTION public.reserve_tour_spots(p_tour_id uuid, p_tour_date_id uuid, p_participants integer) OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: DataProtectionKeys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DataProtectionKeys" (
    "Id" integer NOT NULL,
    "FriendlyName" text,
    "Xml" text
);


ALTER TABLE public."DataProtectionKeys" OWNER TO postgres;

--
-- Name: DataProtectionKeys_Id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
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
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: booking_participants; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.booking_participants OWNER TO postgres;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: postgres
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
    CONSTRAINT chk_booking_status CHECK ((status = ANY (ARRAY[1, 2, 3, 4, 5]))),
    CONSTRAINT chk_participants_positive CHECK ((number_of_participants > 0)),
    CONSTRAINT chk_total_amount_positive CHECK ((total_amount >= (0)::numeric))
);


ALTER TABLE public.bookings OWNER TO postgres;

--
-- Name: email_notifications; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.email_notifications OWNER TO postgres;

--
-- Name: home_page_content; Type: TABLE; Schema: public; Owner: postgres
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
    logo_url_social character varying(500)
);


ALTER TABLE public.home_page_content OWNER TO postgres;

--
-- Name: media_files; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.media_files OWNER TO postgres;

--
-- Name: pages; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.pages OWNER TO postgres;

--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- Name: TABLE password_reset_tokens; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.password_reset_tokens IS 'Tokens para recuperaciÃ³n de contraseÃ±a. Expiran en 15 minutos y son de un solo uso.';


--
-- Name: COLUMN password_reset_tokens.token; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.password_reset_tokens.token IS 'Token Ãºnico (UUID sin guiones) para resetear contraseÃ±a';


--
-- Name: COLUMN password_reset_tokens.expires_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.password_reset_tokens.expires_at IS 'Fecha y hora de expiraciÃ³n del token (15 minutos desde creaciÃ³n)';


--
-- Name: COLUMN password_reset_tokens.is_used; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.password_reset_tokens.is_used IS 'Indica si el token ya fue utilizado (un solo uso)';


--
-- Name: COLUMN password_reset_tokens.used_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.password_reset_tokens.used_at IS 'Fecha y hora en que se utilizÃ³ el token';


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
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
    CONSTRAINT chk_currency_length CHECK ((length((currency)::text) = 3)),
    CONSTRAINT chk_payment_amount_positive CHECK ((amount > (0)::numeric)),
    CONSTRAINT chk_payment_provider CHECK ((provider = ANY (ARRAY[1, 2, 3]))),
    CONSTRAINT chk_payment_status CHECK ((status = ANY (ARRAY[1, 2, 3, 4, 5])))
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: tour_dates; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.tour_dates OWNER TO postgres;

--
-- Name: tour_images; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.tour_images OWNER TO postgres;

--
-- Name: tours; Type: TABLE; Schema: public; Owner: postgres
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
    CONSTRAINT chk_available_spots CHECK (((available_spots >= 0) AND (available_spots <= max_capacity))),
    CONSTRAINT chk_capacity_positive CHECK ((max_capacity > 0)),
    CONSTRAINT chk_duration_positive CHECK ((duration_hours > 0)),
    CONSTRAINT chk_price_positive CHECK ((price >= (0)::numeric))
);


ALTER TABLE public.tours OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
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
    CONSTRAINT chk_email_format CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT chk_failed_attempts CHECK ((failed_login_attempts >= 0))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: DataProtectionKeys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."DataProtectionKeys" ("Id", "FriendlyName", "Xml") FROM stdin;
1	key-619536ab-eb6f-4a07-9521-b045c1b4826c	<key id="619536ab-eb6f-4a07-9521-b045c1b4826c" version="1"><creationDate>2025-12-24T23:57:52.1021052Z</creationDate><activationDate>2025-12-24T23:57:51.8097607Z</activationDate><expirationDate>2026-03-24T23:57:51.8097607Z</expirationDate><descriptor deserializerType="Microsoft.AspNetCore.DataProtection.AuthenticatedEncryption.ConfigurationModel.AuthenticatedEncryptorDescriptorDeserializer, Microsoft.AspNetCore.DataProtection, Version=8.0.0.0, Culture=neutral, PublicKeyToken=adb9793829ddae60"><descriptor><encryption algorithm="AES_256_CBC" /><validation algorithm="HMACSHA256" /><masterKey p4:requiresEncryption="true" xmlns:p4="http://schemas.asp.net/2015/03/dataProtection"><!-- Warning: the key below is in an unencrypted form. --><value>QumhzP/6HFyEWusYt9wgVbeMW4i7ztkc64z3Hl+Ed3gnH6y6L3mjUV7OS6FrfbqQR1tELVQ/rgxQH0KPHGm3Lw==</value></masterKey></descriptor></descriptor></key>
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
\.


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
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
\.


--
-- Data for Name: booking_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.booking_participants (id, booking_id, first_name, last_name, email, phone, date_of_birth, special_requirements, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookings (id, user_id, tour_id, tour_date_id, status, number_of_participants, total_amount, expires_at, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: email_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_notifications (id, user_id, booking_id, type, status, to_email, subject, body, sent_at, retry_count, error_message, scheduled_for, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: home_page_content; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.home_page_content (id, hero_title, hero_subtitle, hero_search_placeholder, hero_search_button, tours_section_title, tours_section_subtitle, loading_tours_text, error_loading_tours_text, no_tours_found_text, footer_brand_text, footer_description, footer_copyright, nav_brand_text, nav_tours_link, nav_bookings_link, nav_login_link, nav_logout_button, page_title, meta_description, created_at, updated_at, logo_url, favicon_url, logo_url_social) FROM stdin;
293baed3-de72-41ec-bd62-e9ce183d2391	Título del Hero	Subtítulo del Hero	Buscar tours...	Buscar	Título de la Sección de Tours	Subtítulo de la Sección de Tours	Cargando tours...	Error al cargar los tours. Por favor, intenta de nuevo.	No se encontraron tours disponibles.	Texto de la Marca del Footer	Descripción del Footer	Copyright del Footer	Texto de la Marca en Nav	Link Nav: Tours	Link Nav: Reservas	Link Nav: Login	Logout	Título de la Página (SEO)	Meta Description (SEO)	2025-12-25 07:04:26.964582	2025-12-25 07:15:20.969202	\N	\N	\N
\.


--
-- Data for Name: media_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.media_files (id, file_name, file_path, file_url, mime_type, file_size, alt_text, description, category, is_image, width, height, uploaded_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: pages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pages (id, title, slug, content, excerpt, meta_title, meta_description, meta_keywords, is_published, published_at, template, display_order, created_by, updated_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (id, user_id, token, expires_at, is_used, used_at, ip_address, user_agent, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, booking_id, provider, status, amount, provider_transaction_id, provider_payment_intent_id, currency, authorized_at, captured_at, refunded_at, failure_reason, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
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
514b6ba6-d070-4a05-8701-cb4831bc04f8	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	A1OyszIKMlLT6SKLyO7NMrdnTSzcmp/vVRmdfU20XEQthfkg9ny4eVY7khRIj4V1gsfXPS+yZRkcxTir0popiA==	2026-01-01 07:37:49.761401	f	\N	\N	::1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	2025-12-25 07:37:49.837695	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, name, description, created_at, updated_at) FROM stdin;
65a8d225-6334-4ee1-ad4d-4f08e25e0b19	Admin	Administrador del sistema	2025-12-25 03:22:07.892489	\N
fd3015ee-40f9-4291-946d-12f81f8bf023	Customer	Cliente del sistema	2025-12-25 03:22:07.892489	\N
\.


--
-- Data for Name: tour_dates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tour_dates (id, tour_id, tour_date_time, available_spots, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tour_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tour_images (id, tour_id, image_url, alt_text, display_order, is_primary, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tours (id, name, description, itinerary, price, max_capacity, duration_hours, location, is_active, available_spots, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (id, user_id, role_id, created_at, updated_at) FROM stdin;
5ff56d75-d881-4310-a512-76da4accd67f	0c5faf03-a38a-46ae-9551-0dddf68aa377	fd3015ee-40f9-4291-946d-12f81f8bf023	2025-12-25 03:22:07.892489	\N
12a0cfa4-09f8-4d64-8970-0e262ba3e858	96b3fec6-5cc8-4465-8add-4e5d141303ee	fd3015ee-40f9-4291-946d-12f81f8bf023	2025-12-25 03:22:07.892489	\N
77934bf4-436c-4377-bcc3-aa1d7e8a39e7	abe50eb1-71cd-40c3-b93c-442476bcd6df	fd3015ee-40f9-4291-946d-12f81f8bf023	2025-12-25 03:22:07.892489	\N
aeecec35-0b57-4a4c-8eed-37d9814ca254	24e8864d-7bbf-4fdf-b59a-0cfa3b882386	65a8d225-6334-4ee1-ad4d-4f08e25e0b19	2025-12-25 04:03:06.957778	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, first_name, last_name, phone, is_active, failed_login_attempts, locked_until, last_login_at, created_at, updated_at) FROM stdin;
0c5faf03-a38a-46ae-9551-0dddf68aa377	cliente@panamatravelhub.com	$2a$12$X.2F9VbuoACkGtef4FHzgOAtjKUBOqJ3LSCsSKuGVMIGfXYDOYJEO	Cliente	Ejemplo	\N	t	0	\N	\N	2025-12-25 03:22:07.892489	2025-12-25 03:22:07.892489
96b3fec6-5cc8-4465-8add-4e5d141303ee	test1@panamatravelhub.com	$2a$12$Ri/d.wxDYf9VUKlt3d11wOsbt9ZuKdABoVzlDgzinawkwPCQPhzmu	Usuario	Prueba 1	\N	t	0	\N	\N	2025-12-25 03:22:07.892489	2025-12-25 03:22:07.892489
abe50eb1-71cd-40c3-b93c-442476bcd6df	test2@panamatravelhub.com	$2a$12$KhUrJxHZ966YuuRZgqtvM.FIvFbAiuoGDi25G7OPhQKkjJqfBGyx.	Usuario	Prueba 2	\N	t	0	\N	\N	2025-12-25 03:22:07.892489	2025-12-25 03:22:07.892489
24e8864d-7bbf-4fdf-b59a-0cfa3b882386	admin@panamatravelhub.com	$2a$12$gpmcPqtakrNDl29T9mDeqOjzeVjACvG/RRyjAdxH3.u58TZG6g8yS	Administrador	Sistema	\N	t	0	\N	2025-12-25 07:37:49.54644	2025-12-25 03:22:07.892489	2025-12-25 03:22:07.892489
\.


--
-- Name: DataProtectionKeys_Id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."DataProtectionKeys_Id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

\unrestrict R8t8z32I7ueafb4F0KXeua63gMg7WHYmQzRWJZjL9Otkch0WZt22nXatWnq50UF

