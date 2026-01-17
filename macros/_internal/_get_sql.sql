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
    {% set sql = demo_source_ops._get_sql('baseline/shop_schema') %}
    {% do run_query(sql) %}

  File structure:
    data/
      ├── duckdb/
      │   ├── baseline/shop_schema.sql
      │   └── deltas/day_01_shop.sql
      └── azure/
          ├── baseline/shop_schema.sql
          └── deltas/day_01_shop.sql
#}

{% macro _get_sql(path) %}
  {# Detect adapter type and select appropriate directory #}
  {% set adapter_dir = 'duckdb' if target.type == 'duckdb' else 'azure' %}
  {% set full_path = 'data/' ~ adapter_dir ~ '/' ~ path ~ '.sql' %}

  {# Load SQL file contents #}
  {% set sql = load_file_contents(full_path) %}

  {# Raise error if file not found #}
  {% if sql is none %}
    {{ exceptions.raise_compiler_error(
      "SQL file not found: " ~ full_path ~
      " (adapter: " ~ target.type ~ ")"
    ) }}
  {% endif %}

  {{ return(sql) }}
{% endmacro %}
