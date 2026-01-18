{#
  Internal helper to execute SQL with adapter-specific handling.

  Databricks SQL Warehouse and SQL Server don't support multiple statements
  in a single query, so this macro splits SQL on semicolons and executes each
  statement separately for these adapters.

  Args:
    sql (str): SQL to execute (may contain multiple statements)

  Returns:
    None (executes SQL)
#}

{% macro _run_sql(sql) %}
  {% if target.type == 'databricks' %}
    {# Replace hardcoded catalog name with actual target catalog #}
    {% set sql = sql.replace('origin_simulator_jaffle_corp', target.catalog) %}

    {# Split on semicolon and execute each statement separately #}
    {% set statements = sql.split(';') %}
    {% for stmt in statements %}
      {# Skip empty statements #}
      {% set stmt = stmt.strip() %}
      {% if stmt %}
        {# Remove SQL comments (lines starting with --) and blank lines #}
        {% set lines = [] %}
        {% for line in stmt.split('\n') %}
          {% set line_stripped = line.strip() %}
          {% if line_stripped and not line_stripped.startswith('--') %}
            {% do lines.append(line_stripped) %}
          {% endif %}
        {% endfor %}
        {% set trimmed = ' '.join(lines).strip() %}
        {% if trimmed %}
          {% do run_query(trimmed) %}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% elif target.type == 'sqlserver' %}
    {# SQL Server needs statements executed separately #}
    {# USE statements switch the database context for subsequent queries #}

    {# Split on semicolon and execute each statement separately #}
    {% set statements = sql.split(';') %}
    {% for stmt in statements %}
      {% set stmt = stmt.strip() %}
      {% if stmt %}
        {# Remove SQL comments (lines starting with --) and blank lines #}
        {% set lines = [] %}
        {% for line in stmt.split('\n') %}
          {% set line_stripped = line.strip() %}
          {% if line_stripped and not line_stripped.startswith('--') %}
            {% do lines.append(line_stripped) %}
          {% endif %}
        {% endfor %}
        {% set trimmed = ' '.join(lines).strip() %}
        {% if trimmed %}
          {% do run_query(trimmed) %}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% else %}
    {# For DuckDB and other adapters, execute as-is #}
    {% do run_query(sql) %}
  {% endif %}
{% endmacro %}
