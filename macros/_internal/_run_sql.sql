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
    {# SQL Server can handle multiple statements in a single batch #}
    {# Azure SQL Database doesn't support USE statements - they need to be removed #}
    {# SQL Server has a limit of 1000 rows per INSERT VALUES statement #}
    {# The profile determines which database we connect to #}

    {# Remove USE statements (Azure SQL Database doesn't support them) #}
    {% set lines = [] %}
    {% for line in sql.split('\n') %}
      {% set line_stripped = line.strip() %}
      {# Skip USE statements and SQL comments #}
      {% if line_stripped and not line_stripped.upper().startswith('USE ') and not line_stripped.startswith('--') %}
        {% do lines.append(line) %}
      {% endif %}
    {% endfor %}
    {% set cleaned_sql = '\n'.join(lines).strip() %}

    {# Check if this is a large INSERT VALUES statement that needs splitting #}
    {% if cleaned_sql.upper().startswith('INSERT INTO') and ' VALUES' in cleaned_sql.upper() %}
      {# Split INSERT header from values #}
      {% set insert_parts = cleaned_sql.split(' VALUES') %}
      {% if insert_parts | length == 2 %}
        {% set insert_header = insert_parts[0] + ' VALUES' %}
        {% set values_part = insert_parts[1].strip() %}

        {# Count value rows by counting lines starting with '(' #}
        {% set value_rows = [] %}
        {% for line in values_part.split('\n') %}
          {% if line.strip().startswith('(') %}
            {% do value_rows.append(line.rstrip(',')) %}
          {% endif %}
        {% endfor %}

        {# If more than 1000 rows, split into batches #}
        {% if value_rows | length > 1000 %}
          {% set batch_size = 1000 %}
          {% for i in range(0, value_rows | length, batch_size) %}
            {% set batch = value_rows[i:i+batch_size] %}
            {% set batch_sql = insert_header + '\n' + ',\n'.join(batch) %}
            {% do run_query(batch_sql) %}
          {% endfor %}
        {% else %}
          {% do run_query(cleaned_sql) %}
        {% endif %}
      {% else %}
        {% do run_query(cleaned_sql) %}
      {% endif %}
    {% elif cleaned_sql %}
      {% do run_query(cleaned_sql) %}
    {% endif %}
  {% else %}
    {# For DuckDB and other adapters, execute as-is #}
    {% do run_query(sql) %}
  {% endif %}
{% endmacro %}
