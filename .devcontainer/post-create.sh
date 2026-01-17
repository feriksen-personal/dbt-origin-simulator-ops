#!/bin/bash
# =============================================================================
# post-create.sh - Devcontainer post-create setup
# =============================================================================
# Installs dbt-core and yamllint for dbt package development.
# This script is idempotent - safe to run multiple times.
# =============================================================================
set -e

echo "=== Post-create setup starting ==="

# Install dbt-core and yamllint
echo "Installing dbt-core and yamllint..."
pip install --no-cache-dir dbt-core yamllint

# Configure Starship
echo "Configuring Starship prompt..."
mkdir -p ~/.config
cp .devcontainer/starship.toml ~/.config/starship.toml

# Verify installations
echo ""
echo "=== Verifying installations ==="
echo -n "gh: "; gh --version | head -1
echo -n "python: "; python --version
echo -n "yamllint: "; yamllint --version
echo -n "dbt: "; dbt --version | head -1

echo ""
echo "=== Post-create setup complete ==="
