# Extras: Optional Quality-of-Life Additions

This folder contains optional files that users can copy into their own projects to enhance their development experience with this package.

**Important**: These files are templates for YOUR project, not part of the package itself. Copy and customize them as needed.

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

- **[Soda Core Contracts](soda/)** - Data quality checks for all tables
  - Schema validation
  - Foreign key integrity checks
  - SLA/freshness monitoring aligned with delta days
  - Soft delete validation
  - Configuration for all 3 platforms

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
cp extras/dbt/sources.yml models/staging/demo_source/sources.yml

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
export DEMO_SQL_SERVER=your-server
export DEMO_SQL_USER=your-user
export DEMO_SQL_PASSWORD=your-password

# Test each target
dbt debug --profile demo_source --target dev         # Local DuckDB
dbt debug --profile demo_source --target motherduck  # MotherDuck cloud
dbt debug --profile demo_source --target azure       # Azure SQL

# Use specific target with operations
dbt run-operation demo_load_baseline --profile demo_source --target motherduck
```

### 3. Soda Core

```bash
# Install Soda Core
pip install soda-core-duckdb

# Run data quality checks
soda scan -d demo_source -c extras/soda/configuration.yml extras/soda/contracts/jaffle_shop.yml
soda scan -d demo_source -c extras/soda/configuration.yml extras/soda/contracts/jaffle_crm.yml
```

### 4. VS Code Tasks

```bash
# Copy to your project's .vscode/ directory
mkdir -p .vscode
cp extras/vscode/tasks.json .vscode/tasks.json

# Use with:
# Cmd+Shift+P → "Tasks: Run Task" → Select operation
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

# Customize:
# - Profile names
# - Your project's dbt models
# - Add GitHub secrets for MotherDuck token
```

---

## Customization Tips

### Profile Names
If you use a different profile name, update all examples:
```yaml
# Change from:
--profile demo_source

# To:
--profile my_project
```

### Database Names
If you override the default database names:
```yaml
# In your dbt_project.yml
vars:
  demo_source_ops:
    shop_db: 'my_shop'
    crm_db: 'my_crm'

# Update sources.yml database references accordingly
```

### Targets
All examples use `--profile demo_source` without specifying target (uses default `dev`).

To use a specific target:
```bash
# MotherDuck
dbt run-operation demo_load_baseline --profile demo_source --target motherduck

# Azure SQL
dbt run-operation demo_load_baseline --profile demo_source --target azure
```

Or override in Makefile/justfile with environment variables:
```bash
make baseline TARGET=motherduck
```

---

## Need Help?

- **Questions?** [Open an issue](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/issues)
- **Wiki**: [Full documentation](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki)
- **Getting Started**: [Setup guide](https://github.com/feriksen-personal/dbt-azure-demo-source-ops/wiki/Getting-Started)
