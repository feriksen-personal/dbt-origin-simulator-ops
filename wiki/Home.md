# Welcome to dbt-azure-demo-source-ops Wiki

Complete documentation for managing demo source data in dbt projects.

---

## Quick Navigation

### Getting Started
- [Installation & Setup](Getting-Started) - First-time setup for DuckDB and Azure SQL
- [Operations Guide](Operations-Guide) - How to use all 4 operations

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

### Supported Adapters
- **DuckDB** - Local development (zero cloud costs)
- **Azure SQL** - Cloud demos with CDC/change tracking

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
