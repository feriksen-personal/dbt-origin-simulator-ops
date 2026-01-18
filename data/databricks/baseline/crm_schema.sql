-- crm schema (CRM/Marketing tables) in Databricks Unity Catalog
-- Marketing/CRM system tables using Delta Lake format
-- Catalog: origin_simulator_jaffle_corp | Schema: crm

-- Create crm schema
CREATE SCHEMA IF NOT EXISTS origin_simulator_jaffle_corp.crm;

COMMENT ON SCHEMA origin_simulator_jaffle_corp.crm IS 'Customer Relationship Management (CRM) schema containing marketing campaign and customer engagement data. This schema includes marketing campaigns, email activity events, and web session events. Tables follow append-only event stream pattern for activity tables.';

-- Campaigns table
CREATE TABLE IF NOT EXISTS origin_simulator_jaffle_corp.crm.campaigns (
    campaign_id INTEGER NOT NULL COMMENT 'Unique campaign identifier',
    campaign_name VARCHAR(100) COMMENT 'Marketing campaign name',
    start_date DATE COMMENT 'Campaign start date',
    end_date DATE COMMENT 'Campaign end date',
    budget DECIMAL(10,2) COMMENT 'Campaign budget amount',
    created_at TIMESTAMP NOT NULL COMMENT 'Record creation timestamp',
    updated_at TIMESTAMP NOT NULL COMMENT 'Record last update timestamp',
    deleted_at TIMESTAMP COMMENT 'Soft delete timestamp (NULL = active, non-NULL = archived)',
    CONSTRAINT pk_campaigns PRIMARY KEY (campaign_id) NOT ENFORCED
) USING DELTA
COMMENT 'Marketing campaigns table';

-- Email activity table (append-only event stream)
CREATE TABLE IF NOT EXISTS origin_simulator_jaffle_corp.crm.email_activity (
    activity_id INTEGER NOT NULL COMMENT 'Unique email activity identifier',
    customer_id INTEGER COMMENT 'Customer who received the email',
    campaign_id INTEGER COMMENT 'Foreign key to campaigns table',
    sent_date TIMESTAMP COMMENT 'Email sent timestamp',
    opened BOOLEAN COMMENT 'Whether email was opened',
    clicked BOOLEAN COMMENT 'Whether any link was clicked',
    created_at TIMESTAMP NOT NULL COMMENT 'Record creation timestamp (when event was recorded)',
    updated_at TIMESTAMP NOT NULL COMMENT 'Record last update timestamp (rarely changes for append-only)',
    deleted_at TIMESTAMP COMMENT 'Soft delete timestamp (rarely used for immutable events)',
    CONSTRAINT pk_email_activity PRIMARY KEY (activity_id) NOT ENFORCED,
    CONSTRAINT fk_email_activity_campaign FOREIGN KEY (campaign_id) REFERENCES origin_simulator_jaffle_corp.crm.campaigns(campaign_id) NOT ENFORCED
) USING DELTA
COMMENT 'Email activity event stream table';

-- Web sessions table (append-only event stream)
CREATE TABLE IF NOT EXISTS origin_simulator_jaffle_corp.crm.web_sessions (
    session_id INTEGER NOT NULL COMMENT 'Unique web session identifier',
    customer_id INTEGER COMMENT 'Customer associated with session',
    session_start TIMESTAMP COMMENT 'Session start timestamp',
    session_end TIMESTAMP COMMENT 'Session end timestamp',
    page_views INTEGER COMMENT 'Number of pages viewed in session',
    created_at TIMESTAMP NOT NULL COMMENT 'Record creation timestamp (when session was recorded)',
    updated_at TIMESTAMP NOT NULL COMMENT 'Record last update timestamp (could update if session extends)',
    deleted_at TIMESTAMP COMMENT 'Soft delete timestamp (rarely used)',
    CONSTRAINT pk_web_sessions PRIMARY KEY (session_id) NOT ENFORCED
) USING DELTA
COMMENT 'Web session event stream table';
