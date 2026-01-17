# dbt-azure-demo-source-ops

[![CI](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/actions/workflows/test-package.yml/badge.svg)](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/actions/workflows/test-package.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![dbt Core](https://img.shields.io/badge/dbt_Core-%3E%3D1.10.0-orange.svg)](https://docs.getdbt.com/docs/introduction)
[![dbt-duckdb](https://img.shields.io/badge/dbt--duckdb-%3E%3D1.10.0-blue.svg)](https://github.com/duckdb/dbt-duckdb)
[![dbt-sqlserver](https://img.shields.io/badge/dbt--sqlserver-%3E%3D1.10.0-blue.svg)](https://github.com/dbt-msft/dbt-sqlserver)

**Manage demo source data for dbt projects** - Four simple operations: load baseline, apply deltas, reset, and check status.

**[Quick Start](#quick-copy-paste-setup)** • **[Wiki Documentation](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki)** • **[Operations Guide](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide)**

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

**Key Benefits:**

- ✅ **Zero Configuration** - Works out of the box with sensible defaults
- 🔄 **Reproducible** - Reset to baseline instantly for consistent demos
- 📊 **Realistic Data** - 100 customers, 500+ orders, proper foreign key relationships
- 🎯 **Four Simple Operations** - `load_baseline`, `apply_delta`, `reset`, `status`
- 💰 **Cost Effective** - DuckDB option = zero cloud costs
- 📈 **Production Patterns** - CDC, SCD Type 2, soft deletes included

Perfect for dbt demos, training workshops, development environments, and CI/CD testing. See the [wiki](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki) for detailed use cases and patterns.

---

## Supported Platforms

| Platform     | Use Case                   | Status               |
|--------------|----------------------------|----------------------|
| **DuckDB**   | Local development, CI/CD   | ✅ Fully supported   |
| **Azure SQL** | Cloud demos, CDC patterns | ⚠️ In development    |

---

## Quick Copy-Paste Setup

**Step 1:** Add to `packages.yml`

```yaml
packages:
  - git: "https://github.com/feriksen-personal/dbt-azure-demo-source-ops"
    revision: v1.0.0
```

**Step 2:** Install and run

```bash
dbt deps
dbt run-operation demo_load_baseline --profile demo_source
```

That's it! 🎉 **[See all operations →](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide)**

---

## Operations Reference

| Operation | Purpose | Idempotent | Destructive | Usage |
|-----------|---------|:----------:|:-----------:|-------|
| [`demo_load_baseline`](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide#demo_load_baseline) | Initialize with Day 0 data | ✅ | ❌ | `dbt run-operation demo_load_baseline --profile demo_source` |
| [`demo_apply_delta`](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide#demo_apply_delta) | Apply day 1/2/3 changes | ❌ | ❌ | `dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source` |
| [`demo_reset`](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide#demo_reset) | Truncate and reload baseline | ✅ | ✅ | `dbt run-operation demo_reset --profile demo_source` |
| [`demo_status`](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide#demo_status) | Show current row counts | ✅ | ❌ | `dbt run-operation demo_status --profile demo_source` |

📚 **[Detailed Operation Guide →](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Operations-Guide)**

---

## Installation & Setup

### Prerequisites

- **dbt Core** >= 1.10.0
- **Adapter** (choose one):
  - **dbt-duckdb** >= 1.10.0 for local development
  - **dbt-sqlserver** >= 1.10.0 for Azure SQL demos

Optional: Azure SQL databases provisioned via [dbt-azure-demo-source-data](https://github.com/feriksen-personal/dbt-azure-demo-source-data)

### Install Package

```yaml
# packages.yml
packages:
  - git: "https://github.com/feriksen-personal/dbt-azure-demo-source-ops"
    revision: v1.0.0
```

```bash
dbt deps
```

### Configure Profile

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

### Run Operations

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

📖 **[Step-by-step setup guide →](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Getting-Started)**

---

## Data Schemas

**jaffle_shop** (e-commerce):

- **[customers](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#customers)** - Customer records with email addresses and soft delete tracking
- **[products](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#products)** - Product catalog with pricing and categories
- **[orders](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#orders)** - Order transactions with status tracking and customer relationships
- **[order_items](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#order_items)** - Line items linking products to orders with quantities and pricing
- **[payments](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#payments)** - Payment records linked to orders (added in deltas)

**jaffle_crm** (marketing):

- **[campaigns](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#campaigns)** - Marketing campaigns with budgets and dates
- **[email_activity](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#email_activity)** - Email engagement metrics (sent, opened, clicked)
- **[web_sessions](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas#web_sessions)** - Website session tracking with page views

📊 **[Complete schema documentation with ID ranges →](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Data-Schemas)**

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
