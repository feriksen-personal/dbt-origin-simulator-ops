-- erp schema (shop) Day 03 delta changes
-- Simulates business activity on Day 03 after baseline

-- Add 28 new customers

INSERT INTO origin_simulator_jaffle_corp.erp.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at) VALUES
(148, 'Val', 'Halpert', 'val.halpert148@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(149, 'Ryan', 'Malone', 'ryan.malone149@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(150, 'Gabe', 'Johnson', 'gabe.johnson150@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(151, 'Helene', 'Tanaka', 'helene.tanaka151@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(152, 'Val', 'Vance', 'val.vance152@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(153, 'David', 'Howard', 'david.howard153@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(154, 'Toby', 'Green', 'toby.green154@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(155, 'Brian', 'Miner', 'brian.miner155@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(156, 'David', 'Tanaka', 'david.tanaka156@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(157, 'Jessica', 'Wallace', 'jessica.wallace157@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(158, 'Katy', 'Bratton', 'katy.bratton158@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(159, 'Val', 'Bernard', 'val.bernard159@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(160, 'Oscar', 'Miner', 'oscar.miner160@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(161, 'Jo', 'Flenderson', 'jo.flenderson161@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(162, 'Pam', 'Flenderson', 'pam.flenderson162@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(163, 'Deangelo', 'Smith', 'deangelo.smith163@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(164, 'Kevin', 'Flax', 'kevin.flax164@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(165, 'Dwight', 'Beesly', 'dwight.beesly165@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(166, 'Erin', 'Lipton', 'erin.lipton166@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(167, 'Creed', 'Martin', 'creed.martin167@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(168, 'Donna', 'Martinez', 'donna.martinez168@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(169, 'Jan', 'Bennett', 'jan.bennett169@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(170, 'Robert', 'Withem', 'robert.withem170@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(171, 'Todd', 'Green', 'todd.green171@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(172, 'Robert', 'Kapoor', 'robert.kapoor172@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(173, 'Gabe', 'Wallace', 'gabe.wallace173@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(174, 'Michael', 'Garfield', 'michael.garfield174@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(175, 'Jordan', 'Palmer', 'jordan.palmer175@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
