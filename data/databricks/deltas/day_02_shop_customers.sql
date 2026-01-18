-- erp schema (shop) Day 02 delta changes
-- Simulates business activity on Day 02 after baseline

-- Add 22 new customers

INSERT INTO origin_simulator_jaffle_corp.erp.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at) VALUES
(126, 'Cathy', 'Beesly', 'cathy.beesly126@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(127, 'Jim', 'Smith', 'jim.smith127@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(128, 'Meredith', 'Johnson', 'meredith.johnson128@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(129, 'Brian', 'Bennett', 'brian.bennett129@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(130, 'Jo', 'Nickerson', 'jo.nickerson130@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(131, 'Gabe', 'Miller', 'gabe.miller131@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(132, 'Hide', 'Vance', 'hide.vance132@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(133, 'David', 'California', 'david.california133@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(134, 'Karen', 'Bennett', 'karen.bennett134@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(135, 'Tony', 'Miller', 'tony.miller135@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(136, 'Cathy', 'Nickerson', 'cathy.nickerson136@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(137, 'Ryan', 'Hannon', 'ryan.hannon137@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(138, 'Kelly', 'Green', 'kelly.green138@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(139, 'Michael', 'Smith', 'michael.smith139@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(140, 'Kevin', 'Schrute', 'kevin.schrute140@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(141, 'Jo', 'Schrute', 'jo.schrute141@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(142, 'Brian', 'Wallace', 'brian.wallace142@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(143, 'Erin', 'Halpert', 'erin.halpert143@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(144, 'Jordan', 'Halpert', 'jordan.halpert144@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(145, 'Nate', 'Bennett', 'nate.bennett145@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(146, 'Stanley', 'Hudson', 'stanley.hudson146@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(147, 'Senator', 'Vance', 'senator.vance147@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
