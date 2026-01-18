{#
  Applies delta changes to demo source databases.

  Simulates business activity by applying incremental changes for a specific day.
  Use this to progress through demo scenarios showing how data evolves over time.

  Args:
    day (int): Day number (1, 2, or 3) - which delta to apply

  Usage:
    dbt run-operation origin_apply_delta --args '{day: 1}' --profile ingestion_simulator
    dbt run-operation origin_apply_delta --args '{day: 2}' --profile ingestion_simulator
    dbt run-operation origin_apply_delta --args '{day: 3}' --profile ingestion_simulator

  Example output:
    Applying Day 01 delta changes...
    → Applying jaffle_shop delta...
      ✓ Applied jaffle_shop delta
    → Applying jaffle_crm delta...
      ✓ Applied jaffle_crm delta

    ═══ Demo Source Status ═══
    jaffle_shop:
      customers: 30 | products: 10 | orders: 65
      order_items: 120

    jaffle_crm:
      campaigns: 5 | email_activity: 45
      web_sessions: 35
    ══════════════════════════
#}

{% macro origin_apply_delta(day) %}
  {% set cfg = origin_simulator_ops._get_config() %}

  {# Validate day parameter #}
  {% if day is none %}
    {{ exceptions.raise_compiler_error("Parameter 'day' is required. Usage: dbt run-operation origin_apply_delta --args '{day: 1}'") }}
  {% endif %}

  {% if day not in [1, 2, 3] %}
    {{ exceptions.raise_compiler_error("Parameter 'day' must be 1, 2, or 3. Got: " ~ day) }}
  {% endif %}

  {# Format day as zero-padded string (01, 02, 03) #}
  {% set day_str = '0' ~ day|string %}

  {{ origin_simulator_ops._log("") }}
  {{ origin_simulator_ops._log("Applying Day " ~ day_str ~ " delta changes...") }}

  {# Apply shop delta - table by table in FK order #}
  {{ origin_simulator_ops._log("→ Applying jaffle_shop delta...") }}

  {# Customers first (no dependencies) #}
  {% set customers_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_shop_customers') %}
  {% do run_query(customers_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied customers changes") }}

  {# Products updates (if exists for this day) #}
  {% if day == 2 %}
    {% set products_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_shop_products_updates') %}
    {% do run_query(products_sql) %}
    {{ origin_simulator_ops._log("  ✓ Applied products updates") }}
  {% endif %}

  {# Orders (depends on customers) #}
  {% set orders_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_shop_orders') %}
  {% do run_query(orders_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied orders changes") }}

  {# Order items (depends on orders and products) #}
  {% set order_items_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_shop_order_items') %}
  {% do run_query(order_items_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied order_items changes") }}

  {# Payments (depends on orders) #}
  {% set payments_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_shop_payments') %}
  {% do run_query(payments_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied payments changes") }}

  {# Orders updates (status changes after payment) #}
  {% set orders_updates_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_shop_orders_updates') %}
  {% do run_query(orders_updates_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied orders status updates") }}

  {# Apply CRM delta - table by table #}
  {{ origin_simulator_ops._log("→ Applying jaffle_crm delta...") }}

  {# Email activity #}
  {% set email_activity_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_crm_email_activity') %}
  {% do run_query(email_activity_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied email_activity changes") }}

  {# Web sessions #}
  {% set web_sessions_sql = origin_simulator_ops._get_sql('deltas/day_' ~ day_str ~ '_crm_web_sessions') %}
  {% do run_query(web_sessions_sql) %}
  {{ origin_simulator_ops._log("  ✓ Applied web_sessions changes") }}

  {{ origin_simulator_ops._log("") }}

  {# Show updated status #}
  {{ origin_simulator_ops.origin_status() }}
{% endmacro %}
