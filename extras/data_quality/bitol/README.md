# Bitol Data Contracts (ODCS)

Data contracts following the **Open Data Contract Standard** (ODCS) from Bitol.

## What is ODCS?

The [Open Data Contract Standard](https://github.com/bitol-io/open-data-contract-standard) is an open-source specification for describing data contracts in a platform-agnostic way. It provides a standardized format for documenting:

- **Schema definitions** - Field names, types, constraints
- **Data quality rules** - Validation checks and expectations
- **Metadata** - Ownership, versioning, tags
- **Server configurations** - Multi-platform connection details

## Why Use ODCS Contracts?

**Industry Standard**: ODCS is gaining adoption as a common format for data contracts across tools and platforms.

**Tool Integration**: Contracts can be validated, tested, and transformed using the datacontract-cli and other ODCS-compatible tools.

**Multi-Platform**: Single contract definition works across DuckDB, Databricks, Snowflake, and more.

**Deterministic Validation**: Our contracts leverage the deterministic data in this package - you know exactly what to expect at each phase (baseline, Day 1, Day 2, Day 3).

## Contracts Provided

### jaffle_shop (ERP System)

- **[jaffle_shop_customers.yml](contracts/jaffle_shop_customers.yml)** - Customer master data
  - Baseline: 5 customers (IDs 1-5)
  - Day 1: +1 customer (ID 6)

- **[jaffle_shop_products.yml](contracts/jaffle_shop_products.yml)** - Product catalog
  - Baseline: 5 products (IDs 1-5)
  - Day 2: Product ID 3 price update

- **[jaffle_shop_orders.yml](contracts/jaffle_shop_orders.yml)** - Customer orders
  - Baseline: 5 orders (IDs 1-5)
  - Day 1: +3 orders (IDs 6-8)
  - Day 2: +3 orders (IDs 9-11)
  - Day 3: +3 orders (IDs 12-14)

- **[jaffle_shop_order_items.yml](contracts/jaffle_shop_order_items.yml)** - Order line items
  - Baseline: 10 order items (IDs 1-10)
  - Day 1: +6 items (IDs 11-16)
  - Day 2: +6 items (IDs 17-22)
  - Day 3: +6 items (IDs 23-28)

- **[jaffle_shop_payments.yml](contracts/jaffle_shop_payments.yml)** - Payment records
  - Baseline: 0 payments (empty table)
  - Day 1: +3 payments (IDs 1-3)
  - Day 2: +3 payments (IDs 4-6)
  - Day 3: +3 payments (IDs 7-9)

### jaffle_crm (Marketing System)

- **[jaffle_crm_campaigns.yml](contracts/jaffle_crm_campaigns.yml)** - Marketing campaigns
  - Baseline: 3 campaigns (IDs 1-3)

- **[jaffle_crm_email_activity.yml](contracts/jaffle_crm_email_activity.yml)** - Email engagement events
  - Baseline: 10 email activities (IDs 1-10)
  - Day 1: +3 activities (IDs 11-13)
  - Day 2: +3 activities (IDs 14-16)
  - Day 3: +3 activities (IDs 17-19)

- **[jaffle_crm_web_sessions.yml](contracts/jaffle_crm_web_sessions.yml)** - Web session events
  - Baseline: 10 web sessions (IDs 1-10)
  - Day 1: +3 sessions (IDs 11-13)
  - Day 2: +3 sessions (IDs 14-16)
  - Day 3: +3 sessions (IDs 17-19)

## Tooling

### Data Contract CLI

Validate and test contracts using the [datacontract-cli](https://github.com/datacontract/datacontract-cli):

```bash
# Install
pip install datacontract-cli

# Validate contract structure
datacontract test contracts/jaffle_shop_customers.yml

# Export to different formats
datacontract export contracts/jaffle_shop_customers.yml --format dbt
datacontract export contracts/jaffle_shop_customers.yml --format sql
datacontract export contracts/jaffle_shop_customers.yml --format great-expectations

# Generate documentation
datacontract export contracts/jaffle_shop_customers.yml --format html > customers_contract.html
```

### Example Workflow

```bash
# 1. Load baseline data
dbt run-operation origin_load_baseline --profile ingestion_simulator

# 2. Validate contracts against baseline state
datacontract test contracts/jaffle_shop_customers.yml
datacontract test contracts/jaffle_shop_orders.yml
datacontract test contracts/jaffle_crm_campaigns.yml

# 3. Apply Day 1 delta
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator

# 4. Update contract for Day 1 state and revalidate
# (Or use separate contracts for each delta state)
datacontract test contracts/jaffle_shop_customers.yml
```

## Using These Contracts

### 1. Validation

Test that actual data matches the contract:

```bash
# Set connection details
export DUCKDB_PATH="data/demo_source.duckdb"

# Validate
datacontract test contracts/jaffle_shop_customers.yml
```

### 2. Documentation Generation

Generate human-readable documentation:

```bash
# HTML docs
datacontract export contracts/jaffle_shop_customers.yml --format html

# Markdown docs
datacontract export contracts/jaffle_shop_customers.yml --format markdown
```

### 3. Code Generation

Generate dbt sources, SQL DDL, or other artifacts:

```bash
# Generate dbt source definition
datacontract export contracts/jaffle_shop_customers.yml --format dbt

# Generate SQL DDL
datacontract export contracts/jaffle_shop_customers.yml --format sql

# Generate Avro schema
datacontract export contracts/jaffle_shop_customers.yml --format avro
```

### 4. Quality Check Extraction

Extract quality checks for other tools:

```bash
# Export Soda checks
datacontract export contracts/jaffle_shop_customers.yml --format soda

# Export Great Expectations suite
datacontract export contracts/jaffle_shop_customers.yml --format great-expectations
```

## Integration with CI/CD

```yaml
# .github/workflows/validate-contracts.yml
name: Validate Data Contracts

on: [push]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install datacontract-cli
        run: pip install datacontract-cli

      - name: Load baseline data
        run: dbt run-operation origin_load_baseline --profile ingestion_simulator

      - name: Validate contracts
        run: |
          datacontract test extras/data_quality/bitol/contracts/jaffle_shop_customers.yml
          datacontract test extras/data_quality/bitol/contracts/jaffle_shop_orders.yml
          datacontract test extras/data_quality/bitol/contracts/jaffle_crm_campaigns.yml
```

## Resources

- **[ODCS Specification](https://github.com/bitol-io/open-data-contract-standard)** - Full specification and examples
- **[datacontract-cli](https://github.com/datacontract/datacontract-cli)** - CLI tool for working with contracts
- **[Data Contracts in Action](https://christophershayan.medium.com/data-contracts-in-action-bc66dd90cce9)** - Practical guide by Christopher Shayan
- **[ODCS Playground](https://datacontract.com/)** - Interactive tool for creating and validating contracts

## Deterministic Data Advantage

Because this package provides **deterministic data evolution**, you can:

- **Document exact expected states** - "Baseline has 5 customers, Day 1 has 6"
- **Write assertive quality checks** - `row_count = 5` (not `row_count > 0`)
- **Test contract evolution** - Validate how contracts change across deltas
- **Demonstrate contract-driven development** - Show how contracts guide development

See the [Operations Guide](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Operations-Guide#understanding-deterministic-evolution) for complete details on expected state at each delta phase.
