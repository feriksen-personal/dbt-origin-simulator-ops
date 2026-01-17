{#
  Reports the current state of demo source databases.

  Displays row counts for all tables in both jaffle_shop and jaffle_crm
  databases. This operation is called at the end of other operations to
  show the results of data changes.

  Usage:
    dbt run-operation demo_status --target dev

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

{% macro demo_status() %}
  {% set cfg = demo_source_ops._get_config() %}

  {# Query row counts from all tables #}
  {% set shop_counts = _get_shop_counts(cfg.shop_db) %}
  {% set crm_counts = _get_crm_counts(cfg.crm_db) %}

  {# Format and display output #}
  {{ demo_source_ops._log("") }}
  {{ demo_source_ops._log("═══ Demo Source Status ═══") }}
  {{ demo_source_ops._log("jaffle_shop:") }}
  {{ demo_source_ops._log("  customers: " ~ shop_counts.customers ~ " | products: " ~ shop_counts.products ~ " | orders: " ~ shop_counts.orders) }}
  {{ demo_source_ops._log("  order_items: " ~ shop_counts.order_items) }}
  {{ demo_source_ops._log("") }}
  {{ demo_source_ops._log("jaffle_crm:") }}
  {{ demo_source_ops._log("  campaigns: " ~ crm_counts.campaigns ~ " | email_activity: " ~ crm_counts.email_activity) }}
  {{ demo_source_ops._log("  web_sessions: " ~ crm_counts.web_sessions) }}
  {{ demo_source_ops._log("══════════════════════════") }}
  {{ demo_source_ops._log("") }}
{% endmacro %}


{#
  Internal helper to get row counts from jaffle_shop tables.

  Args:
    shop_db (str): Shop database name

  Returns:
    dict: Row counts for each table
#}
{% macro _get_shop_counts(shop_db) %}
  {% set query %}
    SELECT
      (SELECT COUNT(*) FROM {{ shop_db }}.customers) as customers,
      (SELECT COUNT(*) FROM {{ shop_db }}.products) as products,
      (SELECT COUNT(*) FROM {{ shop_db }}.orders) as orders,
      (SELECT COUNT(*) FROM {{ shop_db }}.order_items) as order_items
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
  {% set query %}
    SELECT
      (SELECT COUNT(*) FROM {{ crm_db }}.campaigns) as campaigns,
      (SELECT COUNT(*) FROM {{ crm_db }}.email_activity) as email_activity,
      (SELECT COUNT(*) FROM {{ crm_db }}.web_sessions) as web_sessions
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
