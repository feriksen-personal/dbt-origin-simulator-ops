# dbt-origin-simulator-ops

[![CI](https://github.com/feriksen-personal/dbt-origin-simulator-ops/actions/workflows/test-package.yml/badge.svg)](https://github.com/feriksen-personal/dbt-origin-simulator-ops/actions/workflows/test-package.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![dbt Core](https://img.shields.io/badge/dbt_Core-%3E%3D1.10.0-orange.svg)](https://docs.getdbt.com/docs/introduction)
[![dbt-duckdb](https://img.shields.io/badge/dbt--duckdb-%3E%3D1.10.0-blue.svg)](https://github.com/duckdb/dbt-duckdb)
[![dbt-sqlserver](https://img.shields.io/badge/dbt--sqlserver-%3E%3D1.10.0-blue.svg)](https://github.com/dbt-msft/dbt-sqlserver)

**Control plane for managing stable, versioned source system emulations** - Four simple operations: load baseline, apply deltas, reset, and check status.

**[Quick Start](#quick-copy-paste-setup)** • **[Wiki Documentation](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki)** • **[Operations Guide](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide)**

---

## Use Cases

### 1. Local Development (DuckDB)

**Zero cloud costs, instant setup, complete isolation:**

- Fully local source databases with no external dependencies
- Complete dbt development environment in seconds
- Perfect for learning, testing, offline development
- Ideal for CI/CD pipelines

### 2. Collaborative Development (MotherDuck)

**Cloud-native DuckDB with team access:**

- Shared source databases across your team
- Free tier available (no credit card required)
- Same DuckDB experience, cloud-hosted
- Perfect for distributed teams and remote demos

### 3. Cloud Demos & POCs (Azure SQL)

**Enterprise database patterns with CDC:**

- Azure SQL sources with change tracking enabled
- Demonstrate incremental loads, SCD Type 2, CDC workflows
- Infrastructure provisioned via [dbt-origin-simulator-infra](https://github.com/feriksen-personal/dbt-origin-simulator-infra)
- **Note:** For demo/POC purposes only, not production

### 4. Lakehouse Workflows (Databricks)

**Unity Catalog and Delta Lake patterns:**

- Databricks SQL Warehouse sources
- Test lakehouse ingestion patterns and Lakeflow Connect
- Practice Unity Catalog governance workflows
- **Status:** Coming soon (Issue #59)

---

## Why This Package?

When developing data pipelines, you need realistic source databases that you can initialize, evolve over time, and reset instantly. This package acts as a **control plane for managing stable, versioned source system emulations** across multiple platforms (DuckDB, MotherDuck, Azure SQL, Databricks) without maintaining complex seeding scripts or manually recreating databases.

**Unlike traditional databases** (AdventureWorks, Willibald) which provide static datasets for learning SQL and data modeling, this package focuses on **data engineering infrastructure patterns**: incremental loads, CDC, change tracking, SCD Type 2, and pipeline orchestration. The four operations (`load_baseline`, `apply_delta`, `reset`, `status`) let you simulate realistic source system evolution in a controlled, reproducible way—perfect for:

- **Testing pipeline orchestration** - Lakeflow Connect, Databricks workflows, Airflow DAGs
- **Developing ingestion patterns** - Incremental loads, CDC detection, change tracking
- **Learning data engineering** - How source systems evolve, not just querying static data
- **CI/CD testing** - Reproducible source state for automated tests
- **Workshops and training** - Consistent, resettable demo environments

While built with dbt operations for convenience, the managed source databases can be used by **any data pipeline tool or workflow** - Spark jobs, Python scripts, SQL queries, Fivetran, or standalone applications that need consistent, evolving test data.

**Key Benefits:**

- ✅ **Zero Configuration** - Works out of the box with sensible defaults
- 🔄 **Reproducible** - Reset to baseline instantly for consistent state
- 📊 **Realistic Data** - Two source systems (ERP + CRM) with proper relationships
- 🎯 **Four Simple Operations** - `load_baseline`, `apply_delta`, `reset`, `status`
- 🌐 **Multi-Platform** - DuckDB, MotherDuck, Azure SQL, Databricks (coming soon)
- 💰 **Cost Effective** - Free tier options for all platforms
- 📈 **Production Patterns** - CDC, SCD Type 2, soft deletes, incremental loads
- 🔧 **Tool Agnostic** - Use with dbt, Spark, Python, Fivetran, or any data tool

See the [wiki](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki) for detailed use cases and patterns.

---

## Supported Platforms

| Platform        | Use Case                          | Free Tier | Status              |
|-----------------|-----------------------------------|-----------|---------------------|
| **DuckDB**      | Local development, CI/CD          | ✅ Free   | ✅ Fully supported  |
| **MotherDuck**  | Cloud collaboration, remote demos | ✅ Free   | ✅ Fully supported  |
| **Azure SQL**   | CDC patterns, change tracking     | ✅ Free   | ⚠️ In development   |
| **Databricks**  | Unity Catalog, Delta Lake         | ✅ Free   | 🔜 Planned (#59)    |

---

## Quick Copy-Paste Setup

**Step 1:** Add to `packages.yml`

```yaml
packages:
  - git: "https://github.com/feriksen-personal/dbt-origin-simulator-ops"
    revision: v1.0.0
```

**Step 2:** Install and run

```bash
dbt deps
dbt run-operation demo_load_baseline --profile demo_source
```

That's it! 🎉 **[See all operations →](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide)**

---

## Operations Reference

| Operation | Purpose | Idempotent | Destructive | Usage |
|-----------|---------|:----------:|:-----------:|-------|
| [`demo_load_baseline`](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide#demo_load_baseline) | Initialize with Day 0 data | ✅ | ❌ | `dbt run-operation demo_load_baseline --profile demo_source` |
| [`demo_apply_delta`](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide#demo_apply_delta) | Apply day 1/2/3 changes | ❌ | ❌ | `dbt run-operation demo_apply_delta --args '{day: 1}' --profile demo_source` |
| [`demo_reset`](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide#demo_reset) | Truncate and reload baseline | ✅ | ✅ | `dbt run-operation demo_reset --profile demo_source` |
| [`demo_status`](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide#demo_status) | Show current row counts | ✅ | ❌ | `dbt run-operation demo_status --profile demo_source` |

📚 **[Detailed Operation Guide →](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide)**

---

## Installation & Setup

### Prerequisites

- **dbt Core** >= 1.10.0
- **Adapter** (choose one or more):
  - **dbt-duckdb** >= 1.10.0 for DuckDB and MotherDuck
  - **dbt-sqlserver** >= 1.10.0 for Azure SQL
  - **dbt-databricks** >= 1.10.0 for Databricks (coming soon)

**Optional:**

- Azure SQL databases via [dbt-origin-simulator-infra](https://github.com/feriksen-personal/dbt-origin-simulator-infra)
- [MotherDuck account](https://motherduck.com) (free tier available)
- [Databricks workspace](https://databricks.com/try-databricks) (community edition available)

### Install Package

```yaml
# packages.yml
packages:
  - git: "https://github.com/feriksen-personal/dbt-origin-simulator-ops"
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
      path: 'data/demo_source.duckdb'
```

**MotherDuck (cloud):**

```yaml
# profiles.yml
demo_source:
  target: motherduck
  outputs:
    motherduck:
      type: duckdb
      path: 'md:demo_source'
      token: "{{ env_var('MOTHERDUCK_TOKEN') }}"
```

Get your token at [motherduck.com/settings/tokens](https://motherduck.com/settings/tokens):

```bash
export MOTHERDUCK_TOKEN=your-token-here
```

**Azure SQL (cloud):**

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
      encrypt: true
      trust_cert: false
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

📖 **[Step-by-step setup guide →](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Getting-Started)**

---

## Data Schemas

**jaffle_shop** (e-commerce):

- **[customers](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#customers)** - Customer records with email addresses and soft delete tracking
- **[products](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#products)** - Product catalog with pricing and categories
- **[orders](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#orders)** - Order transactions with status tracking and customer relationships
- **[order_items](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#order_items)** - Line items linking products to orders with quantities and pricing
- **[payments](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#payments)** - Payment records linked to orders (added in deltas)

**jaffle_crm** (marketing):

- **[campaigns](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#campaigns)** - Marketing campaigns with budgets and dates
- **[email_activity](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#email_activity)** - Email engagement metrics (sent, opened, clicked)
- **[web_sessions](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas#web_sessions)** - Website session tracking with page views

📊 **[Complete schema documentation with ID ranges →](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Data-Schemas)**

---

## What's Inside

```
dbt-origin-simulator-ops/
├── macros/              # Four operations: load_baseline, apply_delta, reset, status
├── data/
│   ├── duckdb/         # DuckDB/MotherDuck SQL files (baseline, deltas, utilities)
│   ├── azure/          # Azure SQL files (in development)
│   └── databricks/     # Databricks SQL files (planned)
├── extras/              # Optional templates for your project
│   ├── dbt/            # sources.yml, profiles.yml examples
│   ├── soda/           # Data quality contracts
│   ├── vscode/         # VS Code tasks for Command Palette
│   └── cicd/           # GitHub Actions workflow examples
└── scripts/             # Development and testing scripts
```

---

## Configuration

```yaml
# dbt_project.yml (optional overrides)
vars:
  origin_simulator_ops:
    shop_db: 'jaffle_shop'  # default
    crm_db: 'jaffle_crm'    # default
```

**Note:** For MotherDuck, databases are created automatically. For Azure SQL, databases must be provisioned via the [infrastructure repo](https://github.com/feriksen-personal/dbt-origin-simulator-infra).

For detailed documentation, see the [project wiki](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki)

---

## Contributing

Contributions welcome! Please open an issue or submit a pull request. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Acknowledgments

- Built to complement [dbt-origin-simulator-infra](https://github.com/feriksen-personal/dbt-origin-simulator-infra) infrastructure repo
- Inspired by the [Jaffle Shop](https://github.com/dbt-labs/jaffle_shop) demo project

---

## License

MIT License - see [LICENSE](LICENSE) file.

---

**Questions?** [Open an issue](https://github.com/feriksen-personal/dbt-origin-simulator-ops/issues) | **Detailed docs:** [Project wiki](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki)
