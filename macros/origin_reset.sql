{#
  Resets demo source databases to baseline state.

  Truncates all tables in both jaffle_shop and jaffle_crm databases,
  then reloads baseline schema and seed data. This is useful for:
  - Starting fresh after applying deltas
  - Resetting to known state between demo sessions
  - Cleaning up after testing

  Usage:
    dbt run-operation origin_reset --profile ingestion_simulator

  Example output:
    Resetting demo databases to baseline...
    → Truncating jaffle_shop tables...
      ✓ Truncated jaffle_shop tables
    → Truncating jaffle_crm tables...
      ✓ Truncated jaffle_crm tables

    Loading baseline schema and data...
    → Creating jaffle_shop tables...
      ✓ Created jaffle_shop schema
    → Loading jaffle_shop seed data...
      ✓ Loaded jaffle_shop seed data
    → Creating jaffle_crm tables...
      ✓ Created jaffle_crm schema
    → Loading jaffle_crm seed data...
      ✓ Loaded jaffle_crm seed data

    ✓ Baseline load complete!

    ═══ Demo Source Status ═══
    jaffle_shop:
      customers: 5 | products: 5 | orders: 5
      order_items: 5

    jaffle_crm:
      campaigns: 3 | email_activity: 5
      web_sessions: 5
    ══════════════════════════
#}

{% macro origin_reset() %}
  {% set cfg = origin_simulator_ops._get_config() %}

  {{ origin_simulator_ops._log("") }}
  {{ origin_simulator_ops._log("Resetting demo databases to baseline...") }}

  {# Truncate jaffle_shop tables #}
  {{ origin_simulator_ops._log("→ Truncating jaffle_shop tables...") }}
  {% set truncate_shop_sql = origin_simulator_ops._get_sql('utilities/truncate_shop') %}
  {% do origin_simulator_ops._run_sql(truncate_shop_sql) %}
  {{ origin_simulator_ops._log("  ✓ Truncated jaffle_shop tables") }}

  {# Truncate jaffle_crm tables #}
  {{ origin_simulator_ops._log("→ Truncating jaffle_crm tables...") }}
  {% set truncate_crm_sql = origin_simulator_ops._get_sql('utilities/truncate_crm') %}
  {% do origin_simulator_ops._run_sql(truncate_crm_sql) %}
  {{ origin_simulator_ops._log("  ✓ Truncated jaffle_crm tables") }}

  {{ origin_simulator_ops._log("") }}

  {# Reload baseline data #}
  {{ origin_simulator_ops.origin_load_baseline() }}
{% endmacro %}
