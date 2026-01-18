-- Truncate all crm schema tables in Databricks
-- Order matters: delete child tables before parent tables to avoid FK constraint errors

-- Delete email activity first (has FK to campaigns)
DELETE FROM origin_simulator_jaffle_corp.crm.email_activity;

-- Delete web sessions (no FK dependencies)
DELETE FROM origin_simulator_jaffle_corp.crm.web_sessions;

-- Delete campaigns last (was referenced by email_activity)
DELETE FROM origin_simulator_jaffle_corp.crm.campaigns;
