# Getting Started

Get from zero to working source systems in minutes.

---

## Prerequisites

- **dbt Core** >= 1.10.0
- **Adapter** (one or more):
  - `dbt-duckdb` >= 1.10.0 — DuckDB and MotherDuck
  - `dbt-databricks` >= 1.10.0 — Databricks
  - `dbt-sqlserver` >= 1.10.0 — Azure SQL

---

## Installation

**Step 1:** Add to `packages.yml`

```yaml
packages:
  - git: "https://github.com/feriksen-personal/dbt-origin-simulator-ops"
    revision: v1.0.0
```

**Step 2:** Install

```bash
dbt deps
```

---

## Platform Setup

Choose your platform and configure a profile. This profile points to your **source databases** — the upstream systems your pipelines will ingest from.

> ⚠️ Always use a dedicated profile (e.g., `ingestion_simulator`) for source operations. Never run against your default target profile.

### A Note on Environment Variables

The examples below use environment variables for credentials and connection details. This pattern:
- Keeps secrets out of version control
- Works seamlessly with CI/CD pipelines and cloud deployments
- Makes it easy to switch between environments

It's easier to set things up "right" from the start. That said, configure however fits your workflow — these are just examples.

---

### DuckDB (Local Development)

Zero cloud costs, instant setup, complete isolation. Ideal for local development and CI/CD.

**Install adapter:**

```bash
pip install dbt-duckdb
```

**Configure profile** (`~/.dbt/profiles.yml`):

```yaml
ingestion_simulator:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'data/ingestion_simulator.duckdb'
```

**Create directory:**

```bash
mkdir -p data
```

The databases (`jaffle_shop`, `jaffle_crm`) are created automatically as schemas when you run `origin_load_baseline`.

---

### MotherDuck (Cloud-Based Pipelines)

Cloud-native DuckDB accessible from anywhere. Ideal for cloud-based pipelines like Lakeflow Connect, shared team environments, and remote demos. Free tier available.

**Install adapter:**

```bash
pip install dbt-duckdb
```

**Get token:** [motherduck.com/settings/tokens](https://motherduck.com/settings/tokens)

**Set environment variable:**

```bash
export MOTHERDUCK_TOKEN=your-token-here
```

**Configure profile** (`~/.dbt/profiles.yml`):

```yaml
ingestion_simulator:
  target: motherduck
  outputs:
    motherduck:
      type: duckdb
      path: 'md:ingestion_simulator'
      token: "{{ env_var('MOTHERDUCK_TOKEN') }}"
```

Databases are created automatically in your MotherDuck account and accessible from any environment with the token.

---

### Databricks (Unity Catalog / Delta Sharing)

Unity Catalog sources with Delta Lake tables. Test Lakeflow Connect ingestion patterns, Delta Sharing, and catalog governance.

**Install adapter:**

```bash
pip install dbt-databricks
```

**Set environment variables:**

```bash
export DATABRICKS_SERVER_HOSTNAME=your-workspace.cloud.databricks.com
export DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/your-warehouse-id
export DATABRICKS_TOKEN=your-personal-access-token
export DATABRICKS_CATALOG=main
```

Get your token from **User Settings → Developer → Access tokens** in your Databricks workspace.

**Configure profile** (`~/.dbt/profiles.yml`):

```yaml
ingestion_simulator:
  target: databricks
  outputs:
    databricks:
      type: databricks
      host: "{{ env_var('DATABRICKS_SERVER_HOSTNAME') }}"
      http_path: "{{ env_var('DATABRICKS_HTTP_PATH') }}"
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      catalog: "{{ env_var('DATABRICKS_CATALOG') }}"
      schema: default
      threads: 4
```

Source schemas (`jaffle_shop`, `jaffle_crm`) are created in your specified catalog.

---

### Azure SQL (CDC / Change Tracking)

> ⚠️ **In development** — Azure SQL support is being finalized.

SQL Server-native CDC and change tracking patterns. Validate ingestion logic that depends on these features before hitting production.

**Install adapter:**

```bash
pip install dbt-sqlserver
```

**Set environment variables:**

```bash
export SQL_SERVER=your-server-name
export SQL_USER=sqladmin
export SQL_PASSWORD=your-password
```

**Configure profile** (`~/.dbt/profiles.yml`):

```yaml
ingestion_simulator:
  target: azure
  outputs:
    azure:
      type: sqlserver
      server: "{{ env_var('SQL_SERVER') }}.database.windows.net"
      database: master
      user: "{{ env_var('SQL_USER') }}"
      password: "{{ env_var('SQL_PASSWORD') }}"
      encrypt: true
      trust_cert: false
```

---

## First Run

**Load baseline data:**

```bash
dbt run-operation origin_load_baseline --profile ingestion_simulator
```

Or use the **`[dbt-origin-simulator]: Load Baseline`** VS Code action — see [Extras](Extras) for setup.

This creates the source databases and loads baseline data:
- **jaffle_shop:** 100 customers, 20 products, 500 orders, 1200 order_items
- **jaffle_crm:** 5 campaigns, 100 email_activity, 150 web_sessions

**Check status:**

```bash
dbt run-operation origin_status --profile ingestion_simulator
```

Or use the **`[dbt-origin-simulator]: Check Status`** VS Code action.

**Apply incremental changes:**

```bash
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
```

Or use the **`[dbt-origin-simulator]: Apply Delta Day 1`** VS Code action.

Each delta introduces new records, updates existing ones, and soft-deletes others — mirroring real source system behavior.

**Reset to baseline:**

```bash
dbt run-operation origin_reset --profile ingestion_simulator
```

Or use the **`[dbt-origin-simulator]: Reset to Baseline`** VS Code action.

📚 **[Full operations reference →](Operations-Guide)**

---

## Verify Connection

If something isn't working:

```bash
dbt debug --profile ingestion_simulator
```

You should see `Connection test: OK`.

---

## Custom Data

You can insert custom data directly into source tables for specific test scenarios. Be mindful of primary key collisions with package-managed data — this is on you to manage.

Run `origin_reset` anytime to return to a known valid baseline state.

---

## Common Issues

**"Profile ingestion_simulator not found"**
- Check `~/.dbt/profiles.yml` has an `ingestion_simulator:` section
- Verify YAML indentation

**"Package not found"**
- Run `dbt deps` to install

**DuckDB "Failed to create database"**
- Create the data directory: `mkdir -p data`

**Databricks "Invalid token"**
- Verify `DATABRICKS_TOKEN` environment variable is set
- Check token hasn't expired

**Azure SQL "Login failed"**
- Verify environment variables
- Check Azure SQL firewall allows your IP

---

## Next Steps

- **[Operations Guide](Operations-Guide)** — Detailed usage for all four operations
- **[Data Schemas](Data-Schemas)** — Table structures, relationships, ID ranges
- **[Extras](Extras)** — Soda contracts, ODCS definitions, VS Code tasks
