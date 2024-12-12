CREATE SCHEMA IF NOT EXISTS subscriptions
    AUTHORIZATION postgres;

CREATE TABLE IF NOT EXISTS subscriptions.subscriptions_table
(
    id bigint NOT NULL DEFAULT nextval('subscriptions.subscription_pkey_seq'::regclass),
    user_id character varying COLLATE pg_catalog."default" NOT NULL,
    language_code character varying COLLATE pg_catalog."default" NOT NULL,
    created_date timestamp with time zone DEFAULT now(),
    network character varying COLLATE pg_catalog."default",
    "isSuperuser" boolean NOT NULL DEFAULT false,
    CONSTRAINT subscriptions_table_pkey PRIMARY KEY (user_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS subscriptions.subscriptions_table
    OWNER to postgres;

ALTER TABLE IF EXISTS subscriptions.subscriptions_table
    ADD CONSTRAINT subscriptions_table_pkey PRIMARY KEY (user_id);

CREATE TABLE IF NOT EXISTS subscriptions.region_details
(
    subscription_id character varying COLLATE pg_catalog."default" NOT NULL,
    region_code character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT user_region_unique_constraint UNIQUE (subscription_id, region_code),
    CONSTRAINT user_fkey FOREIGN KEY (subscription_id)
        REFERENCES subscriptions.subscriptions_table (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS subscriptions.region_details
    OWNER to postgres;
-- Index: fki_user_fkey

-- DROP INDEX IF EXISTS subscriptions.fki_user_fkey;


ALTER TABLE IF EXISTS subscriptions.region_details
    ADD CONSTRAINT user_fkey FOREIGN KEY (subscription_id)
    REFERENCES subscriptions.subscriptions_table (user_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS subscriptions.region_details
    ADD CONSTRAINT user_region_unique_constraint UNIQUE (subscription_id, region_code);

CREATE INDEX IF NOT EXISTS fki_user_fkey
    ON subscriptions.region_details USING btree
    (subscription_id COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS subscriptions.log
(
    pkey bigint NOT NULL DEFAULT nextval('subscriptions.log_pkey_seq'::regclass),
    database_time timestamp with time zone NOT NULL,
    user_id character varying COLLATE pg_catalog."default" NOT NULL,
    social_media_type character varying COLLATE pg_catalog."default" NOT NULL,
    region character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT log_pkey PRIMARY KEY (pkey)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS subscriptions.log
    OWNER to postgres;

ALTER TABLE IF EXISTS subscriptions.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (pkey);
