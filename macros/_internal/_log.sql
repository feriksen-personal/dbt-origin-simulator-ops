{#
  Internal helper macro for consistent logging across operations.

  Wraps dbt's log() function with consistent formatting and ensures
  messages are always displayed to the user.

  Args:
    msg (str): Message to log

  Example usage:
    {{ demo_source_ops._log("Loading baseline data...") }}
    {{ demo_source_ops._log("✓ Baseline loaded successfully") }}
#}

{% macro _log(msg) %}
  {{ log(msg, info=True) }}
{% endmacro %}
