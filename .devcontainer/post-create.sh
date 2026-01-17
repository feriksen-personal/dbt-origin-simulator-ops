#!/bin/bash
# =============================================================================
# post-create.sh - Devcontainer post-create setup
# =============================================================================
# Installs additional tools not available as devcontainer features.
# This script is idempotent - safe to run multiple times.
# =============================================================================
set -e

echo "=== Post-create setup starting ==="

# Install jq
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
    echo "jq installed"
else
    echo "jq already installed"
fi

# Install yamllint
if ! command -v yamllint &> /dev/null; then
    echo "Installing yamllint..."
    pip install --user yamllint
    echo "yamllint installed"
else
    echo "yamllint already installed"
fi

# Install dbt-core
if ! command -v dbt &> /dev/null; then
    echo "Installing dbt-core..."
    pip install --user dbt-core
    echo "dbt-core installed"
else
    echo "dbt-core already installed"
fi

# Install zsh plugins (autosuggestions & syntax highlighting)
ZSH_PLUGINS_DIR="${HOME}/.zsh"
mkdir -p "$ZSH_PLUGINS_DIR"

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
else
    echo "zsh-autosuggestions already installed"
fi

if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
else
    echo "zsh-syntax-highlighting already installed"
fi

# Source plugins in .zshrc if not already there
if ! grep -q 'zsh-autosuggestions' ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'ZSHRC'

# Zsh plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSHRC
    echo "Added zsh plugins to .zshrc"
fi

# Verify installations
echo ""
echo "=== Verifying installations ==="
echo -n "gh: "; gh --version | head -1
echo -n "python: "; python --version
echo -n "jq: "; jq --version
echo -n "yamllint: "; yamllint --version
echo -n "dbt: "; dbt --version | head -1

echo ""
echo "=== Post-create setup complete ==="
