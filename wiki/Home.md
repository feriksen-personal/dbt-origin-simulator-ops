# Welcome to dbt-azure-demo-source-ops Wiki

Complete documentation for managing demo source data in dbt projects.

---

## Quick Navigation

### Getting Started
- [Installation & Setup](Getting-Started) - First-time setup for DuckDB, MotherDuck, and Azure SQL
- [Operations Guide](Operations-Guide) - How to use all 4 operations
- [Use Cases & Platforms](Use-Cases-and-Platforms) - Platform comparison and when to use each

### Core Documentation
- [Data Schemas](Data-Schemas) - Tables, columns, ID ranges, and relationships
- [Custom Data](Custom-Data) - Adding your own test data (5000+ ID pattern)

### Reference
- [Configuration Reference](Configuration-Reference) - Variables and settings *(coming soon)*
- [FAQ](FAQ) - Frequently asked questions *(coming soon)*

### Advanced
- [Architecture](Architecture) - Design philosophy and orchestrator pattern *(coming soon)*
- [Troubleshooting](Troubleshooting) - Common issues and solutions *(coming soon)*
- [CI/CD Integration](CI-CD-Integration) - GitHub Actions & GitLab CI examples *(coming soon)*

---

## What's This Package?

**dbt-azure-demo-source-ops** provides four simple operations to manage realistic demo source data for dbt projects:

- `demo_load_baseline` - Initialize with baseline data
- `demo_apply_delta` - Apply day 1/2/3 changes (simulate business activity)
- `demo_reset` - Truncate and reload baseline
- `demo_status` - Show current row counts

### Supported Platforms
- **DuckDB (Local)** - Local development (zero cloud costs)
- **MotherDuck** - Cloud collaboration with shared databases (free tier available)
- **Azure SQL** - Cloud demos with CDC/change tracking

---

## How This Differs from Traditional Demo Databases

### Traditional Demo Databases

Popular databases like **Northwind Traders**, **AdventureWorks**, and **Pagila** are excellent for:

- Learning SQL queries and data transformations
- Building BI dashboards and reports
- Exploring schema design and normalization
- Practicing data modeling

**Key characteristic**: Static, complete datasets

### This Package: Data Engineering Focus

**dbt-azure-demo-source-ops** is designed for a different purpose:

- Learning **data integration patterns** (incremental loads, CDC, SCD Type 2)
- Testing **data pipeline orchestration** (Lakeflow Connect, Databricks workflows)
- Developing **change tracking strategies** (soft deletes, audit columns)
- Simulating **realistic source system evolution** over time
- Practicing **delta architecture patterns** in a controlled environment

**Key characteristic**: Dynamic, versioned source systems with reproducible state transitions

### Use Case Comparison

| Scenario                                 | Traditional Demo DB   | This Package                                |
| ---------------------------------------- | --------------------- | ------------------------------------------- |
| "How do I write a complex JOIN?"         | ✅ Northwind          | ❌ Not the focus                            |
| "How do I detect changed records?"       | ❌ Static data        | ✅ Apply deltas, observe changes            |
| "How do I test incremental loads?"       | ❌ No state evolution | ✅ Apply Day 1, then Day 2, then Day 3      |
| "How does CDC work?"                     | ❌ No change tracking | ✅ Azure SQL with change tracking enabled   |
| "How do I handle soft deletes?"          | ❌ No deleted records | ✅ `deleted_at` column pattern              |
| "How do I test pipeline reset/recovery?" | ❌ Can't reset state  | ✅ `demo_reset` operation                   |
| "How do I practice Lakeflow Connect?"    | ❌ Static source      | ✅ DuckDB/MotherDuck as evolving source     |

### Complementary, Not Competing

You might use both:

- **Traditional demo DB**: "What insights can I derive from sales data?"
- **This package**: "How do I incrementally sync those sales from the source system?"

This package is for the **infrastructure layer** - the often-overlooked but critical work of reliably getting data from point A to point B as it evolves.

---

## New to This Package?

1. Start with [Getting Started](Getting-Started) for installation and first-time setup
2. Review [Operations Guide](Operations-Guide) to understand the 4 core operations
3. Check [Data Schemas](Data-Schemas) to see what data is available
4. If you need custom test data, see [Custom Data](Custom-Data)

---

## Need Help?

- **Have questions?** Check the [FAQ](FAQ)
- **Encountered an error?** See [Troubleshooting](Troubleshooting)
- **Found a bug?** [Open an issue](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/issues)
- **Want to contribute?** See [Contributing](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/blob/main/CONTRIBUTING.md)

---

**Main Repository:** [dbt-azure-demo-source-ops](https://github.com/feriksen-personal/dbt-azure-demo-source-ops)
