-- jaffle_crm database schema
-- Marketing/CRM system tables

-- Campaigns table
CREATE TABLE IF NOT EXISTS jaffle_crm.campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(10,2),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP  -- NULL = active, non-NULL = archived
);

-- Email activity table (append-only event stream)
CREATE TABLE IF NOT EXISTS jaffle_crm.email_activity (
    activity_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    campaign_id INTEGER,
    sent_date TIMESTAMP,
    opened BOOLEAN,
    clicked BOOLEAN,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- When event was recorded
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Rarely changes (append-only)
    deleted_at TIMESTAMP,  -- Rarely used (events are immutable)
    FOREIGN KEY (campaign_id) REFERENCES jaffle_crm.campaigns(campaign_id)
);

-- Web sessions table (append-only event stream)
CREATE TABLE IF NOT EXISTS jaffle_crm.web_sessions (
    session_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    session_start TIMESTAMP,
    session_end TIMESTAMP,
    page_views INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- When session was recorded
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- Could update if session extends
    deleted_at TIMESTAMP  -- Rarely used
);
