{#
  Internal helper macro to extract configuration from vars.

  Returns a dictionary with database names that can be overridden
  in the consuming project's dbt_project.yml.

  Returns:
    dict: {
      'shop_db': str - E-commerce database name (default: 'jaffle_shop'),
      'crm_db': str - Marketing/CRM database name (default: 'jaffle_crm')
    }

  Example usage:
    {% set cfg = demo_source_ops._get_config() %}
    {{ log("Using shop database: " ~ cfg.shop_db, info=True) }}
#}

{% macro _get_config() %}
  {% set config = var('demo_source_ops', {}) %}
  {% do return({
    'shop_db': config.get('shop_db', 'jaffle_shop'),
    'crm_db': config.get('crm_db', 'jaffle_crm')
  }) %}
{% endmacro %}
