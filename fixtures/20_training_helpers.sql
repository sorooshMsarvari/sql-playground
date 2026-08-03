\set ON_ERROR_STOP on

CREATE OR REPLACE FUNCTION training.assert_true(condition boolean, message text)
RETURNS text
LANGUAGE plpgsql
AS $$
BEGIN
    IF condition IS DISTINCT FROM true THEN
        RAISE EXCEPTION 'check failed: %', message;
    END IF;
    RETURN 'ok - ' || message;
END;
$$;

ALTER ROLE sql_student SET search_path TO shop, public;

