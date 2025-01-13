CREATE OR REPLACE FUNCTION logistics.handle_expired_status()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
    IF NEW.status = 'EXPIRED' OR NEW.status = 'SATISFIED' THEN
        -- Delete from need_user_associations
        DELETE FROM logistics.need_user_associations
        WHERE need_id = NEW.id;

        -- Delete from logistics.giver_details
        DELETE FROM logistics.giver_details
        WHERE need_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION logistics.handle_expired_status()
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION logistics.update_date_column()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
  -- Check if the status has changed and is now 'in expiry'
  IF NEW.status = 'IN EXPIRY' AND NEW.status IS DISTINCT FROM OLD.status THEN
    NEW.updated_at = NOW();  -- Update 'updated_at' to current timestamp
  END IF;
  
  RETURN NEW;
END;
$BODY$;

ALTER FUNCTION logistics.update_date_column()
    OWNER TO postgres;

-- Trigger: trg_handle_expired_status


CREATE TRIGGER trg_handle_expired_status
    AFTER UPDATE 
    ON logistics.need_reports
    FOR EACH ROW
    WHEN (old.status IS DISTINCT FROM new.status)
    EXECUTE FUNCTION logistics.handle_expired_status();

-- Trigger: trg_update_date_column


CREATE TRIGGER trg_update_date_column
    BEFORE UPDATE 
    ON logistics.need_reports
    FOR EACH ROW
    EXECUTE FUNCTION logistics.update_date_column();