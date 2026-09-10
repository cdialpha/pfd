-- =============================================================================
-- 00-bootstrap.sql  -  cluster-level bootstrap for the "accounts" DB
-- =============================================================================
-- Owns: roles, the DB, extensions & forward-grant policy. 
-- No schemea tables, no indexes, no columns. Those live in goose.
-- Runs 2 ways, same file:
-- local   - mounted at /docker-entrypoint-initdb.d/00-bootstrap.sql (first init only)
-- managed - psql -v ON_ERROR_STOP=1 -f 00-bootstrap.sql  (as the RDS/CloudSQL master)
-- 
-- Idempotent by construction. Safe to re-run.
-- Do NOT run w/ --single-transaction: CREATE DATABASE cannot live in a txn block.
-- =============================================================================

\set ON_ERROR_STOP on

-- psql 13+. Env is visible during initdb.d processing & from your Makefile.
\getenv db          POSTGRES_DB
\getenv migrator_pw SVC_MIGRATOR_PASSWORD
\getenv runtime_pw  SVC_RUNTIME_PASSWORD
\getenv readonly_pw SVC_READONLY_PASSWORD

-----------------------------------------------------------------
-- 1. roles
-- app_owner   - NOLOGIN group. Owns the schema & every object goose creates.
--               Never authenticates ∴ no password to rotate or leak.
-- svc_migrator- LOGIN. goose runs as this. Member of app_owner.
-- svc_runtime - LOGIN. DML only. What the Go service connects as.
-- svc_readonly- LOGIN. SELECT only. Reporting / debug / psql spelunking.

SELECT 'CREATE ROLE app_owner NOLOGIN'
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_owner')\gexec

SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', t.r, t.pw)
FROM (VALUES
        ('svc_migrator'::text, :'migrator_pw'::text),
        ('svc_runtime'::text,  :'runtime_pw'::text),
        ('svc_readonly'::text, :'readonly_pw'::text)
     ) AS t(r, pw)
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = t.r)\gexec

-- Bootstrap user must be a member of app_owner to set its default privileges.
-- No-op for a local superuser; required on managed PG where master is not one.
GRANT app_owner TO CURRENT_USER;

-- The migrator ACTS AS app_owner ∴ every object it creates is owned by
-- app_owner, and the default privileges below always fire. Decouples the
-- grant policy from whichever login role happens to run the migration.
GRANT app_owner TO svc_migrator;


--------------------------------------------------------------
-- 2. database
-- No-op locally (docker_setup_db already created it, owned by POSTGRES_USER).
-- Does the real work on a managed instance.
SELECT format('CREATE DATABASE %I OWNER app_owner', :'db')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'db')\gexec

\connect :"db"

-------------------------------------------------------
-- 3. db-level access
REVOKE ALL ON DATABASE :"db" FROM PUBLIC;
GRANT CONNECT ON DATABASE :"db" TO svc_migrator, svc_runtime, svc_readonly;

-- PG15+ already drops CREATE for PUBLIC on schema public. Belt & braces.
REVOKE ALL ON SCHEMA public FROM PUBLIC;


-- --------------------------------------------------------------
-- 4. schema
-- Lives here, NOT in goose: ALTER DEFAULT PRIVILEGES ... IN SCHEMA app
-- errors if the schema does not yet exist, and goose's version table needs
-- a home before migration 1 can run.
CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION app_owner;

GRANT USAGE ON SCHEMA app TO svc_runtime, svc_readonly;
-- svc_migrator inherits USAGE + CREATE via app_owner membership.

-- Extensions go here too (often needs superuser). Uncomment as needed.
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- CREATE EXTENSION IF NOT EXISTS citext;

-- ------------------------------------------------------
-- 5. session config
-- Auto-assume app_owner so goose never has to emit SET ROLE.
ALTER ROLE svc_migrator IN DATABASE :"db" SET role = 'app_owner';

-- Keep "public" on the path so unqualified extension f(n)s still resolve.
ALTER ROLE svc_migrator IN DATABASE :"db" SET search_path = app, public;
ALTER ROLE svc_runtime  IN DATABASE :"db" SET search_path = app, public;
ALTER ROLE svc_readonly IN DATABASE :"db" SET search_path = app, public;

-- Optional guardrails.
-- ALTER ROLE svc_runtime  IN DATABASE :"db" SET statement_timeout = '10s';
-- ALTER ROLE svc_readonly IN DATABASE :"db" SET default_transaction_read_only = on;


-- ---------------------------------------------
-- 6. forward (default) grants
-- Semantics: "FOR ROLE app_owner IN SCHEMA app" == "whenever app_owner creates
-- an object in app, pre-apply these grants". Keyed to the CREATING role, not
-- the current owner. Never retroactive. Stored in pg_default_acl (\ddp).

ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES    TO svc_runtime;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT USAGE, SELECT                   ON SEQUENCES TO svc_runtime;

ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT SELECT ON TABLES    TO svc_readonly;
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    GRANT SELECT ON SEQUENCES TO svc_readonly;

-- Never let the runtime role hold DDL.
ALTER DEFAULT PRIVILEGES FOR ROLE app_owner IN SCHEMA app
    REVOKE TRUNCATE, REFERENCES, TRIGGER ON TABLES FROM svc_runtime;


-- --------------------------------------------------------
-- 7. catch-up pass
-- No-op on a fresh cluster. Makes the file safe to re-run against a DB that
-- already has migrated objects, or to repair drift from manual DDL.
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA app TO svc_runtime;
GRANT USAGE, SELECT                  ON ALL SEQUENCES IN SCHEMA app TO svc_runtime;
GRANT SELECT                         ON ALL TABLES    IN SCHEMA app TO svc_readonly;
GRANT SELECT                         ON ALL SEQUENCES IN SCHEMA app TO svc_readonly;