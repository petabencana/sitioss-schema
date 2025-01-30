CREATE OR REPLACE FUNCTION logistics.define_report_region()
  RETURNS trigger AS
$BODY$
	BEGIN
	UPDATE logistics.need_reports
    SET tags = (
        SELECT (code.x->0)::jsonb 
        FROM (
            SELECT COALESCE(array_to_json(array_agg(row_to_json(a))), '[{"instance_region_code":null}]') as x 
            FROM (
                SELECT code as instance_region_code 
                FROM cognicity.instance_regions as i 
                WHERE ST_Within(NEW.the_geom, i.the_geom)
            ) as a
        ) as code
    )
    WHERE need_request_id = NEW.need_request_id;
	RETURN NEW;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER update_need_reports_with_region
  AFTER INSERT ON logistics.need_reports
  FOR EACH ROW
  EXECUTE PROCEDURE logistics.define_report_region();

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