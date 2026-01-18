-- erp schema (shop) Day 02 delta changes
-- Simulates business activity on Day 02 after baseline

-- Add 22 new customers

UPDATE origin_simulator_jaffle_corp.erp.products
SET price = 1099.99,
    updated_at = CURRENT_TIMESTAMP
WHERE product_id = 1;  -- Laptop price increase
