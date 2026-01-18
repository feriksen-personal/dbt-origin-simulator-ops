-- jaffle_crm database schema
-- Marketing/CRM system tables

-- Create jaffle_crm schema
CREATE SCHEMA IF NOT EXISTS jaffle_crm;

-- Note: DuckDB does not support COMMENT ON SCHEMA (only tables and columns)
-- Schema description: Customer Relationship Management (CRM) schema containing marketing campaign and customer engagement data.
-- This schema includes marketing campaigns, email activity events, and web session events.
-- Tables follow append-only event stream pattern for activity tables.

-- Campaigns table
CREATE TABLE IF NOT EXISTS jaffle_crm.campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

COMMENT ON TABLE jaffle_crm.campaigns IS 'Marketing campaigns table';
COMMENT ON COLUMN jaffle_crm.campaigns.campaign_id IS 'Unique campaign identifier';
COMMENT ON COLUMN jaffle_crm.campaigns.campaign_name IS 'Marketing campaign name';
COMMENT ON COLUMN jaffle_crm.campaigns.start_date IS 'Campaign start date';
COMMENT ON COLUMN jaffle_crm.campaigns.end_date IS 'Campaign end date';
COMMENT ON COLUMN jaffle_crm.campaigns.budget IS 'Campaign budget amount';
COMMENT ON COLUMN jaffle_crm.campaigns.created_at IS 'Record creation timestamp';
COMMENT ON COLUMN jaffle_crm.campaigns.updated_at IS 'Record last update timestamp';
COMMENT ON COLUMN jaffle_crm.campaigns.deleted_at IS 'Soft delete timestamp (NULL = active, non-NULL = archived)';

-- Email activity table (append-only event stream)
CREATE TABLE IF NOT EXISTS jaffle_crm.email_activity (
    activity_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    campaign_id INTEGER,
    sent_date TIMESTAMP,
    opened BOOLEAN,
    clicked BOOLEAN,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    FOREIGN KEY (campaign_id) REFERENCES jaffle_crm.campaigns(campaign_id)
);

COMMENT ON TABLE jaffle_crm.email_activity IS 'Email activity event stream table';
COMMENT ON COLUMN jaffle_crm.email_activity.activity_id IS 'Unique email activity identifier';
COMMENT ON COLUMN jaffle_crm.email_activity.customer_id IS 'Customer who received the email';
COMMENT ON COLUMN jaffle_crm.email_activity.campaign_id IS 'Foreign key to campaigns table';
COMMENT ON COLUMN jaffle_crm.email_activity.sent_date IS 'Email sent timestamp';
COMMENT ON COLUMN jaffle_crm.email_activity.opened IS 'Whether email was opened';
COMMENT ON COLUMN jaffle_crm.email_activity.clicked IS 'Whether any link was clicked';
COMMENT ON COLUMN jaffle_crm.email_activity.created_at IS 'Record creation timestamp (when event was recorded)';
COMMENT ON COLUMN jaffle_crm.email_activity.updated_at IS 'Record last update timestamp (rarely changes for append-only)';
COMMENT ON COLUMN jaffle_crm.email_activity.deleted_at IS 'Soft delete timestamp (rarely used for immutable events)';

-- Web sessions table (append-only event stream)
CREATE TABLE IF NOT EXISTS jaffle_crm.web_sessions (
    session_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    page_views INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

COMMENT ON TABLE jaffle_crm.web_sessions IS 'Web session event stream table';
COMMENT ON COLUMN jaffle_crm.web_sessions.session_id IS 'Unique web session identifier';
COMMENT ON COLUMN jaffle_crm.web_sessions.customer_id IS 'Customer associated with session';
COMMENT ON COLUMN jaffle_crm.web_sessions.session_start IS 'Session start timestamp';
COMMENT ON COLUMN jaffle_crm.web_sessions.session_end IS 'Session end timestamp';
COMMENT ON COLUMN jaffle_crm.web_sessions.page_views IS 'Number of pages viewed in session';
COMMENT ON COLUMN jaffle_crm.web_sessions.created_at IS 'Record creation timestamp (when session was recorded)';
COMMENT ON COLUMN jaffle_crm.web_sessions.updated_at IS 'Record last update timestamp (could update if session extends)';
COMMENT ON COLUMN jaffle_crm.web_sessions.deleted_at IS 'Soft delete timestamp (rarely used)';
