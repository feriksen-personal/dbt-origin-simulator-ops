# Operations Guide

Detailed reference for the four operations that manage your source systems.

---

## Overview

Four operations to control your source databases:

| Operation | Purpose | When to Use |
|-----------|---------|-------------|
| **origin_load_baseline** | Initialize databases with Day 0 seed data | First-time setup, creating fresh environment |
| **origin_apply_delta** | Apply incremental changes for day 1/2/3 | Simulating business activity, CDC demos |
| **origin_reset** | Truncate all tables and reload baseline | Starting fresh, cleaning up after testing |
| **origin_status** | Display current row counts | Quick verification, checking state |

All operations are executed via `dbt run-operation` and automatically display status at completion.

---

## Understanding Deterministic Increments

Unlike random data generators, this package provides **deterministic, reproducible data increments**. Every operation produces the same results every time.

**Baseline (Day 0):**

| Table | Rows | ID Range |
|-------|------|----------|
| customers | 100 | 1-100 |
| products | 20 | 1-20 |
| orders | 500 | 1-500 |
| order_items | 1200 | 1-1200 |
| payments | 0 | — |
| campaigns | 5 | 1-5 |
| email_activity | 100 | 1-100 |
| web_sessions | 150 | 1-150 |

**After Day 1:**

| Table | Rows | New IDs |
|-------|------|---------|
| customers | 125 | 101-125 |
| products | 20 | — |
| orders | 560 | 501-560 |
| order_items | 1303 | 1201-1303 |
| payments | 272 | 1-272 |
| campaigns | 5 | — |
| email_activity | 150 | 101-150 |
| web_sessions | 200 | 151-200 |

**After Day 2:**

| Table | Rows | New IDs |
|-------|------|---------|
| customers | 147 | 126-147 |
| products | 20 | (updates only) |
| orders | 615 | 561-615 |
| order_items | 1387 | 1304-1387 |
| payments | 316 | 273-316 |
| campaigns | 5 | — |
| email_activity | 200 | 151-200 |
| web_sessions | 250 | 201-250 |

**After Day 3:**

| Table | Rows | New IDs |
|-------|------|---------|
| customers | 175 | 148-175 |
| products | 20 | — |
| orders | 680 | 616-680 |
| order_items | 1502 | 1388-1502 |
| payments | 374 | 317-374 |
| campaigns | 5 | — |
| email_activity | 250 | 201-250 |
| web_sessions | 300 | 251-300 |

This deterministic behavior enables:

- **Verifiable outcomes** — Document exactly what should happen at each state
- **Consistent demos** — Show the same data story every time
- **Reliable CI/CD** — Assert expected row counts in automated tests
- **Effective training** — All participants see identical results

See [Data Schemas](Data-Schemas) for complete table structures and relationships.

---

## origin_load_baseline

Initializes source databases with baseline schema and data (Day 0 state).

**Creates:**

**jaffle_shop** (ERP/e-commerce):
- `customers` — Customer master data with soft delete pattern
- `products` — Product catalog with pricing
- `orders` — Order headers with status tracking
- `order_items` — Order line items
- `payments` — Payment records (empty at baseline, populated by deltas)

**jaffle_crm** (Marketing):
- `campaigns` — Marketing campaigns
- `email_activity` — Email engagement events
- `web_sessions` — Website session tracking

### When to Use

- First-time setup after installing the package
- Setting up new environments
- Clean slate without running reset

### Usage

```bash
dbt run-operation origin_load_baseline --profile ingestion_simulator
```

### Behavior Details

1. **Schema Creation**: Creates schemas/databases if they don't exist
2. **Table Creation**: Creates tables with `IF NOT EXISTS` (idempotent)
3. **Data Loading**: Inserts baseline data
   - Uses `INSERT` statements (DuckDB)
   - Uses `MERGE` for Azure SQL (upsert pattern)
4. **Foreign Key Order**: Loads in dependency order (customers → orders → order_items)

### Expected Output

```
Loading baseline schema and data...
→ Creating jaffle_shop tables...
  ✓ Created jaffle_shop schema
→ Loading jaffle_shop seed data...
  ✓ Loaded customers (100 rows)
  ✓ Loaded products (20 rows)
  ✓ Loaded orders (500 rows)
  ✓ Loaded order_items (1200 rows)
→ Creating jaffle_crm tables...
  ✓ Created jaffle_crm schema
→ Loading jaffle_crm seed data...
  ✓ Loaded campaigns (5 rows)
  ✓ Loaded email_activity (100 rows)
  ✓ Loaded web_sessions (150 rows)

✓ Baseline load complete!

═══ Demo Source Status ═══
jaffle_shop:
  customers: 100 | products: 20 | orders: 500
  order_items: 1200

jaffle_crm:
  campaigns: 5 | email_activity: 100
  web_sessions: 150
══════════════════════════
```

### Row Counts After Baseline

| Table | Row Count | ID Range |
|-------|-----------|----------|
| **jaffle_shop.customers** | 100 | 1-100 |
| **jaffle_shop.products** | 20 | 1-20 |
| **jaffle_shop.orders** | 500 | 1-500 |
| **jaffle_shop.order_items** | 1200 | 1-1200 |
| **jaffle_shop.payments** | 0 | none |
| **jaffle_crm.campaigns** | 5 | 1-5 |
| **jaffle_crm.email_activity** | 100 | 1-100 |
| **jaffle_crm.web_sessions** | 150 | 1-150 |

### Idempotency

This operation is **safe to run multiple times**:
- Table creation uses `IF NOT EXISTS`
- For DuckDB: Re-inserts data (may cause duplicates if data already exists)
- For Azure SQL: Uses `MERGE` to upsert (no duplicates)

**Best Practice**: Use `origin_reset` instead of re-running `origin_load_baseline` if data already exists.

---

## origin_apply_delta

### What It Does

Applies incremental changes for a specific day (1, 2, or 3), simulating realistic business activity over time.

Each day includes:
- New customers
- New orders and order_items
- New payments
- Order status updates
- CRM activity (emails, web sessions)
- Product updates (Day 2 only)

### When to Use

- **Incremental demos**: Showing how data changes over time
- **CDC demonstrations**: Triggering change data capture
- **Multi-day scenarios**: Training, workshops, testing
- **Sequential workflows**: Day 1 → Day 2 → Day 3 progression

### Usage

```bash
# Apply Day 1 changes
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator

# Apply Day 2 changes
dbt run-operation origin_apply_delta --args '{day: 2}' --profile ingestion_simulator

# Apply Day 3 changes
dbt run-operation origin_apply_delta --args '{day: 3}' --profile ingestion_simulator
```

**Important**: Must specify `day` parameter (1, 2, or 3)

### Day 1 Delta

**What Changes:**
- **25 new customers** (101-125)
- **60 new orders** (501-560)
- **103 new order_items** (1201-1303)
- **272 new payments** (1-272)
- Order status updates (pending → completed/shipped)
- **50 new email activities** (101-150)
- **50 new web sessions** (151-200)

**Expected Output:**

```
Applying Day 01 delta changes...
→ Applying jaffle_shop delta...
  ✓ Applied customers changes
  ✓ Applied orders changes
  ✓ Applied order_items changes
  ✓ Applied payments changes
  ✓ Applied orders status updates
→ Applying jaffle_crm delta...
  ✓ Applied email_activity changes
  ✓ Applied web_sessions changes

═══ Demo Source Status ═══
jaffle_shop:
  customers: 125 | products: 20 | orders: 560
  order_items: 1303

jaffle_crm:
  campaigns: 5 | email_activity: 150
  web_sessions: 200
══════════════════════════
```

**After Day 1 Row Counts:**

| Table | Total Rows | New IDs Added | Cumulative ID Range |
|-------|------------|---------------|---------------------|
| customers | 125 | 101-125 | 1-125 |
| products | 20 | none | 1-20 |
| orders | 560 | 501-560 | 1-560 |
| order_items | 1303 | 1201-1303 | 1-1303 |
| payments | 272 | 1-272 | 1-272 |
| campaigns | 5 | none | 1-5 |
| email_activity | 150 | 101-150 | 1-150 |
| web_sessions | 200 | 151-200 | 1-200 |

### Day 2 Delta

**What Changes:**
- **22 new customers** (126-147)
- **55 new orders** (561-615)
- **84 new order_items** (1304-1387)
- **44 new payments** (273-316)
- **Product updates** (price changes, status updates)
- Order status updates
- **50 new email activities** (151-200)
- **50 new web sessions** (201-250)

**Expected Output:**

```
Applying Day 02 delta changes...
→ Applying jaffle_shop delta...
  ✓ Applied customers changes
  ✓ Applied products updates
  ✓ Applied orders changes
  ✓ Applied order_items changes
  ✓ Applied payments changes
  ✓ Applied orders status updates
→ Applying jaffle_crm delta...
  ✓ Applied email_activity changes
  ✓ Applied web_sessions changes

═══ Demo Source Status ═══
jaffle_shop:
  customers: 147 | products: 20 | orders: 615
  order_items: 1387

jaffle_crm:
  campaigns: 5 | email_activity: 200
  web_sessions: 250
══════════════════════════
```

**After Day 2 Row Counts:**

| Table | Total Rows | New IDs Added | Cumulative ID Range |
|-------|------------|---------------|---------------------|
| customers | 147 | 126-147 | 1-147 |
| products | 20 | none (updates only) | 1-20 |
| orders | 615 | 561-615 | 1-615 |
| order_items | 1387 | 1304-1387 | 1-1387 |
| payments | 316 | 273-316 | 1-316 |
| campaigns | 5 | none | 1-5 |
| email_activity | 200 | 151-200 | 1-200 |
| web_sessions | 250 | 201-250 | 1-250 |

### Day 3 Delta

**What Changes:**
- **28 new customers** (148-175)
- **65 new orders** (616-680)
- **115 new order_items** (1388-1502)
- **58 new payments** (317-374)
- Order status updates
- **50 new email activities** (201-250)
- **50 new web sessions** (251-300)

**Expected Output:**

```
Applying Day 03 delta changes...
→ Applying jaffle_shop delta...
  ✓ Applied customers changes
  ✓ Applied orders changes
  ✓ Applied order_items changes
  ✓ Applied payments changes
  ✓ Applied orders status updates
→ Applying jaffle_crm delta...
  ✓ Applied email_activity changes
  ✓ Applied web_sessions changes

═══ Demo Source Status ═══
jaffle_shop:
  customers: 175 | products: 20 | orders: 680
  order_items: 1502

jaffle_crm:
  campaigns: 5 | email_activity: 250
  web_sessions: 300
══════════════════════════
```

**After Day 3 Row Counts:**

| Table | Total Rows | New IDs Added | Cumulative ID Range |
|-------|------------|---------------|---------------------|
| customers | 175 | 148-175 | 1-175 |
| products | 20 | none | 1-20 |
| orders | 680 | 616-680 | 1-680 |
| order_items | 1502 | 1388-1502 | 1-1502 |
| payments | 374 | 317-374 | 1-374 |
| campaigns | 5 | none | 1-5 |
| email_activity | 250 | 201-250 | 1-250 |
| web_sessions | 300 | 251-300 | 1-300 |

### Delta Behavior Details

1. **Sequential Order**: Deltas execute table-by-table in foreign key dependency order:
   - Customers (no dependencies)
   - Products (no dependencies)
   - Orders (depends on customers)
   - Order_items (depends on orders and products)
   - Payments (depends on orders)
   - Order status updates (after payments)
   - CRM tables (campaigns → email_activity, web_sessions)

2. **INSERT-only**: Deltas use INSERT statements (append new rows)

3. **UPDATE Patterns**:
   - Order status updates use `UPDATE` to change `pending` → `completed`/`shipped`
   - Product updates (Day 2) use `UPDATE` for price changes

4. **No Validation**: Operations don't validate that baseline exists or previous days were applied (trust-based)

### Common Mistakes

1. **Wrong syntax**: `--args {day: 1}` ❌ Missing quotes
   - **Correct**: `--args '{day: 1}'` ✅

2. **Invalid day**: `--args '{day: 4}'` ❌
   - **Valid values**: 1, 2, or 3

3. **Skipping baseline**: Running deltas without baseline
   - **Solution**: Run `origin_load_baseline` first

---

## origin_reset

### What It Does

Truncates all tables in both databases and reloads baseline data, returning to Day 0 state.

### When to Use

- **Starting fresh**: After applying deltas, want to return to baseline
- **Between demo sessions**: Clean slate for next demo
- **After testing**: Remove test data and custom records
- **Training resets**: Multiple training sessions in one day

### Usage

```bash
dbt run-operation origin_reset --profile ingestion_simulator
```

### Behavior Details

1. **Truncates ALL tables**: Removes ALL data (including custom data with IDs 5000+)
2. **Preserves table structures**: Tables and columns remain
3. **Reloads baseline**: Calls `origin_load_baseline` internally
4. **Foreign key order**: Truncates in reverse FK order to avoid constraint violations

### Expected Output

```
Resetting source databases to baseline...
→ Truncating jaffle_shop tables...
  ✓ Truncated jaffle_shop tables
→ Truncating jaffle_crm tables...
  ✓ Truncated jaffle_crm tables

Loading baseline schema and data...
→ Creating jaffle_shop tables...
  ✓ Created jaffle_shop schema
→ Loading jaffle_shop seed data...
  ✓ Loaded customers (100 rows)
  ✓ Loaded products (20 rows)
  ✓ Loaded orders (500 rows)
  ✓ Loaded order_items (1200 rows)
→ Creating jaffle_crm tables...
  ✓ Created jaffle_crm schema
→ Loading jaffle_crm seed data...
  ✓ Loaded campaigns (5 rows)
  ✓ Loaded email_activity (100 rows)
  ✓ Loaded web_sessions (150 rows)

✓ Baseline load complete!

═══ Demo Source Status ═══
jaffle_shop:
  customers: 100 | products: 20 | orders: 500
  order_items: 1200

jaffle_crm:
  campaigns: 5 | email_activity: 100
  web_sessions: 150
══════════════════════════
```

### What Gets Deleted

**Everything** - both package data and custom data:
- All package data (IDs 1-2000 range)
- All custom data (IDs 5000+ range)
- All delta changes (Days 1/2/3)
- Order status updates
- Payment records

### Truncate Order (Reverse FK)

To avoid foreign key constraint violations, truncates in this order:

**jaffle_shop**:
1. payments (depends on orders)
2. order_items (depends on orders, products)
3. orders (depends on customers)
4. products (no dependencies)
5. customers (no dependencies)

**jaffle_crm**:
1. email_activity (depends on campaigns)
2. web_sessions (no dependencies)
3. campaigns (no dependencies)

### WARNING

This operation is **destructive** and **cannot be undone**:
- Custom data is permanently removed
- No backup is created
- No confirmation prompt

**Best Practice**: If you have important custom data, export it first or don't use `origin_reset`.

---

## origin_status

### What It Shows

Displays current row counts for all tables in both databases.

### When to Use

- **Quick verification**: Check if operations succeeded
- **State inspection**: See current data state
- **Debugging**: Verify expected row counts
- **Documentation**: Capture state for screenshots/docs

### Usage

```bash
dbt run-operation origin_status --profile ingestion_simulator
```

### Expected Output

```
═══ Demo Source Status ═══
jaffle_shop:
  customers: 175 | products: 20 | orders: 680
  order_items: 1502

jaffle_crm:
  campaigns: 5 | email_activity: 250
  web_sessions: 300
══════════════════════════
```

### Behavior Details

1. **Read-only**: No data changes
2. **Live counts**: Queries current state (not cached)
3. **All tables**: Shows counts for every table
4. **Fast execution**: Uses `SELECT COUNT(*)` subqueries

### How to Interpret Output

**Baseline State**:
```
customers: 100 | products: 20 | orders: 500
order_items: 1200
```
This indicates Day 0 (baseline loaded, no deltas applied).

**After Day 1**:
```
customers: 125 | products: 20 | orders: 560
order_items: 1303
```
This indicates Day 1 delta has been applied.

**After Days 1+2+3**:
```
customers: 175 | products: 20 | orders: 680
order_items: 1502
```
This indicates all three deltas have been applied.

**Custom Data Present**:
```
customers: 185 | products: 25 | orders: 690
order_items: 1520
```
Higher-than-expected counts indicate custom data (IDs 5000+) has been added.

---

## Example Workflows

### Workflow 1: First-Time Setup

```bash
# Install package
dbt deps

# Load baseline data
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Verify
dbt run-operation origin_status --profile ingestion_simulator
```

### Workflow 2: Multi-Day Demo

```bash
# Start at baseline
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Progress through days
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
# ... demonstrate Day 1 state ...

dbt run-operation origin_apply_delta --args '{day: 2}' --profile ingestion_simulator
# ... demonstrate Day 2 state ...

dbt run-operation origin_apply_delta --args '{day: 3}' --profile ingestion_simulator
# ... demonstrate Day 3 state ...

# Reset for next demo
dbt run-operation origin_reset --profile ingestion_simulator
```

### Workflow 3: CDC/Change Tracking Demo

```bash
# Baseline (before CDC enabled)
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Enable CDC on Azure SQL
# (run your CDC setup scripts here)

# Apply Day 1 - triggers CDC
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator

# Query CDC tables to show captured changes
# (your CDC queries here)

# Apply Day 2 - more CDC changes
dbt run-operation origin_apply_delta --args '{day: 2}' --profile ingestion_simulator

# Reset when done
dbt run-operation origin_reset --profile ingestion_simulator
```

### Workflow 4: CI/CD Integration

```yaml
# GitHub Actions example
- name: Setup source data
  run: |
    dbt deps
    dbt run-operation origin_load_baseline --profile ingestion_simulator

- name: Run tests
  run: dbt test

- name: Teardown
  run: dbt run-operation origin_reset --profile ingestion_simulator
  if: always()
```

### Workflow 5: Training Session

```bash
# Morning session
dbt run-operation origin_load_baseline --profile ingestion_simulator
# ... training on baseline state ...

# Afternoon session (same day)
dbt run-operation origin_reset --profile ingestion_simulator
# Fresh start for afternoon participants
```

---

## Summary Table: All 4 Operations

| Operation | Changes Data | Requires Baseline | Idempotent | Destructive |
|-----------|--------------|-------------------|------------|-------------|
| **origin_load_baseline** | ✅ Inserts | ❌ No | ⚠️ Partial* | ❌ No |
| **origin_apply_delta** | ✅ Inserts/Updates | ⚠️ Yes** | ❌ No | ❌ No |
| **origin_reset** | ✅ Truncates/Inserts | ❌ No | ✅ Yes | ⚠️ Yes*** |
| **origin_status** | ❌ Read-only | ⚠️ Yes**** | ✅ Yes | ❌ No |

\* Idempotent for schema creation, but data may duplicate in DuckDB
\*\* Technically works without baseline, but foreign keys may fail
\*\*\* Deletes ALL data including custom records
\*\*\*\* Tables must exist or queries fail

---

## Next Steps

- See [Data Schemas](Data-Schemas) for complete table documentation
- See [Getting Started](Getting-Started) for installation and setup
- See [Extras](Extras) for data quality contracts and CI/CD templates

---

**Questions?** [Open an issue](https://github.com/feriksen-personal/dbt-origin-simulator-ops/issues)
