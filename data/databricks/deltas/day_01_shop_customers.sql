-- erp schema (shop) Day 01 delta changes
-- Simulates business activity on Day 01 after baseline

-- Add 25 new customers

INSERT INTO origin_simulator_jaffle_corp.erp.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at) VALUES
(101, 'Brian', 'Kapoor', 'brian.kapoor101@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(102, 'Phyllis', 'Smith', 'phyllis.smith102@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(103, 'Helene', 'Cordray', 'helene.cordray103@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(104, 'Dwight', 'Kapoor', 'dwight.kapoor104@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(105, 'Brian', 'California', 'brian.california105@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(106, 'Helene', 'Filippelli', 'helene.filippelli106@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(107, 'Meredith', 'Smith', 'meredith.smith107@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(108, 'Stanley', 'Martin', 'stanley.martin108@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(109, 'Roy', 'Bratton', 'roy.bratton109@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(110, 'Clark', 'Lipton', 'clark.lipton110@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(111, 'Toby', 'Lewis', 'toby.lewis111@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(112, 'Karen', 'Withem', 'karen.withem112@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(113, 'Dwight', 'Anderson', 'dwight.anderson113@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(114, 'Meredith', 'Simms', 'meredith.simms114@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(115, 'Darryl', 'Kapoor', 'darryl.kapoor115@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(116, 'Donna', 'Lipton', 'donna.lipton116@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(117, 'Meredith', 'Hannon', 'meredith.hannon117@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(118, 'Helene', 'Hannon', 'helene.hannon118@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(119, 'Darryl', 'Hannon', 'darryl.hannon119@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(120, 'Charles', 'Palmer', 'charles.palmer120@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(121, 'Angela', 'Flenderson', 'angela.flenderson121@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(122, 'Charles', 'Flenderson', 'charles.flenderson122@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(123, 'Pam', 'Anderson', 'pam.anderson123@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(124, 'Roy', 'Packer', 'roy.packer124@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(125, 'Meredith', 'Bratton', 'meredith.bratton125@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
