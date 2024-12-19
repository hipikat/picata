--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: wagtailcore_locale; Type: TABLE DATA; Schema: public; Owner: wagtail
--

COPY public.wagtailcore_locale (id, language_code) FROM stdin;
1	en
\.


--
-- Name: wagtailcore_locale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wagtail
--

SELECT pg_catalog.setval('public.wagtailcore_locale_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

