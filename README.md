# dbt-azure-demo-source-ops

[![CI](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/actions/workflows/test-package.yml/badge.svg)](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/actions/workflows/test-package.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![dbt](https://img.shields.io/badge/dbt-%3E%3D1.6.0-orange.svg)](https://www.getdbt.com/)

**A dbt package for managing demo source data operations** - load baseline data, apply daily deltas, and reset databases for demos and development.

This package provides simple `dbt run-operation` commands to manage demo data in databases provisioned by [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data). Use it to quickly set up realistic source data scenarios for dbt demos, testing, and development.

---

## Background

When demonstrating dbt capabilities or developing data pipelines, you need **realistic source databases** that you can:

- **Initialize** with baseline data
- **Evolve** over time with daily changes
- **Reset** to a known state instantly

This package works hand-in-hand with the [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data) infrastructure repository:

```text
┌─────────────────────────────────────────┐
│  dbt-azure-demo-source-data (Terraform) │  ← Provisions infrastructure
│  - Provisions Azure SQL Server          │     (one-time setup)
│  - Creates jaffle_shop, jaffle_crm DBs  │
│  - Configures users, change tracking    │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│  dbt-azure-demo-source-ops (this pkg)   │  ← Manages demo data
│  - Loads/resets demo data               │     (repeatable operations)
│  - Applies daily deltas (day 1, 2, 3)   │
│  - Used during demos and development    │
└─────────────────────────────────────────┘
```

**Use cases:**

- **dbt demonstrations** - Show incremental models, change data capture, SCD Type 2
- **Development & testing** - Consistent, repeatable source data for pipeline development
- **Training & workshops** - Reset to known state between sessions
- **CI/CD testing** - Spin up realistic sources for integration tests

---

## Features

✅ **Four simple operations** via `dbt run-operation`:

- `demo_load_baseline` - Initialize with baseline schema and seed data
- `demo_apply_delta` - Apply day 1, 2, or 3 changes
- `demo_reset` - Truncate and reload baseline
- `demo_status` - Show current row counts and state

✅ **Dual-adapter support**:

- **DuckDB** for local development and testing (no cloud required)
- **Azure SQL** for production demos (works with provisioned infrastructure)

✅ **Behavior-realistic data**:

- E-commerce transactions (customers, products, orders)
- Marketing campaigns (campaigns, email activity, web sessions)
- Daily deltas simulate ongoing business activity

✅ **Change Data Capture ready**:

- Azure SQL databases have change tracking enabled
- Incremental data perfect for demonstrating CDC patterns

---

## Prerequisites

**Required:**

- **dbt** 1.6.0 or higher
- One of the following adapters:
  - **dbt-duckdb** (for local development) - FREE
  - **dbt-sqlserver** (for Azure SQL) - requires Azure account

**Optional:**

- Azure SQL databases provisioned via [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data)
- OR use DuckDB locally (no cloud costs)

---

## Getting Started

### 1. Install the Package

Add to your `packages.yml`:

```yaml
packages:
  - git: "https://github.com/feriksen-personal/dbt-azure-demo-source-ops"
    revision: v1.0.0
```

Then install:

```bash
dbt deps
```

### 2. Configure Connection

#### Option A: DuckDB (Local Development)

Add to your `profiles.yml`:

```yaml
demo_source:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'demo_source.duckdb'
      schema: main
```

#### Option B: Azure SQL (Production Demos)

Add to your `profiles.yml`:

```yaml
demo_source:
  target: azure
  outputs:
    azure:
      type: sqlserver
      server: "{{ env_var('DEMO_SQL_SERVER') }}.database.windows.net"
      database: master
      user: "{{ env_var('DEMO_SQL_USER') }}"
      password: "{{ env_var('DEMO_SQL_PASSWORD') }}"
      encrypt: true
      trust_cert: false
```

Set environment variables:

```bash
export DEMO_SQL_SERVER=your-server        # Without .database.windows.net
export DEMO_SQL_USER=sqladmin
export DEMO_SQL_PASSWORD=your-password
```

### 3. (Optional) Override Database Names

If your databases have different names:

```yaml
# dbt_project.yml
vars:
  demo_source_ops:
    shop_db: 'my_shop_db'
    crm_db: 'my_crm_db'
```

---

## Usage

### Load Baseline Data

Initialize databases with schema and seed data:

```bash
dbt run-operation demo_load_baseline --profile demo_source
```

### Check Status

View current row counts and database state:

```bash
dbt run-operation demo_status --profile demo_source
```

Example output:

```text
═══ Demo Source Status ═══
jaffle_shop:
  customers: 5 | products: 5 | orders: 5
  order_items: 5

jaffle_crm:
  campaigns: 3 | email_activity: 5
  web_sessions: 5
═══════════════════════════
```

### Apply Daily Deltas

Simulate business activity over 3 days:

```bash
# Day 1: New customers, orders, email activity
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source

# Day 2: More orders, product changes, engagement
dbt run-operation demo_apply_delta --args '{day: 2}' --profile demo_source

# Day 3: Final batch, completions, cancellations
dbt run-operation demo_apply_delta --args '{day: 3}' --profile demo_source
```

### Reset to Baseline

Truncate all tables and reload baseline data:

```bash
dbt run-operation demo_reset --profile demo_source
```

---

## Project Structure

```text
dbt-azure-demo-source-ops/
├── dbt_project.yml           # Package configuration
├── README.md
├── LICENSE
├── macros/
│   ├── demo_load_baseline.sql    # Load baseline schema & data
│   ├── demo_apply_delta.sql      # Apply day 1/2/3 changes
│   ├── demo_reset.sql            # Truncate & reload
│   ├── demo_status.sql           # Show row counts
│   └── _internal/
│       ├── _get_config.sql       # Extract vars
│       ├── _get_sql.sql          # Load SQL files (adapter-aware)
│       └── _log.sql              # Logging helper
├── data/
│   ├── duckdb/                   # DuckDB SQL files
│   │   ├── baseline/             # Schema + seed data
│   │   ├── deltas/               # Day 1/2/3 changes
│   │   └── utilities/            # Truncate scripts
│   └── azure/                    # Azure SQL files
│       ├── baseline/             # Schema + seed data
│       ├── deltas/               # Day 1/2/3 changes
│       └── utilities/            # Truncate scripts
└── integration_tests/
    ├── dbt_project.yml
    └── profiles.yml
```

---

## Configuration

### Package Variables

| Variable                      | Default       | Description                  |
|-------------------------------|---------------|------------------------------|
| `demo_source_ops.shop_db`     | `jaffle_shop` | E-commerce database name     |
| `demo_source_ops.crm_db`      | `jaffle_crm`  | Marketing/CRM database name  |

### Environment Variables (Azure SQL)

| Variable              | Required | Description                                           |
|-----------------------|----------|-------------------------------------------------------|
| `DEMO_SQL_SERVER`     | Yes      | Azure SQL Server name (without .database.windows.net) |
| `DEMO_SQL_USER`       | Yes      | SQL admin username                                    |
| `DEMO_SQL_PASSWORD`   | Yes      | SQL admin password                                    |

---

## Database Schemas

### jaffle_shop (E-commerce)

- **customers** - Customer records with email addresses
- **products** - Product catalog with pricing
- **orders** - Order transactions with status tracking
- **order_items** - Order line items linking products to orders

### jaffle_crm (Marketing)

- **campaigns** - Marketing campaigns with budgets and dates
- **email_activity** - Email engagement metrics (sent, opened, clicked)
- **web_sessions** - Website session tracking with page views

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- Built to complement [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data)
- Inspired by the need for realistic, repeatable demo data in the dbt ecosystem
- Data schema inspired by the classic [Jaffle Shop](https://github.com/dbt-labs/jaffle_shop) demo project

---

**Questions or Issues?** [Open an issue](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/issues) or [start a discussion](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/discussions)
