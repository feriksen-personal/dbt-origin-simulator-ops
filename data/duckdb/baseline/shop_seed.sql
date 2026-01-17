-- jaffle_shop baseline seed data
-- Matches data from infrastructure repo: scripts/02_load_baseline_data.sh

-- Seed customers (timestamps relative to today - 5 days ago)
-- Spread over 5 days to show customer acquisition pattern
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at) VALUES
(1, 'Michael', 'Scott', 'michael.scott@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '10 hours', NULL),
(2, 'Dwight', 'Schrute', 'dwight.schrute@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '14 hours', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '14 hours', NULL),
(3, 'Jim', 'Halpert', 'jim.halpert@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '11 hours', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '11 hours', NULL),
(4, 'Pam', 'Beesly', 'pam.beesly@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '9 hours', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '9 hours', NULL),
(5, 'Ryan', 'Howard', 'ryan.howard@dundermifflin.com', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '16 hours', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '16 hours', NULL);

-- Seed products (created 30 days ago - established catalog)
INSERT INTO jaffle_shop.products (product_id, name, category, price, created_at, updated_at, deleted_at) VALUES
(1, 'Laptop', 'Electronics', 999.99, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours', NULL),
(2, 'Mouse', 'Electronics', 29.99, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours' + INTERVAL '15 minutes', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours' + INTERVAL '15 minutes', NULL),
(3, 'Keyboard', 'Electronics', 79.99, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours' + INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours' + INTERVAL '30 minutes', NULL),
(4, 'Monitor', 'Electronics', 299.99, CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours' + INTERVAL '45 minutes', CURRENT_TIMESTAMP - INTERVAL '30 days' + INTERVAL '8 hours' + INTERVAL '45 minutes', NULL),
(5, 'Desk Chair', 'Furniture', 199.99, CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '10 hours', CURRENT_TIMESTAMP - INTERVAL '15 days' + INTERVAL '10 hours', NULL);

-- Seed orders (recent activity over last 5 days)
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at) VALUES
-- Order 1: Created 5 days ago, completed next day
(1, 1, CURRENT_DATE - 5, 'completed', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '14 hours', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '10 hours', NULL),
-- Order 2: Created 4 days ago, completed next day
(2, 2, CURRENT_DATE - 4, 'completed', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '9 hours', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '11 hours', NULL),
-- Order 3: Created 3 days ago, still pending
(3, 3, CURRENT_DATE - 3, 'pending', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '16 hours', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '16 hours', NULL),
-- Order 4: Created 2 days ago, completed next day
(4, 4, CURRENT_DATE - 2, 'completed', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '9 hours', NULL),
-- Order 5: Created 1 day ago, cancelled same day
(5, 5, CURRENT_DATE - 1, 'cancelled', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '13 hours', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '14 hours', NULL);

-- Seed order items (created with their orders, immutable)
INSERT INTO jaffle_shop.order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at, deleted_at) VALUES
(1, 1, 1, 1, 999.99, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '14 hours', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '14 hours', NULL),
(2, 1, 2, 2, 29.99, CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '14 hours', CURRENT_TIMESTAMP - INTERVAL '5 days' + INTERVAL '14 hours', NULL),
(3, 2, 3, 1, 79.99, CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '9 hours', CURRENT_TIMESTAMP - INTERVAL '4 days' + INTERVAL '9 hours', NULL),
(4, 3, 4, 1, 299.99, CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '16 hours', CURRENT_TIMESTAMP - INTERVAL '3 days' + INTERVAL '16 hours', NULL),
(5, 4, 5, 1, 199.99, CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours', CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '11 hours', NULL);
