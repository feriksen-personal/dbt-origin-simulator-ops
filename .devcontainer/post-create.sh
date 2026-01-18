#!/bin/bash
# =============================================================================
# post-create.sh - Devcontainer post-create setup
# =============================================================================
# Installs dbt-core, dbt adapters (duckdb, sqlserver), and development tools.
#
# Packages installed:
#   - dbt-core: Core dbt framework
#   - dbt-duckdb: DuckDB adapter for local development/testing
#   - dbt-sqlserver: Azure SQL adapter for demo/POC environments
#   - duckdb: Python client for testing SQL files
#   - yamllint: YAML validation
#
# System dependencies:
#   - ODBC Driver 18 for SQL Server (required by dbt-sqlserver)
#
# This script is idempotent - safe to run multiple times.
# =============================================================================
set -e

echo "=== Post-create setup starting ==="

# Install ODBC Driver 18 for SQL Server (required by dbt-sqlserver)
echo "Installing ODBC Driver 18 for SQL Server..."
if ! odbcinst -q -d -n "ODBC Driver 18 for SQL Server" > /dev/null 2>&1; then
    # Add Microsoft package repository
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc > /dev/null

    # Detect Debian/Ubuntu version for correct repo
    if [ -f /etc/debian_version ]; then
        # Use Debian 12 (bookworm) repo - works for most Debian-based systems
        echo "deb [arch=amd64,arm64] https://packages.microsoft.com/debian/12/prod bookworm main" | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
    fi

    sudo apt-get update -qq
    sudo ACCEPT_EULA=Y apt-get install -y -qq msodbcsql18 unixodbc-dev
    echo "ODBC Driver 18 installed successfully"
else
    echo "ODBC Driver 18 already installed"
fi

# Install dbt packages and development tools
echo "Installing dbt-core, adapters, and development tools..."
pip install --no-cache-dir \
    dbt-core \
    dbt-duckdb \
    dbt-sqlserver \
    duckdb \
    yamllint

# Configure Starship
echo "Configuring Starship prompt..."
mkdir -p ~/.config
cp .devcontainer/starship.toml ~/.config/starship.toml

# Verify installations
echo ""
echo "=== Verifying installations ==="
echo -n "gh: "; gh --version | head -1
echo -n "python: "; python --version
echo -n "duckdb: "; python -c "import duckdb; print(duckdb.__version__)"
echo -n "yamllint: "; yamllint --version
echo -n "dbt-core: "; dbt --version | head -1
echo "dbt adapters:"
dbt --version | grep -E "(duckdb|sqlserver)" || echo "  (checking available adapters...)"
echo -n "ODBC Driver: "; odbcinst -q -d -n "ODBC Driver 18 for SQL Server" 2>/dev/null && echo "installed" || echo "not found"

echo ""
echo "=== Post-create setup complete ==="
