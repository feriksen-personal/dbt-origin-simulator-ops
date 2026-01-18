-- erp schema (shop) Day 02 delta changes
-- Simulates business activity on Day 02 after baseline

-- Add 22 new customers

UPDATE origin_simulator_jaffle_corp.erp.orders
SET status = 'completed',
    updated_at = CURRENT_TIMESTAMP
WHERE order_id IN (293, 220, 281, 298, 276, 264, 214, 307, 255, 238, 232, 218);
