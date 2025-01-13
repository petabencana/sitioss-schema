CREATE SCHEMA IF NOT EXISTS logistics
    AUTHORIZATION postgres;

-- Create Enum type if it doesn't exist
-- CREATE TYPE IF NOT EXISTS logistics.need_status_type AS ENUM ('expired', 'satisfied');
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'logistics.need_status_type') THEN
        create type logistics.need_status_type AS ENUM ('ACTIVE','EXPIRED', 'SATISFIED');
    END IF;
END
$$;

-- Create Sequence if it doesn't exist
CREATE SEQUENCE IF NOT EXISTS logistics.need_reports_seq START 1;

-- Table: logistics.need_reports

-- DROP TABLE IF EXISTS logistics.need_reports;

ALTER TABLE IF EXISTS logistics.need_reports
    ADD CONSTRAINT need_reports_pkey PRIMARY KEY (id);

CREATE TABLE IF NOT EXISTS logistics.need_reports
(
    id integer NOT NULL DEFAULT nextval('logistics.need_reports_seq'::regclass),
    need_user_id character varying COLLATE pg_catalog."default",
    the_geom geometry,
    created_date timestamp with time zone NOT NULL DEFAULT now(),
    quantity_requested character varying COLLATE pg_catalog."default",
    item_requested character varying COLLATE pg_catalog."default",
    need_language character varying COLLATE pg_catalog."default" NOT NULL,
    status logistics.need_status_type,
    description character varying COLLATE pg_catalog."default",
    units character varying COLLATE pg_catalog."default" NOT NULL,
    item_id character varying COLLATE pg_catalog."default" NOT NULL,
    need_request_id character varying COLLATE pg_catalog."default" NOT NULL,
    updated_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT need_reports_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

-- Add is_training column
ALTER TABLE IF EXISTS logistics.need_reports
    ADD COLUMN is_training BOOLEAN DEFAULT FALSE;

ALTER TABLE IF EXISTS logistics.need_reports
    OWNER to postgres;
-- Index: fki_need_reports_fkey



CREATE INDEX IF NOT EXISTS fki_need_reports_fkey
    ON logistics.need_reports USING btree
    (need_user_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: fki_need_user_fkey


CREATE INDEX IF NOT EXISTS fki_need_user_fkey
    ON logistics.need_reports USING btree
    (need_user_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS logistics.need_user_associations
(
    need_id integer NOT NULL,
    user_id character varying COLLATE pg_catalog."default" NOT NULL,
    need_language character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT need_user_associations_pkey PRIMARY KEY (need_id, user_id),
    CONSTRAINT need_user_associations_need_fkey FOREIGN KEY (need_id)
        REFERENCES logistics.need_reports (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS logistics.need_user_associations
    OWNER to postgres;

CREATE TABLE IF NOT EXISTS logistics.giver_details
(
    giver_id character varying COLLATE pg_catalog."default" NOT NULL,
    quantity_satisfied character varying COLLATE pg_catalog."default",
    promised_date character varying COLLATE pg_catalog."default",
    promised_time character varying COLLATE pg_catalog."default",
    giver_language character varying COLLATE pg_catalog."default",
    need_id integer,
    item_satisfied character varying COLLATE pg_catalog."default",
    delivery_code character varying COLLATE pg_catalog."default" NOT NULL,
    date_extended boolean NOT NULL DEFAULT false,
    CONSTRAINT need_id_fkey FOREIGN KEY (need_id)
        REFERENCES logistics.need_reports (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
        NOT VALID
)

TABLESPACE pg_default;

-- ALTER TABLE IF EXISTS logistics.need_user_associations
--     ADD CONSTRAINT need_user_associations_need_fkey FOREIGN KEY (need_id);
--     ADD CONSTRAINT need_user_associations_pkey UNIQUE (need_id, user_id);
--     REFERENCES logistics.need_reports (id) MATCH SIMPLE
--     ON UPDATE NO ACTION
--     ON DELETE NO ACTION;


ALTER TABLE IF EXISTS logistics.giver_details
    OWNER to postgres;
-- Index: fki_need_id_fkey

-- ALTER TABLE IF EXISTS logistics.giver_details
--     ADD CONSTRAINT need_id_fkey FOREIGN KEY (need_id)
--     REFERENCES logistics.need_reports (id) MATCH SIMPLE
--     ON UPDATE NO ACTION
--     ON DELETE CASCADE
--     NOT VALID;


CREATE INDEX IF NOT EXISTS fki_need_id_fkey
    ON logistics.giver_details USING btree
    (need_id ASC NULLS LAST)
    TABLESPACE pg_default;

