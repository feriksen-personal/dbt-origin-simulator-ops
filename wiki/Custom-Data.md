# Custom Data

Guide for adding your own test data using the **5000+ ID pattern**.

---

## Overview

While this package provides realistic baseline and delta data, you may need to add your own custom test data for:
- **Specific test cases**: Edge cases, boundary conditions
- **Training scenarios**: Custom examples for workshops
- **Development testing**: Testing your dbt models with specific data
- **Demo customization**: Company-specific examples

This guide explains how to safely add custom data without conflicting with package-managed data.

---

## When to Add Custom Data vs Modify Package

### Add Custom Data (This Guide) ✅

Use the 5000+ ID pattern when:
- You need additional test records
- You want to test edge cases
- You need temporary data for specific demos
- You're developing and testing your own dbt models
- You want to preserve custom data across some resets

**Advantages**:
- No package modification required
- Clear separation from package data
- Easy to identify custom vs package data
- Can coexist with package deltas

### Modify Package Data ❌

Consider contributing to the package repository when:
- You want to permanently change baseline data
- You need different delta patterns
- You want to add new tables
- You're improving the package for everyone

**Process**: Fork the repository, make changes, submit a pull request.

---

## ID Range Guidelines

The package uses a **reserved ID range pattern** to prevent conflicts:

| ID Range | Purpose | Owner | Examples |
|----------|---------|-------|----------|
| **1-2000** | Package-managed data | Package | Baseline + Deltas |
| **2001-4999** | Safety buffer | Reserved | (unused) |
| **5000+** | Custom user data | You | Your test data |

### Why This Matters

**Avoid Conflicts**: If you use IDs 1-2000, package deltas may:
- Fail with duplicate key errors
- Overwrite your custom data
- Create inconsistent state

**Stay Safe**: Always use IDs **5000 or higher** for custom data.

### Current Package Usage

| Table | Package Max ID | Safe Starting ID |
|-------|----------------|------------------|
| customers | 175 (after Day 3) | 5000 |
| products | 20 (baseline) | 5000 |
| orders | 680 (after Day 3) | 5000 |
| order_items | 1502 (after Day 3) | 5000 |
| payments | 374 (after Day 3) | 5000 |
| campaigns | 5 (baseline) | 5000 |
| email_activity | 250 (after Day 3) | 5000 |
| web_sessions | 300 (after Day 3) | 5000 |

**Rule of Thumb**: Start all custom IDs at **5000** to leave plenty of headroom for future package expansion.

---

## Step-by-Step Examples

### Example 1: Adding a Custom Customer

Add a test customer for a specific scenario:

```sql
-- Connect to your demo database
-- DuckDB: duckdb data/demo.duckdb
-- Azure SQL: Use your SQL client

INSERT INTO jaffle_shop.customers (
    customer_id,
    first_name,
    last_name,
    email,
    created_at,
    updated_at,
    deleted_at
) VALUES (
    5000,  -- Start at 5000
    'Alice',
    'TestUser',
    'alice.testuser@example.com',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL  -- Active customer
);
```

**Verify**:
```sql
SELECT * FROM jaffle_shop.customers WHERE customer_id >= 5000;
```

### Example 2: Adding Multiple Custom Products

Add a suite of test products:

```sql
INSERT INTO jaffle_shop.products (
    product_id,
    name,
    category,
    price,
    created_at,
    updated_at,
    deleted_at
) VALUES
(5000, 'Test Product A', 'Testing', 99.99, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 'Test Product B', 'Testing', 149.99, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5002, 'Test Product C', 'Testing', 199.99, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5003, 'Discontinued Test', 'Testing', 0.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP); -- Soft deleted
```

**Verify**:
```sql
SELECT * FROM jaffle_shop.products WHERE product_id >= 5000;
```

### Example 3: Adding a Custom Order with Items

Add a complete order with line items (respecting foreign keys):

```sql
-- Step 1: Add the order (references customer 5000)
INSERT INTO jaffle_shop.orders (
    order_id,
    customer_id,
    order_date,
    status,
    created_at,
    updated_at,
    deleted_at
) VALUES (
    5000,
    5000,  -- References our custom customer
    CURRENT_DATE,
    'pending',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
);

-- Step 2: Add order items
INSERT INTO jaffle_shop.order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    created_at,
    updated_at,
    deleted_at
) VALUES
(5000, 5000, 5000, 2, 99.99, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),  -- 2x Test Product A
(5001, 5000, 5001, 1, 149.99, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);  -- 1x Test Product B

-- Step 3: Add payment
INSERT INTO jaffle_shop.payments (
    payment_id,
    order_id,
    payment_method,
    amount,
    created_at,
    updated_at,
    deleted_at
) VALUES (
    5000,
    5000,
    'credit_card',
    349.97,  -- (2 * 99.99) + (1 * 149.99)
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
);

-- Step 4: Update order status
UPDATE jaffle_shop.orders
SET status = 'completed', updated_at = CURRENT_TIMESTAMP
WHERE order_id = 5000;
```

**Verify**:
```sql
-- Complete order view
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.status,
    COUNT(oi.order_item_id) AS line_items,
    SUM(oi.quantity * oi.unit_price) AS order_total,
    p.amount AS payment_amount
FROM jaffle_shop.orders o
LEFT JOIN jaffle_shop.customers c ON o.customer_id = c.customer_id
LEFT JOIN jaffle_shop.order_items oi ON o.order_id = oi.order_id
LEFT JOIN jaffle_shop.payments p ON o.order_id = p.order_id
WHERE o.order_id >= 5000
GROUP BY o.order_id, c.first_name, c.last_name, o.order_date, o.status, p.amount;
```

### Example 4: Adding Custom CRM Data

Add marketing campaign data:

```sql
-- Step 1: Add custom campaign
INSERT INTO jaffle_crm.campaigns (
    campaign_id,
    campaign_name,
    start_date,
    end_date,
    budget,
    created_at,
    updated_at,
    deleted_at
) VALUES (
    5000,
    'Test Campaign',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '30 days',
    5000.00,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
);

-- Step 2: Add email activity for custom campaign
INSERT INTO jaffle_crm.email_activity (
    activity_id,
    customer_id,
    campaign_id,
    sent_date,
    opened,
    clicked,
    created_at,
    updated_at,
    deleted_at
) VALUES
(5000, 5000, 5000, CURRENT_TIMESTAMP, TRUE, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 1, 5000, CURRENT_TIMESTAMP, TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),  -- Package customer
(5002, 2, 5000, CURRENT_TIMESTAMP, FALSE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);  -- Package customer

-- Step 3: Add web sessions
INSERT INTO jaffle_crm.web_sessions (
    session_id,
    customer_id,
    session_start,
    session_end,
    page_views,
    created_at,
    updated_at,
    deleted_at
) VALUES
(5000, 5000, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '15 minutes', 12, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '5 minutes', 5, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
```

**Verify**:
```sql
SELECT * FROM jaffle_crm.campaigns WHERE campaign_id >= 5000;
SELECT * FROM jaffle_crm.email_activity WHERE activity_id >= 5000;
SELECT * FROM jaffle_crm.web_sessions WHERE session_id >= 5000;
```

### Example 5: Bulk Custom Data with SQL Script

Create a reusable SQL script for custom test data:

```sql
-- custom_test_data.sql
-- Load this script after demo_load_baseline

-- Custom customers
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at)
VALUES
(5000, 'Test', 'User1', 'test.user1@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 'Test', 'User2', 'test.user2@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5002, 'Test', 'User3', 'test.user3@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Custom products
INSERT INTO jaffle_shop.products (product_id, name, category, price, created_at, updated_at, deleted_at)
VALUES
(5000, 'Test Widget', 'Test', 50.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 'Test Gadget', 'Test', 75.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Custom orders and items
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at)
VALUES
(5000, 5000, CURRENT_DATE, 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 5001, CURRENT_DATE, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

INSERT INTO jaffle_shop.order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at, deleted_at)
VALUES
(5000, 5000, 5000, 1, 50.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5001, 5000, 5001, 2, 75.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL),
(5002, 5001, 5000, 3, 50.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Custom payments
INSERT INTO jaffle_shop.payments (payment_id, order_id, payment_method, amount, created_at, updated_at, deleted_at)
VALUES
(5000, 5000, 'credit_card', 200.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
```

**Usage**:
```bash
# DuckDB
duckdb data/demo.duckdb < custom_test_data.sql

# Azure SQL (using sqlcmd)
sqlcmd -S myserver.database.windows.net -d jaffle_shop -U sqladmin -P password -i custom_test_data.sql
```

---

## Maintaining Foreign Key Relationships

When adding custom data, **always respect foreign key relationships**:

### Foreign Key Dependencies

```
jaffle_shop:
  customers (no dependencies)
    ↓
  orders (requires customer_id)
    ↓
  order_items (requires order_id and product_id)
  payments (requires order_id)

jaffle_crm:
  campaigns (no dependencies)
    ↓
  email_activity (requires campaign_id)
  web_sessions (no FK, but references customer_id logically)
```

### Rules

1. **Insert parent records first**: customers before orders, orders before order_items
2. **Use valid foreign keys**: Don't reference non-existent IDs
3. **Can mix custom and package IDs**: Custom order (5000) can reference package customer (1)

### Example: Mixing Custom and Package Data

```sql
-- Custom order for existing package customer
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at)
VALUES (5000, 1, CURRENT_DATE, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
       -- ↑ custom ID      ↑ package customer (valid)

-- Custom order item using custom order and package product
INSERT INTO jaffle_shop.order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at, deleted_at)
VALUES (5000, 5000, 1, 1, 1299.99, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
       -- ↑ custom     ↑ custom    ↑ package product (valid)
```

**This is perfectly valid**: Custom IDs can reference package IDs and vice versa.

---

## Reset Behavior

Understanding how `demo_reset` affects custom data is critical.

### What demo_reset Does

1. **Truncates ALL tables**: Removes every row (package AND custom data)
2. **Reloads baseline only**: Only package baseline data (IDs 1-2000) returns
3. **Custom data is lost**: IDs 5000+ are permanently deleted

### Example Reset Scenario

**Before reset**:
```
customers: 175 package rows + 10 custom rows = 185 total
```

**After `demo_reset`**:
```
customers: 100 baseline rows (custom data GONE)
```

### Preserving Custom Data

If you need to preserve custom data across resets, you have options:

#### Option 1: Export Before Reset

```sql
-- Export custom data
-- DuckDB
COPY (SELECT * FROM jaffle_shop.customers WHERE customer_id >= 5000) TO 'custom_customers.csv' (HEADER, DELIMITER ',');

-- Import after reset
COPY jaffle_shop.customers FROM 'custom_customers.csv' (HEADER, DELIMITER ',');
```

#### Option 2: Maintain a Custom Data Script

Keep a `custom_data.sql` script (as shown in Example 5) that you re-run after each reset:

```bash
# Reset to baseline
dbt run-operation demo_reset --profile demo_source

# Re-apply custom data
duckdb data/demo.duckdb < custom_data.sql
```

#### Option 3: Don't Use demo_reset

If you need custom data to persist:
- Use `demo_apply_delta` to progress through days
- Manually delete specific package data if needed
- Avoid `demo_reset` entirely

---

## Best Practices

### 1. Always Use IDs 5000+

**Good**:
```sql
INSERT INTO jaffle_shop.customers (customer_id, ...) VALUES (5000, ...);
```

**Bad**:
```sql
INSERT INTO jaffle_shop.customers (customer_id, ...) VALUES (176, ...);  -- Conflicts with future package expansion
```

### 2. Use Consistent ID Spacing

Leave gaps between custom records for easier management:

```sql
-- Good: 10-ID spacing
5000, 5010, 5020, 5030, ...

-- Also good: 100-ID spacing
5000, 5100, 5200, 5300, ...

-- Avoid: Sequential IDs
5000, 5001, 5002, 5003, ...  -- Hard to insert records between later
```

### 3. Document Your Custom Data

Add comments to your SQL scripts:

```sql
-- Custom customer for "Edge Case #42: Deleted customer with active orders"
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at)
VALUES (5000, 'Deleted', 'Customer', 'deleted@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Active order for deleted customer (edge case test)
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at)
VALUES (5000, 5000, CURRENT_DATE, 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
```

### 4. Maintain a Custom Data Library

Create reusable scripts for common scenarios:

```
custom_data/
├── edge_cases.sql          # Boundary conditions, nulls, etc.
├── large_orders.sql        # Orders with 50+ items
├── deleted_customers.sql   # Soft deleted customers
└── campaign_tests.sql      # CRM test scenarios
```

### 5. Version Control Your Custom Data

Commit your custom data scripts to your project repository:

```bash
git add custom_data/
git commit -m "Add custom test data for edge case testing"
```

This ensures team members can reproduce your test scenarios.

### 6. Test Foreign Key Relationships

Always verify foreign key constraints are satisfied:

```sql
-- Check for orphaned order_items
SELECT oi.*
FROM jaffle_shop.order_items oi
LEFT JOIN jaffle_shop.orders o ON oi.order_id = o.order_id
WHERE oi.order_item_id >= 5000
  AND o.order_id IS NULL;

-- Should return 0 rows
```

### 7. Use Descriptive Names for Test Data

Make it obvious that data is for testing:

```sql
-- Good
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, ...)
VALUES (5000, 'Test', 'EdgeCase', 'test.edgecase@example.com', ...);

-- Less clear
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, ...)
VALUES (5000, 'John', 'Doe', 'john.doe@example.com', ...);
```

### 8. Verify Row Counts After Adding Data

Use `demo_status` to confirm your additions:

```bash
dbt run-operation demo_status --profile demo_source
```

If you added 10 custom customers after Day 3:
```
customers: 185  (175 package + 10 custom)
```

---

## Common Scenarios

### Scenario 1: Testing Soft Deletes

```sql
-- Add active customer
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at)
VALUES (5000, 'Active', 'Customer', 'active@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Add deleted customer
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at)
VALUES (5001, 'Deleted', 'Customer', 'deleted@example.com',
        CURRENT_TIMESTAMP - INTERVAL '30 days',
        CURRENT_TIMESTAMP - INTERVAL '10 days',
        CURRENT_TIMESTAMP - INTERVAL '10 days');  -- Deleted 10 days ago
```

### Scenario 2: Testing Large Orders

```sql
-- Order with 50+ line items
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at)
VALUES (5000, 1, CURRENT_DATE, 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Generate 50 order items
INSERT INTO jaffle_shop.order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at, updated_at, deleted_at)
SELECT
    5000 + ROW_NUMBER() OVER () - 1,
    5000,
    ((ROW_NUMBER() OVER () - 1) % 20) + 1,  -- Cycle through products 1-20
    1,
    99.99,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    NULL
FROM generate_series(1, 50);  -- DuckDB syntax
```

### Scenario 3: Testing Null Values

```sql
-- Customer with minimal data
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at)
VALUES (5000, NULL, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Order with null status
INSERT INTO jaffle_shop.orders (order_id, customer_id, order_date, status, created_at, updated_at, deleted_at)
VALUES (5000, 1, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
```

### Scenario 4: Testing Cross-Database Logic

```sql
-- Customer with CRM activity but no orders
INSERT INTO jaffle_shop.customers (customer_id, first_name, last_name, email, created_at, updated_at, deleted_at)
VALUES (5000, 'CRM', 'Only', 'crm.only@example.com', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Web session (no orders)
INSERT INTO jaffle_crm.web_sessions (session_id, customer_id, session_start, session_end, page_views, created_at, updated_at, deleted_at)
VALUES (5000, 5000, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '10 minutes', 8, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);

-- Email activity (no orders)
INSERT INTO jaffle_crm.email_activity (activity_id, customer_id, campaign_id, sent_date, opened, clicked, created_at, updated_at, deleted_at)
VALUES (5000, 5000, 1, CURRENT_TIMESTAMP, TRUE, FALSE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
```

---

## Querying Custom vs Package Data

### View Only Custom Data

```sql
-- Custom customers
SELECT * FROM jaffle_shop.customers WHERE customer_id >= 5000;

-- Custom orders
SELECT * FROM jaffle_shop.orders WHERE order_id >= 5000;
```

### View Only Package Data

```sql
-- Package customers
SELECT * FROM jaffle_shop.customers WHERE customer_id < 5000;

-- Package orders
SELECT * FROM jaffle_shop.orders WHERE order_id < 5000;
```

### Count Custom vs Package Data

```sql
SELECT
    COUNT(CASE WHEN customer_id < 5000 THEN 1 END) AS package_customers,
    COUNT(CASE WHEN customer_id >= 5000 THEN 1 END) AS custom_customers,
    COUNT(*) AS total_customers
FROM jaffle_shop.customers;
```

### Mixed Query Example

```sql
-- Orders by customer type
SELECT
    CASE
        WHEN c.customer_id < 5000 THEN 'Package Customer'
        ELSE 'Custom Customer'
    END AS customer_type,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(p.amount) AS total_revenue
FROM jaffle_shop.customers c
LEFT JOIN jaffle_shop.orders o ON c.customer_id = o.customer_id
LEFT JOIN jaffle_shop.payments p ON o.order_id = p.order_id
GROUP BY customer_type;
```

---

## Troubleshooting Custom Data

### Issue: "Duplicate key violation"

**Cause**: ID already exists (conflicting with package or previous custom insert)

**Solution**:
1. Check current max ID: `SELECT MAX(customer_id) FROM jaffle_shop.customers;`
2. Use an ID higher than max: `INSERT ... VALUES (5000, ...)`

### Issue: "Foreign key constraint violation"

**Cause**: Referenced ID doesn't exist

**Solution**:
1. Verify parent record exists: `SELECT * FROM jaffle_shop.customers WHERE customer_id = 5000;`
2. Insert parent record first, then child record

### Issue: "Custom data disappeared after reset"

**Cause**: `demo_reset` truncates ALL data

**Solution**:
- Maintain a custom data script
- Re-run after each reset
- Or avoid using `demo_reset`

### Issue: "Can't find my custom data"

**Cause**: Filtering by wrong ID range

**Solution**:
```sql
-- Find ALL data (package + custom)
SELECT * FROM jaffle_shop.customers;

-- Find only custom data
SELECT * FROM jaffle_shop.customers WHERE customer_id >= 5000;
```

---

## Summary

### Quick Reference

| Topic | Guideline |
|-------|-----------|
| **ID Range** | Always use 5000+ for custom data |
| **Foreign Keys** | Insert parent records first |
| **Reset Behavior** | `demo_reset` deletes ALL data (including custom) |
| **Preservation** | Maintain SQL scripts to re-apply custom data |
| **Mixing Data** | Custom IDs can reference package IDs (and vice versa) |
| **Querying** | Use `WHERE id >= 5000` to filter custom data |

### Decision Tree

**Do I need custom data?**
- ✅ Yes → Use 5000+ ID pattern (this guide)
- ❌ No → Use package baseline and deltas

**Do I need to preserve custom data across resets?**
- ✅ Yes → Maintain custom data SQL script
- ❌ No → Add custom data ad-hoc, accept loss on reset

**Do I need to modify package data structure?**
- ✅ Yes → Fork package repository, contribute changes
- ❌ No → Use 5000+ ID pattern for new records

---

## Next Steps

- See [Data Schemas](Data-Schemas) for complete table structures and FK relationships
- See [Operations Guide](Operations-Guide) for how operations affect custom data
- See [Getting Started](Getting-Started) for installation and setup

---

**Questions?** See [FAQ](FAQ) or [open an issue](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/issues).
