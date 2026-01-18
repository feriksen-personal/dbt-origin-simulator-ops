-- erp schema (shop) Day 01 delta changes
-- Simulates business activity on Day 01 after baseline

-- Add 25 new customers

UPDATE origin_simulator_jaffle_corp.erp.orders
SET status = 'completed',
    updated_at = CURRENT_TIMESTAMP
WHERE order_id IN (192, 230, 219, 224, 185, 234, 202, 244, 177, 159, 243, 198, 169, 163, 212);
