# dbt-origin-simulator-ops

**Control plane for deterministic, incremental source system simulation** — four operations to manage upstream databases your ingestion pipelines pull from.

---

## What This Creates

This package creates and manages **source databases** — the upstream systems your pipelines ingest *from*, not the destination.

Two simulated systems (inspired by dbt Labs' [Jaffle Shop](https://github.com/dbt-labs/jaffle_shop)):

| Database | Business Domain | Tables |
|----------|-----------------|--------|
| **jaffle_shop** | ERP / e-commerce | customers, products, orders, order_items, payments |
| **jaffle_crm** | Marketing platform | campaigns, email_activity, web_sessions |

Your dbt project, Lakeflow Connect, Fivetran, or Spark jobs consume these as external sources.

---

## Core Concepts

**Source-side simulation** — This package manages the databases your pipelines ingest *from*, not your target warehouse. Think of it as a controllable stand-in for production ERP, CRM, and marketing systems.

**Deterministic** — Same data every run. Customer #101 always appears in Day 1. Order #561 always gets created in Day 2. Write assertions, document expected results, debug with confidence.

**Incremental** — Controlled progression through deltas. Each delta introduces new records, updates existing ones, and soft-deletes others — mirroring real source system behavior over time.

**Portable** — Develop locally on DuckDB (zero cost), deploy source databases to Databricks or Azure SQL. Same schemas, same increments, different platforms.

---

## Quick Start

```yaml
# packages.yml
packages:
  - git: "https://github.com/feriksen-personal/dbt-origin-simulator-ops"
    revision: v1.0.0
```

```bash
dbt deps
dbt run-operation origin_load_baseline --profile ingestion_simulator
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
dbt run-operation origin_status --profile ingestion_simulator
```

> ⚠️ Always use `--profile` to target your source database connection — never run against your default (target) profile.

📖 **[Full setup guide →](Getting-Started)**

---

## The Four Operations

| Operation | Purpose |
|-----------|---------|
| `origin_load_baseline` | Initialize source systems with baseline data |
| `origin_apply_delta` | Apply incremental changes (day 1, 2, or 3) |
| `origin_reset` | Reset sources to baseline state |
| `origin_status` | Inspect current source state |

📚 **[Detailed Operations Guide →](Operations-Guide)**

---

## Documentation

| Page | Description |
|------|-------------|
| **[Getting Started](Getting-Started)** | Installation, platform setup |
| **[Operations Guide](Operations-Guide)** | Detailed usage for all four operations |
| **[Incremental Load Reference](Incremental-Load-Reference)** | Row counts at each state (baseline, day 1/2/3) |
| **[Data Schemas](Data-Schemas)** | Table structures, relationships, ID ranges |
| **[Use Cases and Platforms](Use-Cases-and-Platforms)** | When to use what, example workflows |
| **[CI/CD Integration](CI-CD-Integration)** | GitHub Actions, Azure DevOps, GitLab CI |
| **[Configuration Reference](Configuration-Reference)** | All variables and settings |
| **[Extras](Extras)** | Soda contracts, ODCS definitions, VS Code tasks |

---

## Platforms

| Platform | Use Case | Status |
|----------|----------|--------|
| **DuckDB** | Local development, CI/CD | ✅ Supported |
| **MotherDuck** | Team collaboration, shared environments | ✅ Supported |
| **Databricks** | Unity Catalog, Delta Sharing ingestion patterns | ✅ Supported |
| **Azure SQL** | CDC-enabled sources, change tracking ingestion patterns | ⚠️ In development |

---

## Links

- **Repository:** [github.com/feriksen-personal/dbt-origin-simulator-ops](https://github.com/feriksen-personal/dbt-origin-simulator-ops)
- **Issues:** [Report bugs or request features](https://github.com/feriksen-personal/dbt-origin-simulator-ops/issues)
- **Contributing:** [CONTRIBUTING.md](https://github.com/feriksen-personal/dbt-origin-simulator-ops/blob/main/CONTRIBUTING.md)
