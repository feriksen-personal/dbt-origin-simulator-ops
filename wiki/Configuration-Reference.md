# Configuration Reference

All variables, options, and settings in one place.

---

## dbt Project Variables

Override in your `dbt_project.yml`:

```yaml
vars:
  origin_simulator_ops:
    shop_db: 'jaffle_shop'    # Default database/schema name for ERP data
    crm_db: 'jaffle_crm'      # Default database/schema name for CRM data
```

| Variable | Default | Description |
|----------|---------|-------------|
| `shop_db` | `jaffle_shop` | Database/schema name for ERP tables (customers, products, orders, etc.) |
| `crm_db` | `jaffle_crm` | Database/schema name for CRM tables (campaigns, email_activity, web_sessions) |

---

## Profile Configuration

The package operations require a profile pointing to your source database. This should be **separate** from your target/warehouse profile.

### Profile Name Convention

We recommend `ingestion_simulator` but any name works:

```yaml
ingestion_simulator:
  target: dev
  outputs:
    dev:
      # ... connection details
```

### DuckDB

```yaml
ingestion_simulator:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'data/ingestion_simulator.duckdb'
      threads: 4
```

| Option | Required | Description |
|--------|----------|-------------|
| `type` | Yes | Must be `duckdb` |
| `path` | Yes | File path for database, or `:memory:` for in-memory |
| `threads` | No | Number of threads (default: 1) |

### MotherDuck

```yaml
ingestion_simulator:
  target: motherduck
  outputs:
    motherduck:
      type: duckdb
      path: 'md:ingestion_simulator'
      token: "{{ env_var('MOTHERDUCK_TOKEN') }}"
```

| Option | Required | Description |
|--------|----------|-------------|
| `type` | Yes | Must be `duckdb` |
| `path` | Yes | `md:<database_name>` format |
| `token` | Yes | MotherDuck API token |

### Databricks

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

| Option | Required | Description |
|--------|----------|-------------|
| `type` | Yes | Must be `databricks` |
| `host` | Yes | Workspace hostname (e.g., `xxx.cloud.databricks.com`) |
| `http_path` | Yes | SQL warehouse HTTP path |
| `token` | Yes | Personal access token |
| `catalog` | Yes | Unity Catalog name |
| `schema` | Yes | Default schema |
| `threads` | No | Number of threads (default: 1) |

### Azure SQL

```yaml
ingestion_simulator:
  target: azure
  outputs:
    azure:
      type: sqlserver
      server: "{{ env_var('SQL_SERVER') }}.database.windows.net"
      port: 1433
      database: master
      schema: dbo
      user: "{{ env_var('SQL_USER') }}"
      password: "{{ env_var('SQL_PASSWORD') }}"
      driver: "ODBC Driver 18 for SQL Server"
      encrypt: true
      trust_cert: false
```

| Option | Required | Description |
|--------|----------|-------------|
| `type` | Yes | Must be `sqlserver` |
| `server` | Yes | Server hostname |
| `port` | No | Port (default: 1433) |
| `database` | Yes | Database name (`master` for creating databases) |
| `schema` | No | Default schema (default: `dbo`) |
| `user` | Yes | SQL authentication username |
| `password` | Yes | SQL authentication password |
| `driver` | No | ODBC driver name |
| `encrypt` | No | Enable encryption (default: true) |
| `trust_cert` | No | Trust server certificate (default: false) |

---

## Environment Variables

Recommended environment variables for each platform:

### MotherDuck

| Variable | Description |
|----------|-------------|
| `MOTHERDUCK_TOKEN` | API token from motherduck.com/settings/tokens |

### Databricks

| Variable | Description |
|----------|-------------|
| `DATABRICKS_SERVER_HOSTNAME` | Workspace hostname |
| `DATABRICKS_HTTP_PATH` | SQL warehouse HTTP path |
| `DATABRICKS_TOKEN` | Personal access token |
| `DATABRICKS_CATALOG` | Unity Catalog name |

### Azure SQL

| Variable | Description |
|----------|-------------|
| `SQL_SERVER` | Server name (without `.database.windows.net`) |
| `SQL_USER` | SQL admin username |
| `SQL_PASSWORD` | SQL admin password |

---

## Operation Parameters

### origin_load_baseline

```bash
dbt run-operation origin_load_baseline --profile ingestion_simulator
```

No parameters. Creates schemas and loads baseline data.

### origin_apply_delta

```bash
dbt run-operation origin_apply_delta --args '{day: N}' --profile ingestion_simulator
```

| Parameter | Required | Values | Description |
|-----------|----------|--------|-------------|
| `day` | Yes | `1`, `2`, or `3` | Which delta to apply |

### origin_reset

```bash
dbt run-operation origin_reset --profile ingestion_simulator
```

No parameters. Truncates all tables and reloads baseline.

### origin_status

```bash
dbt run-operation origin_status --profile ingestion_simulator
```

No parameters. Displays current row counts.

---

## Soda Configuration

Location: `extras/data_quality/soda/configuration.yml`

```yaml
data_source ingestion_simulator:
  type: duckdb
  path: data/ingestion_simulator.duckdb
```

Update `path` to match your profile configuration.

For other platforms:

```yaml
# Databricks
data_source ingestion_simulator:
  type: databricks
  catalog: main
  schema: jaffle_shop
  host: ${DATABRICKS_SERVER_HOSTNAME}
  http_path: ${DATABRICKS_HTTP_PATH}
  token: ${DATABRICKS_TOKEN}

# SQL Server
data_source ingestion_simulator:
  type: sqlserver
  host: ${SQL_SERVER}.database.windows.net
  username: ${SQL_USER}
  password: ${SQL_PASSWORD}
  database: jaffle_shop
```

---

## VS Code Tasks

Location: `extras/vscode/tasks.json`

The tasks use `ingestion_simulator` as the profile name. If you use a different name, update the tasks:

```json
{
  "label": "[dbt-origin-simulator]: Load Baseline",
  "type": "shell",
  "command": "dbt run-operation origin_load_baseline --profile YOUR_PROFILE_NAME"
}
```

---

## Data Ranges

For reference when inserting custom data:

| Table | Package ID Range | Safe Custom IDs |
|-------|------------------|-----------------|
| customers | 1-175 | 1000+ |
| products | 1-20 | 1000+ |
| orders | 1-680 | 1000+ |
| order_items | 1-1502 | 2000+ |
| payments | 1-374 | 1000+ |
| campaigns | 1-5 | 1000+ |
| email_activity | 1-250 | 1000+ |
| web_sessions | 1-300 | 1000+ |

These are maximum IDs after all three deltas. Be mindful of collisions if inserting custom data.
