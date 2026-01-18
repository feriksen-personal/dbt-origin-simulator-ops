# Contributing to dbt-origin-simulator-ops

Thank you for your interest in contributing! This package demonstrates production-grade data engineering patterns with deterministic, reproducible demo data across multiple platforms.

## Quick Start with Dev Container

**The easiest way to contribute is using the included Dev Container** - it provides a fully configured environment with all tools pre-installed:

### Option 1: GitHub Codespaces (Recommended)
1. Click the green "Code" button on GitHub
2. Select "Codespaces" → "Create codespace on [branch]"
3. Wait ~2 minutes for the environment to build
4. Everything is ready! All tools (dbt, DuckDB, Soda, Python, etc.) are installed

### Option 2: VS Code Dev Containers (Local)
1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install [VS Code Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Clone this repository
4. Open in VS Code → Command Palette (Cmd/Ctrl+Shift+P) → "Reopen in Container"
5. Wait for container to build - all dependencies installed automatically

**What you get in the Dev Container:**
- ✅ dbt Core with all adapters (DuckDB, Databricks, SQL Server)
- ✅ Python 3.11 with all dependencies
- ✅ Soda Core for data quality validation
- ✅ datacontract-cli for ODCS contracts
- ✅ GitHub CLI (gh) for PR management
- ✅ Pre-configured VS Code tasks
- ✅ Starship shell prompt
- ✅ Git, Make, and other development tools

**Why this matters:** You can start contributing in seconds without worrying about Python versions, dbt installation, adapter compatibility, or missing dependencies. It's the same environment used in CI/CD.

---

## Manual Setup (Without Dev Container)

If you prefer to set up your local environment:

### Prerequisites
- **dbt Core** >= 1.10.0
- **Python** >= 3.11
- **Git**

### Install Dependencies

```bash
# Clone the repository
git clone https://github.com/feriksen-personal/dbt-origin-simulator-ops.git
cd dbt-origin-simulator-ops

# Install dbt adapters (choose what you need)
pip install dbt-duckdb>=1.10.0        # For DuckDB/MotherDuck
pip install dbt-databricks>=1.10.0    # For Databricks
pip install dbt-sqlserver>=1.10.0     # For Azure SQL

# Optional: Install data quality tools
pip install soda-core-duckdb              # For DuckDB quality checks
pip install soda-core-spark[databricks]   # For Databricks quality checks
pip install datacontract-cli              # For ODCS contracts
```

### Verify Installation

```bash
# Test dbt connection
dbt debug --profile ingestion_simulator --target dev

# Load baseline data
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Check status
dbt run-operation origin_status --profile ingestion_simulator
```

---

## Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

**Branch naming conventions:**
- `feature/` - New functionality
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions/updates

### 2. Make Your Changes

The package is organized as follows:

```
dbt-origin-simulator-ops/
├── macros/
│   ├── _internal/        # SQL macros, routing logic
│   └── *.sql             # Public operation macros
├── data/
│   ├── duckdb/           # DuckDB SQL files
│   ├── databricks/       # Databricks Delta Lake SQL
│   └── sqlserver/        # Azure SQL files
├── extras/               # Optional templates for users
│   ├── dbt/              # Profile and source examples
│   ├── soda/             # Data quality contracts/scans
│   └── vscode/           # VS Code tasks
├── tests/                # dbt tests
└── .github/workflows/    # CI/CD pipelines
```

### 3. Test Your Changes

**Use VS Code Tasks** (Cmd/Ctrl+Shift+P → "Tasks: Run Task"):
- `[dbt-origin-simulator] Load Baseline` - Initialize data
- `[dbt-origin-simulator] Apply Day 1 Changes` - Test delta application
- `[dbt-origin-simulator] Check Status` - Verify row counts
- `[dbt-origin-simulator] Reset to Baseline` - Clean slate

**Or use dbt commands directly:**

```bash
# Test baseline load
dbt run-operation origin_load_baseline --profile ingestion_simulator

# Test delta application
dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
dbt run-operation origin_apply_delta --args '{day: 2}' --profile ingestion_simulator
dbt run-operation origin_apply_delta --args '{day: 3}' --profile ingestion_simulator

# Verify status
dbt run-operation origin_status --profile ingestion_simulator

# Reset for clean slate
dbt run-operation origin_reset --profile ingestion_simulator
```

**Multi-platform testing** (if you have credentials):

```bash
# Test on Databricks
dbt run-operation origin_load_baseline --profile ingestion_simulator --target databricks

# Test on MotherDuck
dbt run-operation origin_load_baseline --profile ingestion_simulator --target motherduck
```

### 4. Run Data Quality Checks (Optional)

If you're modifying data or schemas:

```bash
# Run Soda contracts
soda scan -d ingestion_simulator -c extras/soda/configuration.yml extras/soda/contracts/jaffle_shop.yml

# Run ODCS contracts
datacontract test extras/data_quality/bitol/contracts/jaffle_shop_customers.yml
```

### 5. Commit Your Changes

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Good commit messages
git commit -m "feat: add new delta operation for day 4"
git commit -m "fix: correct row count validation in origin_status"
git commit -m "docs: update README with Databricks examples"
git commit -m "refactor: simplify SQL routing logic"

# Include Co-Authored-By for pair programming
git commit -m "feat: add new feature

Co-Authored-By: Partner Name <partner@example.com>"
```

### 6. Push and Create Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create PR using GitHub CLI (if available)
gh pr create --title "feat: your feature name" --body "Description of changes"

# Or create PR manually on GitHub
```

---

## What to Contribute

We welcome contributions in these areas:

### 🚀 New Features
- Additional delta days (Day 4, 5, etc.)
- New source tables or relationships
- Support for additional platforms (Snowflake, BigQuery, etc.)
- Enhanced data quality checks

### 🐛 Bug Fixes
- SQL errors on specific platforms
- Incorrect row counts or data integrity issues
- Documentation errors

### 📚 Documentation
- Wiki improvements
- Usage examples
- Platform-specific guides
- Troubleshooting tips

### 🧪 Testing
- Additional test scenarios
- Platform compatibility tests
- Data quality validation

### 🎨 Developer Experience
- VS Code task improvements
- CI/CD enhancements
- Template updates in `extras/`

---

## Code Standards

### SQL Style
- Use lowercase for SQL keywords: `select`, `from`, `where`
- Indent with 4 spaces (no tabs)
- Fully qualify table names: `schema.table`
- Add comments for complex logic

### dbt Macros
- Prefix internal macros with `_` (e.g., `_get_sql`)
- Public macros use `origin_` prefix (e.g., `origin_load_baseline`)
- Document macro parameters and return values
- Use Jinja templating consistently

### Python/YAML
- Follow PEP 8 for Python code
- Use 2-space indentation for YAML
- Quote strings consistently in YAML

### Documentation
- Update README.md for user-facing changes
- Update Wiki for detailed guides
- Include examples in docstrings
- Update `extras/` templates as needed

---

## Testing Guidelines

### Deterministic Data
This package uses **deterministic, reproducible data**. Row counts are exact and predictable:

**Baseline (Day 0):**
- customers: 100, products: 20, orders: 500, order_items: 1200
- campaigns: 5, email_activity: 100, web_sessions: 150

**Day 1:** customers: 125, orders: 560, order_items: 1303
**Day 2:** customers: 147, orders: 615, order_items: 1387
**Day 3:** customers: 175, orders: 680, order_items: 1502

When adding changes, maintain these exact counts or update documentation.

### CI/CD Validation
All PRs run through automated checks:
- ✅ SQL syntax validation
- ✅ dbt compilation
- ✅ Baseline load test
- ✅ Delta application tests
- ✅ Row count verification
- ✅ Data quality scans (Soda + ODCS)

View CI results in the GitHub Actions tab.

---

## Need Help?

- 💬 **Questions?** [Open a Discussion](https://github.com/feriksen-personal/dbt-origin-simulator-ops/discussions)
- 🐛 **Found a bug?** [Open an Issue](https://github.com/feriksen-personal/dbt-origin-simulator-ops/issues)
- 📖 **Read the docs:** [Wiki](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki)
- 🎓 **Getting Started:** [Setup Guide](https://github.com/feriksen-personal/dbt-origin-simulator-ops/wiki/Getting-Started)

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).

**TL;DR:** Be respectful, inclusive, and constructive. We're here to build great data engineering tools together.

---

## License

By contributing, you agree that your contributions will be licensed under the same license as this project (see [LICENSE](LICENSE)).

---

**Thank you for contributing! Your work helps data engineers worldwide build better pipelines.** 🚀
