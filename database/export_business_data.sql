--
-- PostgreSQL database dump
--

\restrict N1DKsPqaxv5iGhToezYegjPXGJs69h32bJxtF4OZ1evOutwsSIDesNBJqNrXAPt

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

--
-- Data for Name: booking_participants; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.booking_participants (id, booking_id, first_name, last_name, email, phone, date_of_birth, special_requirements, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bookings (id, user_id, tour_id, tour_date_id, status, number_of_participants, total_amount, expires_at, notes, created_at, updated_at, country_id) FROM stdin;
\.


--
-- Data for Name: email_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.email_notifications (id, user_id, booking_id, type, status, to_email, subject, body, sent_at, retry_count, error_message, scheduled_for, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: home_page_content; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.home_page_content (id, hero_title, hero_subtitle, hero_search_placeholder, hero_search_button, tours_section_title, tours_section_subtitle, loading_tours_text, error_loading_tours_text, no_tours_found_text, footer_brand_text, footer_description, footer_copyright, nav_brand_text, nav_tours_link, nav_bookings_link, nav_login_link, nav_logout_button, page_title, meta_description, created_at, updated_at, logo_url, favicon_url, logo_url_social, hero_image_url) FROM stdin;
293baed3-de72-41ec-bd62-e9ce183d2391	AloticoPTY																			2025-12-25 07:04:26.964582	2025-12-25 18:53:03.646289	\N	\N	\N	/uploads/media/254d4445-92cd-477f-860f-235460265361.jpeg
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
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, booking_id, provider, status, amount, provider_transaction_id, provider_payment_intent_id, currency, authorized_at, captured_at, refunded_at, failure_reason, metadata, created_at, updated_at) FROM stdin;
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
659830d6-2c51-407b-bdf9-28e5db57797a	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	https://localhost:7009/uploads/tours/59307568-7999-4139-adfe-ca4aa539be88.png	\N	1	f	2025-12-26 03:12:53.645151	\N
5277e704-6d3a-4eff-808f-4eb86d4de85b	29ba9240-93ec-4c61-b0f5-a1bba83bd21b	https://localhost:7009/uploads/tours/f2dcad63-7e96-49dc-a6e7-ec302dbf54c1.png	\N	0	t	2025-12-26 03:12:53.645151	\N
\.


--
-- Data for Name: tours; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tours (id, name, description, itinerary, price, max_capacity, duration_hours, location, is_active, available_spots, created_at, updated_at, includes, tour_date) FROM stdin;
29ba9240-93ec-4c61-b0f5-a1bba83bd21b	Cebaco	Descripción del Tourqaqa\nDescripción del Touraqaqa	Descripción del Tourssss\nDescripción del Tourssss\nvvvvvvvvv\nsssssss	23.00	100	3	Panama	t	100	2025-12-25 17:38:42.669668	2025-12-26 03:12:53.612217	wswwswss\nwswsws\nwswsws\nwswswsws\nwswsws	2025-12-28 03:12:00
\.


--
-- PostgreSQL database dump complete
--

\unrestrict N1DKsPqaxv5iGhToezYegjPXGJs69h32bJxtF4OZ1evOutwsSIDesNBJqNrXAPt

