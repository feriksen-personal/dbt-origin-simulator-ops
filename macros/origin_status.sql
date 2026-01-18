{#
  Reports the current state of demo source databases.

  Displays row counts for all tables in both jaffle_shop and jaffle_crm
  databases. This operation is called at the end of other operations to
  show the results of data changes.

  Usage:
    dbt run-operation origin_status --target dev

  Example output:
    ═══ Demo Source Status ═══
    jaffle_shop:
      customers: 100 | products: 20 | orders: 500
      order_items: 1200

    jaffle_crm:
      campaigns: 10 | email_activity: 800
      web_sessions: 1500
    ══════════════════════════
#}

{% macro origin_status() %}
  {% set cfg = origin_simulator_ops._get_config() %}

  {# Query row counts from all tables #}
  {% set shop_counts = _get_shop_counts(cfg.shop_db) %}
  {% set crm_counts = _get_crm_counts(cfg.crm_db) %}

  {# Format and display output #}
  {{ origin_simulator_ops._log("") }}
  {{ origin_simulator_ops._log("═══ Demo Source Status ═══") }}
  {{ origin_simulator_ops._log("jaffle_shop:") }}
  {{ origin_simulator_ops._log("  customers: " ~ shop_counts.customers ~ " | products: " ~ shop_counts.products ~ " | orders: " ~ shop_counts.orders) }}
  {{ origin_simulator_ops._log("  order_items: " ~ shop_counts.order_items) }}
  {{ origin_simulator_ops._log("") }}
  {{ origin_simulator_ops._log("jaffle_crm:") }}
  {{ origin_simulator_ops._log("  campaigns: " ~ crm_counts.campaigns ~ " | email_activity: " ~ crm_counts.email_activity) }}
  {{ origin_simulator_ops._log("  web_sessions: " ~ crm_counts.web_sessions) }}
  {{ origin_simulator_ops._log("══════════════════════════") }}
  {{ origin_simulator_ops._log("") }}
{% endmacro %}


{#
  Internal helper to get row counts from jaffle_shop tables.

  Args:
    shop_db (str): Shop database name

  Returns:
    dict: Row counts for each table
#}
{% macro _get_shop_counts(shop_db) %}
  {# Build table references based on adapter type #}
  {% if target.type == 'databricks' %}
    {# Databricks: catalog.erp.table #}
    {% set customers_ref = target.catalog ~ '.erp.customers' %}
    {% set products_ref = target.catalog ~ '.erp.products' %}
    {% set orders_ref = target.catalog ~ '.erp.orders' %}
    {% set order_items_ref = target.catalog ~ '.erp.order_items' %}
  {% else %}
    {# DuckDB: jaffle_shop.table #}
    {% set customers_ref = shop_db ~ '.customers' %}
    {% set products_ref = shop_db ~ '.products' %}
    {% set orders_ref = shop_db ~ '.orders' %}
    {% set order_items_ref = shop_db ~ '.order_items' %}
  {% endif %}

  {% set query %}
    SELECT
      (SELECT COUNT(*) FROM {{ customers_ref }}) as customers,
      (SELECT COUNT(*) FROM {{ products_ref }}) as products,
      (SELECT COUNT(*) FROM {{ orders_ref }}) as orders,
      (SELECT COUNT(*) FROM {{ order_items_ref }}) as order_items
  {% endset %}

  {% set result = run_query(query) %}
  {% if execute %}
    {% set row = result.rows[0] %}
    {% do return({
      'customers': row[0],
      'products': row[1],
      'orders': row[2],
      'order_items': row[3]
    }) %}
  {% else %}
    {% do return({
      'customers': 0,
      'products': 0,
      'orders': 0,
      'order_items': 0
    }) %}
  {% endif %}
{% endmacro %}


{#
  Internal helper to get row counts from jaffle_crm tables.

  Args:
    crm_db (str): CRM database name

  Returns:
    dict: Row counts for each table
#}
{% macro _get_crm_counts(crm_db) %}
  {# Build table references based on adapter type #}
  {% if target.type == 'databricks' %}
    {# Databricks: catalog.crm.table #}
    {% set campaigns_ref = target.catalog ~ '.crm.campaigns' %}
    {% set email_activity_ref = target.catalog ~ '.crm.email_activity' %}
    {% set web_sessions_ref = target.catalog ~ '.crm.web_sessions' %}
  {% else %}
    {# DuckDB: jaffle_crm.table #}
    {% set campaigns_ref = crm_db ~ '.campaigns' %}
    {% set email_activity_ref = crm_db ~ '.email_activity' %}
    {% set web_sessions_ref = crm_db ~ '.web_sessions' %}
  {% endif %}

  {% set query %}
    SELECT
      (SELECT COUNT(*) FROM {{ campaigns_ref }}) as campaigns,
      (SELECT COUNT(*) FROM {{ email_activity_ref }}) as email_activity,
      (SELECT COUNT(*) FROM {{ web_sessions_ref }}) as web_sessions
  {% endset %}

  {% set result = run_query(query) %}
  {% if execute %}
    {% set row = result.rows[0] %}
    {% do return({
      'campaigns': row[0],
      'email_activity': row[1],
      'web_sessions': row[2]
    }) %}
  {% else %}
    {% do return({
      'campaigns': 0,
      'email_activity': 0,
      'web_sessions': 0
    }) %}
  {% endif %}
{% endmacro %}
