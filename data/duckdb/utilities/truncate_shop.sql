-- Truncate all jaffle_shop tables
-- Order matters: delete child tables before parent tables to avoid FK constraint errors

-- Delete payments first (has FK to orders)
DELETE FROM jaffle_shop.payments;

-- Delete order items next (has FKs to orders and products)
DELETE FROM jaffle_shop.order_items;

-- Delete orders next (has FK to customers)
DELETE FROM jaffle_shop.orders;

-- Delete products (no dependencies on it anymore)
DELETE FROM jaffle_shop.products;

-- Delete customers last (no dependencies on it anymore)
DELETE FROM jaffle_shop.customers;
