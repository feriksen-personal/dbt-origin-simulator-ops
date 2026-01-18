# Incremental Load Reference

Quick reference for expected row counts at each state. Use these values for CI/CD assertions and debugging.

---

## Baseline (Day 0)

Initial state after `origin_load_baseline`.

### jaffle_shop

| Table | Rows | ID Range |
|-------|------|----------|
| customers | 100 | 1-100 |
| products | 20 | 1-20 |
| orders | 500 | 1-500 |
| order_items | 1,200 | 1-1200 |
| payments | 0 | — |

### jaffle_crm

| Table | Rows | ID Range |
|-------|------|----------|
| campaigns | 5 | 1-5 |
| email_activity | 100 | 1-100 |
| web_sessions | 150 | 1-150 |

---

## After Day 1

State after `origin_apply_delta --args '{day: 1}'`.

### jaffle_shop

| Table | Rows | Change | New IDs |
|-------|------|--------|---------|
| customers | 125 | +25 | 101-125 |
| products | 20 | — | — |
| orders | 560 | +60 | 501-560 |
| order_items | 1,303 | +103 | 1201-1303 |
| payments | 272 | +272 | 1-272 |

### jaffle_crm

| Table | Rows | Change | New IDs |
|-------|------|--------|---------|
| campaigns | 5 | — | — |
| email_activity | 150 | +50 | 101-150 |
| web_sessions | 200 | +50 | 151-200 |

---

## After Day 2

State after `origin_apply_delta --args '{day: 2}'`.

### jaffle_shop

| Table | Rows | Change | New IDs |
|-------|------|--------|---------|
| customers | 147 | +22 | 126-147 |
| products | 20 | — | (updates only) |
| orders | 615 | +55 | 561-615 |
| order_items | 1,387 | +84 | 1304-1387 |
| payments | 316 | +44 | 273-316 |

### jaffle_crm

| Table | Rows | Change | New IDs |
|-------|------|--------|---------|
| campaigns | 5 | — | — |
| email_activity | 200 | +50 | 151-200 |
| web_sessions | 250 | +50 | 201-250 |

---

## After Day 3

State after `origin_apply_delta --args '{day: 3}'`.

### jaffle_shop

| Table | Rows | Change | New IDs |
|-------|------|--------|---------|
| customers | 175 | +28 | 148-175 |
| products | 20 | — | — |
| orders | 680 | +65 | 616-680 |
| order_items | 1,502 | +115 | 1388-1502 |
| payments | 374 | +58 | 317-374 |

### jaffle_crm

| Table | Rows | Change | New IDs |
|-------|------|--------|---------|
| campaigns | 5 | — | — |
| email_activity | 250 | +50 | 201-250 |
| web_sessions | 300 | +50 | 251-300 |

---

## Cumulative Summary

Total rows at each state:

| State | jaffle_shop | jaffle_crm | Total |
|-------|-------------|------------|-------|
| Baseline | 1,820 | 255 | 2,075 |
| After Day 1 | 2,280 | 355 | 2,635 |
| After Day 2 | 2,485 | 455 | 2,940 |
| After Day 3 | 2,751 | 555 | 3,306 |

---

## Using These Values

### CI/CD Assertions

```yaml
# GitHub Actions example
- name: Verify baseline state
  run: |
    COUNT=$(dbt run-operation origin_status --profile ingestion_simulator | grep customers | awk '{print $2}')
    [ "$COUNT" -eq "100" ] || exit 1
```

### dbt Tests

```yaml
# models/staging/schema.yml
models:
  - name: stg_customers
    tests:
      - dbt_utils.expression_is_true:
          expression: "count(*) = 100"
          config:
            where: "1=1"  # baseline state
```

---

**See also:** [Operations Guide](Operations-Guide) | [Data Schemas](Data-Schemas)
