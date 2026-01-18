# CI/CD Workflows

This directory contains GitHub Actions workflows for continuous integration and testing across multiple platforms.

## Workflows

### 1. Main Branch CI (`test-package.yml`)

**Trigger**: Pushes to `main` branch only

**Purpose**: Validates the main branch after merges

**Jobs**:
- Validate dbt Configuration
- Lint Package
- Validate Package Structure
- Test DuckDB Operations (with PR comments)

**Use case**: Final validation after PR merge to ensure main branch stays healthy

---

### 2. Feature Branch CI (`feature-branch-ci.yml`)

**Trigger**: Pushes to any branch except `main`

**Purpose**: Fast validation on feature branches during development

**Jobs**:
- Validate dbt Configuration (dbt parse)
- Lint Package (sqlfluff, YAML validation)
- Validate Package Structure (required files/directories)

**Use case**: Fast feedback loop for developers working on feature branches

**Note**: Validation-only workflow (~30 seconds). Full integration testing happens at PR time.

---

### 3. PR CI (`pr-ci.yml`)

**Trigger**: Pull requests to `main` branch

**Purpose**: Comprehensive testing before merge, including cloud platforms

**Jobs**:
- Validate dbt Configuration
- Lint Package
- Validate Package Structure
- **Test DuckDB Operations** (with PR comment showing verification tables)
- **Test Databricks Operations** (conditional, with PR comment)

**Platform Testing**:
- **DuckDB**: Always tested (local, fast)
- **Databricks**: Conditionally tested if secrets are available
- **MotherDuck**: Not tested (assumes DuckDB parity)

**Databricks Testing**:
The Databricks test job only runs if:
1. PR is from the same repository (not a fork)
2. Repository variable `DATABRICKS_ENABLED` is set to `'true'`
3. All required secrets are configured:
   - `DATABRICKS_SERVER_HOSTNAME`
   - `DATABRICKS_HTTP_PATH`
   - `DATABRICKS_TOKEN`
   - `DATABRICKS_CATALOG`

**Use case**: Final validation gate before merging PRs

---

## Configuration

### Repository Secrets (for Databricks testing)

To enable Databricks testing in PR CI, configure these secrets in your repository:

```
Settings → Secrets and variables → Actions → Repository secrets
```

Required secrets:
- `DATABRICKS_SERVER_HOSTNAME`: Your Databricks workspace hostname (e.g., `dbc-xxxxx.cloud.databricks.com`)
- `DATABRICKS_HTTP_PATH`: SQL Warehouse HTTP path (e.g., `/sql/1.0/warehouses/xxxxx`)
- `DATABRICKS_TOKEN`: Personal access token with SQL Warehouse access
- `DATABRICKS_CATALOG`: Catalog name for testing (e.g., `origin_simulator_jaffle_corp`)

### Repository Variables

```
Settings → Secrets and variables → Actions → Repository variables
```

Optional variables:
- `DATABRICKS_ENABLED`: Set to `'true'` to enable Databricks testing in PR CI

---

## Workflow Summary

| Event | Workflow | Validation | DuckDB Tests | Databricks Tests | PR Comments |
|-------|----------|------------|--------------|------------------|-------------|
| Push to `main` | Main Branch CI | ✅ | ✅ | ❌ | ✅ |
| Push to feature branch | Feature Branch CI | ✅ | ❌ | ❌ | ❌ |
| PR to `main` | PR CI | ✅ | ✅ | ⚠️* | ✅ |

\* Databricks testing in PR CI is conditional on secrets being configured

**Validation**: dbt parse, linting, structure checks (~30 seconds)
**DuckDB Tests**: Full integration testing (baseline, verify, reset, status)
**Databricks Tests**: Full integration testing with Unity Catalog

---

## Test Coverage

### DuckDB Tests (all workflows)
1. **Parse**: Validate dbt project configuration
2. **Baseline Load**: Create schemas and load Day 0 data
3. **Verify Baseline**: Check row counts match expected values
4. **Status**: Display current state
5. **Reset**: Truncate and reload baseline
6. **Verify Reset**: Confirm baseline state restored

### Databricks Tests (PR CI only, when enabled)
1. **Connection**: Verify Databricks SQL Warehouse connectivity
2. **Baseline Load**: Create Unity Catalog schemas and Delta tables
3. **Status**: Display current row counts
4. **Reset**: Truncate and reload baseline
5. **Final Status**: Verify state after reset

---

## Adding New Platform Tests

To add testing for a new platform (e.g., Azure SQL):

1. Add test job to `pr-ci.yml` (conditional on secrets)
2. Create repository secrets for platform credentials
3. Install platform-specific dbt adapter
4. Run same test operations: baseline → status → reset
5. Post results to PR comment

Example job structure:
```yaml
test-<platform>:
  name: Test <Platform> Operations
  runs-on: ubuntu-latest
  if: |
    github.event.pull_request.head.repo.full_name == github.repository &&
    vars.<PLATFORM>_ENABLED == 'true'
  steps:
    - name: Install dbt-<adapter>
      run: pip install dbt-<adapter>
    - name: Test baseline
      run: dbt run-operation origin_load_baseline --target <platform>
    # ... more tests
```

---

## Troubleshooting

### Databricks Tests Not Running

**Check**:
1. Is `DATABRICKS_ENABLED` variable set to `'true'`?
2. Are all four Databricks secrets configured?
3. Is the PR from the same repository (not a fork)?
4. Check workflow run logs for conditional evaluation

### DuckDB Tests Failing

**Common causes**:
1. Missing `CREATE SCHEMA` statements in baseline SQL
2. Macro syntax errors (check `dbt parse` output)
3. Foreign key violations (check load order in macros)

### PR Comments Not Posting

**Check**:
1. Workflow has `pull-requests: write` permission
2. `GH_TOKEN` is set correctly: `${{ github.token }}`
3. PR number is available: `${{ github.event.pull_request.number }}`
