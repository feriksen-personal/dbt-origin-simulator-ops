# Getting Started

Complete guide for first-time users of **dbt-azure-demo-source-ops**.

---

## Prerequisites

Before installing this package, ensure you have:

- **dbt Core >= 1.10.0**
- **Adapter** (choose one based on your target):
  - **DuckDB**: `dbt-duckdb >= 1.10.0` for local development
  - **Azure SQL**: `dbt-sqlserver >= 1.10.0` for cloud demos

### Why These Versions?

- dbt 1.10.0+ introduced critical improvements to `run-operation` that this package relies on
- Adapter versions must match dbt Core major version

---

## Installation

### 1. Add Package Dependency

Add to your `packages.yml`:

```yaml
packages:
  - git: "https://github.com/feriksen-personal/dbt-azure-demo-source-ops"
    revision: v1.0.0  # Or latest version
```

### 2. Install Package

```bash
dbt deps
```

This downloads the package to your `dbt_packages/` directory.

---

## Database Setup

Choose your target database and follow the corresponding setup instructions.

### Option A: DuckDB Setup (Local Development)

DuckDB is ideal for:
- Local development with zero cloud costs
- Fast iteration cycles
- Learning dbt without infrastructure

#### 1. Install DuckDB Adapter

```bash
pip install dbt-duckdb
```

#### 2. Configure Profile

Add to your `~/.dbt/profiles.yml`:

```yaml
demo_source:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: data/demo.duckdb  # Where to store the database file
      threads: 4
```

#### 3. Create Database Directory

```bash
mkdir -p data/duckdb
```

The databases (`jaffle_shop` and `jaffle_crm`) will be created automatically as DuckDB schemas when you run `demo_load_baseline`.

---

### Option B: Azure SQL Setup (Cloud Demos)

Azure SQL is ideal for:
- Realistic cloud demos
- Change Data Capture (CDC) demonstrations
- Multi-user environments
- Production-like scenarios

#### 1. Install Azure SQL Adapter

```bash
pip install dbt-sqlserver
```

#### 2. Configure Profile

Add to your `~/.dbt/profiles.yml`:

```yaml
demo_source:
  target: dev
  outputs:
    dev:
      type: sqlserver
      server: "{{ env_var('DEMO_SQL_SERVER') }}.database.windows.net"
      port: 1433
      database: master  # Connect to master, package creates databases
      schema: dbo
      authentication: sql
      user: "{{ env_var('DEMO_SQL_USER') }}"
      password: "{{ env_var('DEMO_SQL_PASSWORD') }}"
      driver: "ODBC Driver 18 for SQL Server"
      encrypt: true
      trust_cert: false
```

#### 3. Set Environment Variables

Create a `.env` file or export in your shell:

```bash
export DEMO_SQL_SERVER=myserver        # Without .database.windows.net
export DEMO_SQL_USER=sqladmin
export DEMO_SQL_PASSWORD=YourPassword123!
```

**Security Note**: Never commit credentials to git. Use `.env` files (add to `.gitignore`) or your shell's credential manager.

#### 4. Verify Connection

Test your connection:

```bash
dbt debug --profile demo_source
```

You should see "Connection test: OK".

---

## Optional: Override Database Names

By default, the package uses these database names:
- **DuckDB**: `jaffle_shop` and `jaffle_crm` (schemas)
- **Azure SQL**: `jaffle_shop` and `jaffle_crm` (databases)

To use different names, add to your `dbt_project.yml`:

```yaml
vars:
  demo_source_ops:
    shop_db: 'my_shop_db'
    crm_db: 'my_crm_db'
```

---

## First Operations Walkthrough

Now that your environment is configured, let's initialize and explore the demo data.

### Step 1: Load Baseline Data

Initialize both databases with baseline seed data:

```bash
dbt run-operation demo_load_baseline --profile demo_source
```

**What happens:**
1. Creates schemas/databases (`jaffle_shop`, `jaffle_crm`)
2. Creates all tables with proper schemas
3. Loads baseline data (Day 0):
   - **jaffle_shop**: 100 customers, 20 products, 500 orders, 1200 order_items
   - **jaffle_crm**: 5 campaigns, 100 email_activity, 150 web_sessions

**Expected output:**

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

### Step 2: Check Status

Verify the current state of your databases:

```bash
dbt run-operation demo_status --profile demo_source
```

**What it shows:**
- Row counts for all tables
- Quick verification that data loaded correctly

**Expected output:**

```
═══ Demo Source Status ═══
jaffle_shop:
  customers: 100 | products: 20 | orders: 500
  order_items: 1200

jaffle_crm:
  campaigns: 5 | email_activity: 100
  web_sessions: 150
══════════════════════════
```

### Step 3: Apply Day 1 Delta

Simulate business activity by applying Day 1 changes:

```bash
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source
```

**What happens:**
1. Adds 25 new customers (101-125)
2. Adds 60 new orders (501-560)
3. Adds 103 new order_items (1201-1303)
4. Adds 272 payments
5. Updates order statuses
6. Adds CRM activity (email and web sessions)

**Expected output:**

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

### Step 4: Apply More Deltas (Optional)

Continue progressing through days 2 and 3:

```bash
# Day 2
dbt run-operation demo_apply_delta --args '{day: 2}' --profile demo_source

# Day 3
dbt run-operation demo_apply_delta --args '{day: 3}' --profile demo_source
```

Each day adds more customers, orders, and activity. See [Operations Guide](Operations-Guide) for detailed breakdown.

### Step 5: Reset to Baseline

When you want to start fresh:

```bash
dbt run-operation demo_reset --profile demo_source
```

**What happens:**
1. Truncates all tables (removes ALL data, including custom data)
2. Reloads baseline seed data
3. Returns to Day 0 state

**Expected output:**

```
Resetting demo databases to baseline...
→ Truncating jaffle_shop tables...
  ✓ Truncated jaffle_shop tables
→ Truncating jaffle_crm tables...
  ✓ Truncated jaffle_crm tables

Loading baseline schema and data...
[... baseline load output ...]

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

---

## Common Setup Issues and Solutions

### Issue: "Command not found: dbt"

**Cause**: dbt is not installed or not in your PATH

**Solution**:
```bash
pip install dbt-core dbt-duckdb  # or dbt-sqlserver
```

### Issue: "Profile demo_source not found"

**Cause**: Profile not configured or typo in profile name

**Solution**:
1. Verify `~/.dbt/profiles.yml` has a `demo_source:` section
2. Check indentation (YAML is whitespace-sensitive)
3. Run `dbt debug --profile demo_source` to validate

### Issue: "Package demo_source_ops not found"

**Cause**: Package not installed

**Solution**:
```bash
dbt deps
```

Make sure `packages.yml` exists and contains the package definition.

### Issue: DuckDB "Failed to create database"

**Cause**: Directory doesn't exist or permission issues

**Solution**:
```bash
mkdir -p data/duckdb
chmod 755 data/duckdb
```

### Issue: Azure SQL "Login failed for user"

**Cause**: Incorrect credentials or network access

**Solution**:
1. Verify environment variables: `echo $DEMO_SQL_SERVER`
2. Check Azure SQL firewall rules (allow your IP)
3. Test connection with `dbt debug --profile demo_source`

### Issue: Azure SQL "Database 'jaffle_shop' does not exist"

**Cause**: This is normal on first run - the package creates databases

**Solution**:
- Ensure your user has `CREATE DATABASE` permissions
- Run `demo_load_baseline` which creates the databases

### Issue: "Parameter 'day' must be 1, 2, or 3"

**Cause**: Invalid day parameter

**Solution**:
```bash
# Correct syntax with single quotes around args
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source
```

Note the single quotes around the JSON object.

### Issue: "Relation does not exist" when running demo_status

**Cause**: Tables not created yet

**Solution**:
1. Run `demo_load_baseline` first
2. This creates all tables and schemas

---

## Next Steps

Now that you have the package installed and working:

1. **Explore the data**: See [Data Schemas](Data-Schemas) for complete table documentation
2. **Learn the operations**: See [Operations Guide](Operations-Guide) for detailed usage patterns
3. **Add custom data**: See [Custom Data](Custom-Data) for the 5000+ ID pattern

---

## Quick Reference

### Four Core Operations

| Operation | Purpose | Example |
|-----------|---------|---------|
| `demo_load_baseline` | Initialize with Day 0 data | `dbt run-operation demo_load_baseline --profile demo_source` |
| `demo_apply_delta` | Apply day 1/2/3 changes | `dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source` |
| `demo_reset` | Truncate and reload baseline | `dbt run-operation demo_reset --profile demo_source` |
| `demo_status` | Show current row counts | `dbt run-operation demo_status --profile demo_source` |

### Typical Workflow

```bash
# First time setup
dbt deps
dbt run-operation demo_load_baseline --profile demo_source

# Progress through days
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source
dbt run-operation demo_apply_delta --args '{day: 2}' --profile demo_source
dbt run-operation demo_apply_delta --args '{day: 3}' --profile demo_source

# Check state anytime
dbt run-operation demo_status --profile demo_source

# Reset when needed
dbt run-operation demo_reset --profile demo_source
```

---

**Need more help?** See [Troubleshooting](Troubleshooting) or [open an issue](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/issues).
