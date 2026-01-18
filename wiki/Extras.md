# Extras

Ready-to-use templates to accelerate your setup.

The `extras/` folder contains dbt configurations, data quality contracts, and developer tooling. Copy what you need into your project.

---

## Overview

```
extras/
├── dbt/                    # sources.yml, profiles.yml.example
├── data_quality/
│   ├── soda/               # Contracts + deterministic scans
│   └── bitol/              # ODCS contracts (datacontract-cli compatible)
├── vscode/                 # Command palette tasks
└── cicd/                   # GitHub Actions workflow
```

---

## dbt Integration

### sources.yml

Complete source definitions for `jaffle_shop` and `jaffle_crm` with:
- Column descriptions
- Freshness checks
- Documentation references

**Usage:** Copy to your dbt project's `models/` directory.

```yaml
# Example excerpt
sources:
  - name: jaffle_shop
    database: jaffle_shop
    tables:
      - name: customers
        description: Customer master data with soft delete pattern
        columns:
          - name: customer_id
            description: Primary key
          - name: deleted_at
            description: Soft delete timestamp (NULL = active)
```

### profiles.yml.example

Connection templates for all four platforms. Copy and customize for your environment.

---

## Data Quality — Soda (Core or Cloud)

[Soda](https://www.soda.io/) is a data quality platform that lets you define checks as code and run them against your data. **Soda Core** is the open-source CLI; **Soda Cloud** adds collaboration, alerting, and incident management.

📖 **[Soda documentation](https://docs.soda.io/)** · **[Data contracts reference](https://docs.soda.io/soda/data-contracts.html)**

### Contracts (`data_quality/soda/contracts/`)

Generic validation patterns for schema integrity and business rules:
- `jaffle_shop.yml` — Validates customers, products, orders, order_items, payments
- `jaffle_crm.yml` — Validates campaigns, email_activity, web_sessions

**What they check:**
- Required columns exist
- Primary keys are unique and not null
- Foreign key relationships are valid
- Business rules (e.g., order amounts > 0)

### Scans (`data_quality/soda/scans/`)

Deterministic integration tests with **exact row counts** per state:

| Scan | Purpose |
|------|---------|
| `baseline_checks.yml` | Validate baseline state (Day 0) |
| `delta_day1_checks.yml` | Validate after Day 1 |
| `delta_day2_checks.yml` | Validate after Day 2 |
| `delta_day3_checks.yml` | Validate after Day 3 |
| `relationship_checks.yml` | Cross-table referential integrity (any state) |

**Example usage:**

```bash
# After loading baseline
dbt run-operation origin_load_baseline --profile ingestion_simulator
soda scan -d ingestion_simulator -c extras/data_quality/soda/configuration.yml extras/data_quality/soda/scans/baseline_checks.yml

# After Day 1
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
soda scan -d ingestion_simulator -c extras/data_quality/soda/configuration.yml extras/data_quality/soda/scans/delta_day1_checks.yml
```

### Configuration (`data_quality/soda/configuration.yml`)

Soda connection config for DuckDB, Databricks, and Azure SQL. Update with your credentials.

---

## Data Quality — ODCS (Bitol)

[ODCS (Open Data Contract Standard)](https://bitol.io/open-data-contract-standard/) is a vendor-neutral, open standard for defining data contracts. It provides a structured way to describe schemas, quality rules, SLAs, and ownership metadata in a machine-readable format.

📖 **[ODCS specification](https://github.com/bitol-io/open-data-contract-standard)** · **[datacontract-cli](https://github.com/datacontract/datacontract-cli)**

### Contracts (`data_quality/bitol/contracts/`)

Eight ODCS contract definitions, one per table:

```
data_quality/bitol/contracts/
├── jaffle_shop_customers.yml
├── jaffle_shop_products.yml
├── jaffle_shop_orders.yml
├── jaffle_shop_order_items.yml
├── jaffle_shop_payments.yml
├── jaffle_crm_campaigns.yml
├── jaffle_crm_email_activity.yml
└── jaffle_crm_web_sessions.yml
```

**What they define:**
- Schema (columns, types, constraints)
- Data quality rules
- Ownership and SLA metadata
- Semantic descriptions

### Using with datacontract-cli

```bash
# Install
pip install datacontract-cli

# Validate contract syntax
datacontract lint extras/data_quality/bitol/contracts/jaffle_shop_customers.yml

# Generate documentation
datacontract export --format html extras/data_quality/bitol/contracts/jaffle_shop_customers.yml

# Test against live data
datacontract test extras/data_quality/bitol/contracts/jaffle_shop_customers.yml
```

---

## Developer Experience

### VS Code Tasks (`vscode/tasks.json`)

Command Palette actions for all operations. Copy to your project's `.vscode/` directory.

**Available tasks:**
- `[dbt-origin-simulator]: Load Baseline`
- `[dbt-origin-simulator]: Apply Delta Day 1`
- `[dbt-origin-simulator]: Apply Delta Day 2`
- `[dbt-origin-simulator]: Apply Delta Day 3`
- `[dbt-origin-simulator]: Reset to Baseline`
- `[dbt-origin-simulator]: Check Status`

**Usage:**
1. Copy `extras/vscode/tasks.json` to `.vscode/tasks.json`
2. Open Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)
3. Type "Run Task"
4. Select the operation

Tasks automatically use the correct `--profile` flag.

---

### GitHub Actions (`cicd/github-actions.yml`)

CI/CD workflow template with:
- Baseline loading
- Incremental delta application
- Data quality validation
- Matrix testing across platforms

**Example workflow:**

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install dbt-core dbt-duckdb
          dbt deps
      
      - name: Load baseline
        run: dbt run-operation origin_load_baseline --profile ingestion_simulator
      
      - name: Run dbt models
        run: dbt run --profile my_project
      
      - name: Apply Day 1 delta
        run: dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
      
      - name: Run incremental models
        run: dbt run --profile my_project
      
      - name: Validate
        run: dbt test --profile my_project
```

**Key pattern:** DuckDB in CI/CD = zero cloud costs for testing. Same source data, same increments, predictable assertions.

---

## Quick Reference

| Extra | Location | Purpose |
|-------|----------|---------|
| sources.yml | `extras/dbt/` | dbt source definitions |
| profiles.yml.example | `extras/dbt/` | Connection templates |
| Soda contracts | `extras/data_quality/soda/contracts/` | Generic validation |
| Soda scans | `extras/data_quality/soda/scans/` | Deterministic state tests |
| ODCS contracts | `extras/data_quality/bitol/contracts/` | Data contract definitions |
| VS Code tasks | `extras/vscode/` | Command Palette actions |
| GitHub Actions | `extras/cicd/` | CI/CD workflow template |
