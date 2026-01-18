{#
  Internal helper macro to load SQL files with adapter detection.

  Automatically routes to the correct SQL directory based on the current
  target adapter type (duckdb vs sqlserver).

  Args:
    path (str): Relative path to SQL file within the adapter directory,
                without .sql extension. Examples:
                - 'baseline/shop_schema'
                - 'deltas/day_01_shop'
                - 'utilities/truncate_crm'

  Returns:
    str: Contents of the SQL file

  Raises:
    Compilation error if file not found

  Example usage:
    {% set sql = origin_simulator_ops._get_sql('baseline/shop_schema') %}
    {% do run_query(sql) %}

  File structure:
    data/
      ├── duckdb/
      │   ├── baseline/shop_schema.sql
      │   └── deltas/day_01_shop.sql
      ├── databricks/
      │   ├── baseline/shop_schema.sql
      │   └── deltas/day_01_shop.sql
      └── azure/
          ├── baseline/shop_schema.sql
          └── deltas/day_01_shop.sql
#}

{% macro _get_sql(path) %}
  {# Route to adapter-specific SQL macros #}
  {% if target.type == 'duckdb' %}
    {% if path == 'baseline/shop_schema' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_shop_schema()) }}
    {# Baseline shop - table-specific #}
    {% elif path == 'baseline/shop_customers' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_shop_customers()) }}
    {% elif path == 'baseline/shop_products' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_shop_products()) }}
    {% elif path == 'baseline/shop_orders' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_shop_orders()) }}
    {% elif path == 'baseline/shop_order_items' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_shop_order_items()) }}
    {% elif path == 'baseline/crm_schema' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_crm_schema()) }}
    {# Baseline CRM - table-specific #}
    {% elif path == 'baseline/crm_campaigns' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_crm_campaigns()) }}
    {% elif path == 'baseline/crm_email_activity' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_crm_email_activity()) }}
    {% elif path == 'baseline/crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_duckdb_baseline_crm_web_sessions()) }}
    {% elif path == 'utilities/truncate_shop' %}
      {{ return(origin_simulator_ops._get_duckdb_utilities_truncate_shop()) }}
    {% elif path == 'utilities/truncate_crm' %}
      {{ return(origin_simulator_ops._get_duckdb_utilities_truncate_crm()) }}
    {# Delta table-specific routes #}
    {% elif path == 'deltas/day_01_crm_email_activity' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_crm_email_activity()) }}
    {% elif path == 'deltas/day_01_crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_crm_web_sessions()) }}
    {% elif path == 'deltas/day_01_shop_customers' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_shop_customers()) }}
    {% elif path == 'deltas/day_01_shop_order_items' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_shop_order_items()) }}
    {% elif path == 'deltas/day_01_shop_orders' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_shop_orders()) }}
    {% elif path == 'deltas/day_01_shop_orders_updates' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_shop_orders_updates()) }}
    {% elif path == 'deltas/day_01_shop_payments' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_01_shop_payments()) }}
    {% elif path == 'deltas/day_02_crm_email_activity' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_crm_email_activity()) }}
    {% elif path == 'deltas/day_02_crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_crm_web_sessions()) }}
    {% elif path == 'deltas/day_02_shop_customers' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_shop_customers()) }}
    {% elif path == 'deltas/day_02_shop_order_items' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_shop_order_items()) }}
    {% elif path == 'deltas/day_02_shop_orders' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_shop_orders()) }}
    {% elif path == 'deltas/day_02_shop_orders_updates' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_shop_orders_updates()) }}
    {% elif path == 'deltas/day_02_shop_payments' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_shop_payments()) }}
    {% elif path == 'deltas/day_02_shop_products_updates' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_02_shop_products_updates()) }}
    {% elif path == 'deltas/day_03_crm_email_activity' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_crm_email_activity()) }}
    {% elif path == 'deltas/day_03_crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_crm_web_sessions()) }}
    {% elif path == 'deltas/day_03_shop_customers' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_shop_customers()) }}
    {% elif path == 'deltas/day_03_shop_order_items' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_shop_order_items()) }}
    {% elif path == 'deltas/day_03_shop_orders' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_shop_orders()) }}
    {% elif path == 'deltas/day_03_shop_orders_updates' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_shop_orders_updates()) }}
    {% elif path == 'deltas/day_03_shop_payments' %}
      {{ return(origin_simulator_ops._get_duckdb_deltas_day_03_shop_payments()) }}
    {% else %}
      {{ exceptions.raise_compiler_error("Unknown DuckDB SQL path: " ~ path) }}
    {% endif %}
  {% elif target.type == 'databricks' %}
    {% if path == 'baseline/shop_schema' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_shop_schema()) }}
    {% elif path == 'baseline/shop_customers' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_shop_customers()) }}
    {% elif path == 'baseline/shop_products' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_shop_products()) }}
    {% elif path == 'baseline/shop_orders' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_shop_orders()) }}
    {% elif path == 'baseline/shop_order_items' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_shop_order_items()) }}
    {% elif path == 'baseline/crm_schema' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_crm_schema()) }}
    {% elif path == 'baseline/crm_campaigns' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_crm_campaigns()) }}
    {% elif path == 'baseline/crm_email_activity' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_crm_email_activity()) }}
    {% elif path == 'baseline/crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_databricks_baseline_crm_web_sessions()) }}
    {% elif path == 'utilities/truncate_shop' %}
      {{ return(origin_simulator_ops._get_databricks_utilities_truncate_shop()) }}
    {% elif path == 'utilities/truncate_crm' %}
      {{ return(origin_simulator_ops._get_databricks_utilities_truncate_crm()) }}
    {% elif path == 'deltas/day_01_crm_email_activity' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_crm_email_activity()) }}
    {% elif path == 'deltas/day_01_crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_crm_web_sessions()) }}
    {% elif path == 'deltas/day_01_shop_customers' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_shop_customers()) }}
    {% elif path == 'deltas/day_01_shop_order_items' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_shop_order_items()) }}
    {% elif path == 'deltas/day_01_shop_orders' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_shop_orders()) }}
    {% elif path == 'deltas/day_01_shop_orders_updates' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_shop_orders_updates()) }}
    {% elif path == 'deltas/day_01_shop_payments' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_01_shop_payments()) }}
    {% elif path == 'deltas/day_02_crm_email_activity' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_crm_email_activity()) }}
    {% elif path == 'deltas/day_02_crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_crm_web_sessions()) }}
    {% elif path == 'deltas/day_02_shop_customers' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_shop_customers()) }}
    {% elif path == 'deltas/day_02_shop_order_items' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_shop_order_items()) }}
    {% elif path == 'deltas/day_02_shop_orders' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_shop_orders()) }}
    {% elif path == 'deltas/day_02_shop_orders_updates' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_shop_orders_updates()) }}
    {% elif path == 'deltas/day_02_shop_payments' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_shop_payments()) }}
    {% elif path == 'deltas/day_02_shop_products_updates' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_02_shop_products_updates()) }}
    {% elif path == 'deltas/day_03_crm_email_activity' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_crm_email_activity()) }}
    {% elif path == 'deltas/day_03_crm_web_sessions' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_crm_web_sessions()) }}
    {% elif path == 'deltas/day_03_shop_customers' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_shop_customers()) }}
    {% elif path == 'deltas/day_03_shop_order_items' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_shop_order_items()) }}
    {% elif path == 'deltas/day_03_shop_orders' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_shop_orders()) }}
    {% elif path == 'deltas/day_03_shop_orders_updates' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_shop_orders_updates()) }}
    {% elif path == 'deltas/day_03_shop_payments' %}
      {{ return(origin_simulator_ops._get_databricks_deltas_day_03_shop_payments()) }}
    {% else %}
      {{ exceptions.raise_compiler_error("Unknown Databricks SQL path: " ~ path) }}
    {% endif %}
  {% else %}
    {# Azure SQL - to be implemented later #}
    {{ exceptions.raise_compiler_error("Azure SQL adapter not yet implemented") }}
  {% endif %}
{% endmacro %}
