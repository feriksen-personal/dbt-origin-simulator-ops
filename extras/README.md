# Extras: Optional Quality-of-Life Additions

This folder contains optional files that users can copy into their own projects to enhance their development experience with this package.

**Important**: These files are templates for YOUR project, not part of the package itself. Copy and customize them as needed.

**Why these matter**: The package provides deterministic, reproducible demo data. These extras help you integrate that data into your workflow - defining sources, validating quality, and automating operations.

---

## What's Included

### dbt Integration

- **[sources.yml](dbt/sources.yml)** - Complete dbt source definitions for both `jaffle_shop` and `jaffle_crm` databases
  - All tables with column descriptions
  - Freshness checks configured
  - Ready to copy to your `models/` directory

- **[profiles.yml.example](dbt/profiles.yml.example)** - Profile templates for all 3 platforms (DuckDB, MotherDuck, Azure SQL)
  - Copy to `~/.dbt/profiles.yml`
  - Includes environment variable configuration
  - Examples for each target

### Data Quality

- **[Soda Core](data_quality/soda/)** - Data quality contracts, scans, and configuration
  - **Contracts**: Schema validation, integrity checks, business rules
  - **Scans**: Example scans for baseline, delta validation, and relationships
  - **Configuration**: Multi-platform setup (DuckDB, Databricks, Azure SQL)

- **[Bitol ODCS Contracts](data_quality/bitol/)** - Industry-standard data contracts
  - **Open Data Contract Standard** (ODCS) compliant
  - **datacontract-cli** compatible for validation and code generation
  - Platform-agnostic contract definitions with quality checks
  - Leverages deterministic data for assertive validation

### Developer Tools

- **[VS Code Tasks](vscode/tasks.json)** - Quick access to demo operations via Command Palette
  - Copy to your `.vscode/tasks.json`
  - Run operations with Cmd+Shift+P → "Tasks: Run Task"

- **[Makefile](scripts/Makefile)** - Common operations wrapped in make targets
  - `make baseline`, `make delta-1`, `make reset`, etc.
  - Workflow targets for common scenarios

- **[justfile](scripts/justfile)** - Modern alternative to Makefile
  - Better syntax, cleaner output
  - Same operations as Makefile

### CI/CD

- **[GitHub Actions](cicd/github-actions.yml)** - Example workflow for testing with demo sources
  - Load baseline → run models → apply deltas → test
  - Soda Core integration example
  - Matrix testing across platforms

---

## How to Use

### 1. dbt Sources

```bash
# Copy sources.yml to your project
cp extras/dbt/sources.yml models/staging/ingestion_simulator/sources.yml

# Customize database/schema names if needed
# Then reference in your models:
# {{ source('jaffle_shop', 'customers') }}
```

### 2. dbt Profiles

```bash
# Copy example to your profiles
cp extras/dbt/profiles.yml.example ~/.dbt/profiles.yml

# Customize the file for your environment
# - Choose your default target (dev, motherduck, or azure)
# - Update paths/settings as needed

# Set environment variables (for MotherDuck/Azure)
export MOTHERDUCK_TOKEN=your-token
export SQL_SERVER=your-server
export SQL_USER=your-user
export SQL_PASSWORD=your-password

# Test each target
dbt debug --profile ingestion_simulator --target dev         # Local DuckDB
dbt debug --profile ingestion_simulator --target motherduck  # MotherDuck cloud
dbt debug --profile ingestion_simulator --target azure       # Azure SQL

# Use specific target with operations
dbt run-operation origin_load_baseline --profile ingestion_simulator --target motherduck
```

### 3. Soda Core

```bash
# Install Soda Core for your platform
pip install soda-core-duckdb              # For DuckDB/MotherDuck
pip install soda-core-databricks          # For Databricks
pip install soda-core-sqlserver           # For Azure SQL

# Copy configuration file
cp extras/data_quality/soda/configuration.yml soda/configuration.yml

# Edit configuration.yml - choose your platform and set connection details

# Run contracts (schema validation, business rules, integrity checks)
dbt run-operation origin_load_baseline --profile ingestion_simulator
soda scan -d ingestion_simulator -c soda/configuration.yml extras/data_quality/soda/contracts/jaffle_shop.yml
soda scan -d ingestion_simulator -c soda/configuration.yml extras/data_quality/soda/contracts/jaffle_crm.yml

# Run scans (deterministic validation)
# Baseline state validation
soda scan -d ingestion_simulator -c soda/configuration.yml extras/data_quality/soda/scans/baseline_checks.yml

# Apply delta and validate
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
soda scan -d ingestion_simulator -c soda/configuration.yml extras/data_quality/soda/scans/delta_day1_checks.yml

# Relationship integrity checks (works at any state)
soda scan -d ingestion_simulator -c soda/configuration.yml extras/data_quality/soda/scans/relationship_checks.yml

# Optional: Connect to Soda Cloud for dashboards and alerts
# - Sign up at https://cloud.soda.io
# - Add soda_cloud section to configuration.yml with API keys
```

### 3b. Bitol ODCS Contracts

```bash
# Install datacontract-cli
pip install datacontract-cli

# Validate contracts against actual data
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Test baseline state
datacontract test extras/data_quality/bitol/contracts/jaffle_shop_customers.yml
datacontract test extras/data_quality/bitol/contracts/jaffle_shop_orders.yml
datacontract test extras/data_quality/bitol/contracts/jaffle_crm_campaigns.yml

# Generate artifacts from contracts
# dbt source definitions
datacontract export extras/data_quality/bitol/contracts/jaffle_shop_customers.yml --format dbt

# SQL DDL
datacontract export extras/data_quality/bitol/contracts/jaffle_shop_orders.yml --format sql

# HTML documentation
datacontract export extras/data_quality/bitol/contracts/jaffle_crm_campaigns.yml --format html > contracts.html

# See bitol/README.md for complete tooling guide
```

### 4. VS Code Tasks

```bash
# Copy to your project's .vscode/ directory
mkdir -p .vscode
cp extras/vscode/tasks.json .vscode/tasks.json

# Run tasks via Command Palette:
# Cmd+Shift+P (Mac) / Ctrl+Shift+P (Windows/Linux) → "Tasks: Run Task"

# Available tasks:
# - [dbt-origin-simulator] Load Baseline (Day 0)
# - [dbt-origin-simulator] Check Status
# - [dbt-origin-simulator] Apply Day 1 Changes
# - [dbt-origin-simulator] Apply Day 2 Changes
# - [dbt-origin-simulator] Apply Day 3 Changes
# - [dbt-origin-simulator] Reset to Baseline
# - [dbt-origin-simulator] Full Workflow (Baseline + All 3 Days)
# - [dbt-origin-simulator] Verify Baseline Data

# Customize for different targets:
# Edit .vscode/tasks.json and change --profile ingestion_simulator to your profile
# Or add --target flag: --profile ingestion_simulator --target motherduck
```

### 5. Makefile / justfile

```bash
# Copy to your project root
cp extras/scripts/Makefile .

# Use with:
make help           # Show all commands
make baseline       # Load baseline data
make delta-1        # Apply Day 1 changes
make full-demo      # Run through all 3 days

# Or with justfile:
cp extras/scripts/justfile .
just --list         # Show all commands
just baseline       # Load baseline data
```

### 6. GitHub Actions

```bash
# Copy to your workflow directory
mkdir -p .github/workflows
cp extras/cicd/github-actions.yml .github/workflows/test-with-demo-sources.yml

# The workflow includes 4 jobs:
# 1. test-baseline: Load baseline and run your dbt models
# 2. test-incremental: Apply Days 1-3 and test incremental models
# 3. test-data-quality: Run Soda Core quality checks (optional)
# 4. test-matrix: Test against DuckDB and MotherDuck (requires secret)

# Required customizations in the workflow file:
# 1. Replace "my_project" with your actual dbt profile name
# 2. Update the my_project profile configuration (warehouse type, connection details)
# 3. Adjust dbt build commands for your project structure
# 4. Add your project-specific tests

# GitHub Secrets (for MotherDuck matrix testing):
# Settings → Secrets and variables → Actions → New repository secret
# - Name: MOTHERDUCK_TOKEN
# - Value: Your MotherDuck service token from https://motherduck.com

# Optional: Soda Cloud integration
# Add these secrets if you want Soda Cloud dashboards:
# - SODA_CLOUD_API_KEY_ID
# - SODA_CLOUD_API_KEY_SECRET

# Workflow triggers:
# - Runs on pull requests to main
# - Runs on pushes to main
# - Customize triggers in the workflow file's "on:" section

# What each job does:
#
# test-baseline:
#   - Loads baseline source data (Day 0: 100 customers, 500 orders)
#   - Runs your dbt models against the demo sources
#   - Verifies data was loaded correctly
#
# test-incremental:
#   - Loads baseline, then applies Day 1, 2, and 3 deltas
#   - Tests that your incremental models handle changes correctly
#   - Useful for testing SCD Type 2, CDC, and incremental logic
#
# test-data-quality:
#   - Loads baseline and runs Soda Core quality checks
#   - Validates schema, foreign keys, business rules
#   - Applies Day 1 and re-checks to test data evolution
#
# test-matrix:
#   - Runs tests against both DuckDB (local) and MotherDuck (cloud)
#   - Ensures your models work across platforms
#   - MotherDuck requires MOTHERDUCK_TOKEN secret

# Performance tips:
# - Jobs run in parallel by default (faster CI)
# - dbt packages are cached between runs
# - Consider caching Python dependencies with setup-python cache option
# - MotherDuck cleanup step prevents database accumulation
```

---

## Customization Tips

### Profile Names
If you use a different profile name, update all examples:
```yaml
# Change from:
--profile ingestion_simulator

# To:
--profile my_project
```

### Database Names
If you override the default database names:
```yaml
# In your dbt_project.yml
vars:
  origin_simulator_ops:
    shop_db: 'my_shop'
    crm_db: 'my_crm'

# Update sources.yml database references accordingly
```

### Targets
All examples use `--profile ingestion_simulator` without specifying target (uses default `dev`).

To use a specific target:
```bash
# MotherDuck
dbt run-operation origin_load_baseline --profile ingestion_simulator --target motherduck

# Azure SQL
dbt run-operation origin_load_baseline --profile ingestion_simulator --target azure
```

Or override in Makefile/justfile with environment variables:
```bash
make baseline TARGET=motherduck
```

---

## Need Help?

- **Questions?** [Open an issue](https://github.com/feriksen-personal/dbt-origin-simulator-ops/issues)
- **Wiki**: [Full documentation](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki)
- **Getting Started**: [Setup guide](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Getting-Started)
