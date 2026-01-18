{#
  Verifies baseline data was loaded correctly.

  Checks that all tables exist and contain the expected number of rows.
  Outputs a formatted test results table with pass/fail status.

  This is primarily used in CI/CD testing to validate operations.

  Usage:
    dbt run-operation origin_verify_baseline --profile ingestion_simulator

  Example output:
    ╔════════════════════════════════════════════════════════╗
    ║ Test Results                                           ║
    ╠════════════════════════════════════════════════════════╣
    ║ Database.Table          │ Expected │ Actual │ Status   ║
    ╟────────────────────────────────────────────────────────╢
    ║ jaffle_shop.customers   │     100  │   100  │ ✓ PASS   ║
    ║ jaffle_shop.products    │      20  │    20  │ ✓ PASS   ║
    ║ jaffle_shop.orders      │     500  │   500  │ ✓ PASS   ║
    ║ jaffle_shop.order_items │    1200  │  1200  │ ✓ PASS   ║
    ║ jaffle_crm.campaigns    │       5  │     5  │ ✓ PASS   ║
    ║ jaffle_crm.email_activ… │     100  │   100  │ ✓ PASS   ║
    ║ jaffle_crm.web_sessions │     150  │   150  │ ✓ PASS   ║
    ╚════════════════════════════════════════════════════════╝
    ✓ All tests passed
#}

{% macro origin_verify_baseline() %}
  {# Expected baseline counts (scaled to 100 customers) #}
  {% set expected_counts = {
    'jaffle_shop.customers': 100,
    'jaffle_shop.products': 20,
    'jaffle_shop.orders': 500,
    'jaffle_shop.order_items': 1200,
    'jaffle_crm.campaigns': 5,
    'jaffle_crm.email_activity': 100,
    'jaffle_crm.web_sessions': 150
  } %}

  {{ origin_simulator_ops._verify_test_results(expected_counts) }}
{% endmacro %}
