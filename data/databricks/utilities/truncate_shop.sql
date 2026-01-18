-- Truncate all erp schema (shop) tables in Databricks
-- Order matters: delete child tables before parent tables to avoid FK constraint errors

-- Delete payments first (has FK to orders)
DELETE FROM origin_simulator_jaffle_corp.erp.payments;

-- Delete order items next (has FKs to orders and products)
DELETE FROM origin_simulator_jaffle_corp.erp.order_items;

-- Delete orders next (has FK to customers)
DELETE FROM origin_simulator_jaffle_corp.erp.orders;

-- Delete products (no dependencies on it anymore)
DELETE FROM origin_simulator_jaffle_corp.erp.products;

-- Delete customers last (no dependencies on it anymore)
DELETE FROM origin_simulator_jaffle_corp.erp.customers;
