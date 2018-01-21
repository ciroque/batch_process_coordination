--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.2
-- Dumped by pg_dump version 9.6.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: process_batch_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE process_batch_keys (
    id bigint NOT NULL,
    process_name character varying(255),
    key integer,
    machine character varying(255),
    started_at timestamp without time zone,
    last_completed_at timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    external_id character varying(255)
);


--
-- Name: process_batch_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE process_batch_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: process_batch_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE process_batch_keys_id_seq OWNED BY process_batch_keys.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: process_batch_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY process_batch_keys ALTER COLUMN id SET DEFAULT nextval('process_batch_keys_id_seq'::regclass);


--
-- Name: process_batch_keys process_batch_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY process_batch_keys
    ADD CONSTRAINT process_batch_keys_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: process_batch_keys_process_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX process_batch_keys_process_name_index ON process_batch_keys USING btree (process_name);


--
-- Name: process_batch_keys_process_name_key_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX process_batch_keys_process_name_key_index ON process_batch_keys USING btree (process_name, key);


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20180119034358), (20180119231203), (20180119234354), (20180120171815);

