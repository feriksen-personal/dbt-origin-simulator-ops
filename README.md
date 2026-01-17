# dbt-azure-demo-source-ops

[![CI](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/actions/workflows/test-package.yml/badge.svg)](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/actions/workflows/test-package.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![dbt](https://img.shields.io/badge/dbt-%3E%3D1.10.0-green.svg)](https://www.getdbt.com/)

**Manage demo source data for dbt projects** - Four simple operations: load baseline, apply deltas, reset, and check status.

---

## Use Cases

### 1. Fully Local Development (DuckDB)

**Zero cloud costs, instant setup, full dbt development workflow:**

- DuckDB sources (managed by this package) + DuckDB target
- Complete dbt development environment in seconds
- No Azure account or credentials needed
- Perfect for learning, testing, CI/CD

### 2. Demo/POC Environments (Azure SQL)

**Test CDC and change tracking patterns:**

- Azure SQL sources with change tracking enabled
- Demonstrate incremental loads, SCD Type 2, CDC workflows
- Infrastructure provisioned via [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data)
- **Note:** For demo/POC purposes only, not production

---

## Why This Package?

When demonstrating dbt or developing data pipelines, you need realistic source databases that you can initialize, evolve over time, and reset instantly. This package provides four simple operations to manage demo data without maintaining complex seeding scripts or manually recreating databases.

Perfect for dbt demos, training workshops, development environments, and CI/CD testing. See the [wiki](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki) for detailed use cases and patterns.

---

## Features

Four operations via `dbt run-operation`:

- **`demo_load_baseline`** - Create schema and load seed data
- **`demo_apply_delta`** - Apply day 1/2/3 changes (simulates business activity)
- **`demo_reset`** - Truncate and reload baseline
- **`demo_status`** - Show current row counts

Dual-adapter support:

- **DuckDB** - Local, fast, no dependencies
- **Azure SQL** - Cloud-based with CDC/change tracking

---

## Quick Start

### Prerequisites

- **dbt** >= 1.10.0
- One of the following adapters:
  - **dbt-duckdb** (for local development) - zero cloud costs
  - **dbt-sqlserver** (for Azure SQL demos) - requires Azure account

Optional: Azure SQL databases provisioned via [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data)

### 1. Install Package

```yaml
# packages.yml
packages:
  - git: "https://github.com/feriksen-personal/dbt-azure-demo-source-ops"
    revision: v1.0.0
```

```bash
dbt deps
```

### 2. Configure Profile

**DuckDB (local):**

```yaml
# profiles.yml
demo_source:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'demo_source.duckdb'
```

**Azure SQL (demo/POC):**

```yaml
# profiles.yml
demo_source:
  target: azure
  outputs:
    azure:
      type: sqlserver
      server: "{{ env_var('DEMO_SQL_SERVER') }}.database.windows.net"
      database: master
      user: "{{ env_var('DEMO_SQL_USER') }}"
      password: "{{ env_var('DEMO_SQL_PASSWORD') }}"
```

Set environment variables:

```bash
export DEMO_SQL_SERVER=your-server-name
export DEMO_SQL_USER=sqladmin
export DEMO_SQL_PASSWORD=your-password
```

### 3. Run Operations

```bash
# Load baseline data
dbt run-operation demo_load_baseline --profile demo_source

# Check status
dbt run-operation demo_status --profile demo_source

# Apply deltas
dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source

# Reset to baseline
dbt run-operation demo_reset --profile demo_source
```

---

## Data Schemas

**jaffle_shop** (e-commerce):

- **customers** - Customer records with email addresses and soft delete tracking
- **products** - Product catalog with pricing and categories
- **orders** - Order transactions with status tracking and customer relationships
- **order_items** - Line items linking products to orders with quantities and pricing
- **payments** - Payment records linked to orders (added in deltas)

**jaffle_crm** (marketing):

- **campaigns** - Marketing campaigns with budgets and dates
- **email_activity** - Email engagement metrics (sent, opened, clicked)
- **web_sessions** - Website session tracking with page views

See the [Data Schemas wiki page](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas) for detailed column definitions and ID ranges.

---

## What's Inside

```
dbt-azure-demo-source-ops/
├── macros/              # Four operations: load_baseline, apply_delta, reset, status
├── data/duckdb/         # DuckDB SQL files (baseline, deltas, utilities)
└── data/azure/          # Azure SQL files (to be implemented)
```

---

## Configuration

```yaml
# dbt_project.yml (optional overrides)
vars:
  demo_source_ops:
    shop_db: 'jaffle_shop'  # default
    crm_db: 'jaffle_crm'    # default
```

For detailed documentation, see the [project wiki](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki)

---

## Contributing

Contributions welcome! Please open an issue or submit a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Acknowledgments

- Built to complement [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data) infrastructure repo
- Inspired by the [Jaffle Shop](https://github.com/dbt-labs/jaffle_shop) demo project

---

## License

MIT License - see [LICENSE](LICENSE) file.

---

**Questions?** [Open an issue](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/issues) | **Detailed docs:** [Project wiki](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki)
