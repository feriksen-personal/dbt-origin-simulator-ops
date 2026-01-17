-- jaffle_crm baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed campaigns (created 30 days ago, campaign dates relative to creation)
INSERT INTO jaffle_crm.campaigns (campaign_id, campaign_name, start_date, end_date, budget, created_at, updated_at, deleted_at) VALUES
(1, 'Spring Sale 2024', CURRENT_DATE - 25, CURRENT_DATE + 5, 5000.00, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours', NULL),
(2, 'Summer Promotion', CURRENT_DATE - 15, CURRENT_DATE + 15, 7500.00, CURRENT_TIMESTAMP - INTERVAL '20 days' + INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '20 days' + INTERVAL '10 hours', NULL),
(3, 'Back to School', CURRENT_DATE - 5, CURRENT_DATE + 25, 6000.00, CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '14 hours', CURRENT_TIMESTAMP - INTERVAL '10 days' + INTERVAL '14 hours', NULL);

-- Seed email activity (events from last 5 days, append-only)
INSERT INTO jaffle_crm.email_activity (activity_id, customer_id, campaign_id, sent_date, opened, clicked, created_at, updated_at, deleted_at) VALUES
(1, 1, 1, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours', true, true, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours', NULL),
(2, 2, 1, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours' + INTERVAL '5 minutes', true, false, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours' + INTERVAL '5 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours' + INTERVAL '5 minutes', NULL),
(3, 3, 1, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours' + INTERVAL '10 minutes', false, false, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours' + INTERVAL '10 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours' + INTERVAL '10 minutes', NULL),
(4, 4, 2, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '14 hours', true, true, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '14 hours', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '14 hours', NULL),
(5, 5, 2, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '14 hours' + INTERVAL '5 minutes', true, true, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '14 hours' + INTERVAL '5 minutes', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '14 hours' + INTERVAL '5 minutes', NULL);

-- Seed web sessions (activity from last 5 days)
INSERT INTO jaffle_crm.web_sessions (session_id, customer_id, session_start, session_end, page_views, created_at, updated_at, deleted_at) VALUES
(1, 1, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '9 hours', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '9 hours' + INTERVAL '30 minutes', 12, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '9 hours' + INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '9 hours' + INTERVAL '30 minutes', NULL),
(2, 2, CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '10 hours' + INTERVAL '15 minutes', 5, CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '10 hours' + INTERVAL '15 minutes', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '10 hours' + INTERVAL '15 minutes', NULL),
(3, 3, CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '15 hours', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '15 hours' + INTERVAL '45 minutes', 20, CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '15 hours' + INTERVAL '45 minutes', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '15 hours' + INTERVAL '45 minutes', NULL),
(4, 4, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours' + INTERVAL '25 minutes', 8, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours' + INTERVAL '25 minutes', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours' + INTERVAL '25 minutes', NULL),
(5, 5, CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '16 hours', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '16 hours' + INTERVAL '10 minutes', 3, CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '16 hours' + INTERVAL '10 minutes', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '16 hours' + INTERVAL '10 minutes', NULL);
