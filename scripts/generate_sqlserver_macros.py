#!/usr/bin/env python3
"""
Generates SQL Server macros from Databricks macros.

This script reads the Databricks SQL macros and converts them to SQL Server T-SQL format.
The conversion rules are:
- CURRENT_TIMESTAMP - INTERVAL 'N days' → DATEADD(day, -N, GETDATE())
- CURRENT_DATE - N → DATEADD(day, -N, CAST(GETDATE() AS DATE))
- Table references: catalog.schema.table → dbo.table
- Adds USE database; statements
"""

import re
import sys
from pathlib import Path


def convert_databricks_to_sqlserver(content: str, database: str = 'jaffle_shop') -> str:
    """Convert Databricks SQL to SQL Server T-SQL."""

    # Replace CURRENT_TIMESTAMP - INTERVAL 'N days' with DATEADD(day, -N, GETDATE())
    content = re.sub(
        r"CURRENT_TIMESTAMP - INTERVAL '(\d+) days?'",
        r"DATEADD(day, -\1, GETDATE())",
        content
    )

    # Replace CURRENT_DATE - N with DATEADD(day, -N, CAST(GETDATE() AS DATE))
    content = re.sub(
        r"CURRENT_DATE - (\d+)",
        r"DATEADD(day, -\1, CAST(GETDATE() AS DATE))",
        content
    )

    # Replace catalog.schema.table references
    content = re.sub(
        r"origin_simulator_jaffle_corp\.erp\.(\w+)",
        r"dbo.\1",
        content
    )
    content = re.sub(
        r"origin_simulator_jaffle_corp\.crm\.(\w+)",
        r"dbo.\1",
        content
    )

    # Add USE database; at the beginning of INSERT statements
    content = re.sub(
        r"(INSERT INTO dbo\.)",
        f"USE {database};\n\n\\1",
        content,
        count=1  # Only add USE once at the beginning
    )

    return content


def extract_macro_content(file_content: str, macro_name: str) -> str:
    """Extract the content of a specific macro from the file."""
    # Handle both {%- and {% variations
    pattern = rf"\{{%-? macro {macro_name}\(\) -?%\}}(.*?)\{{%-? endmacro %\}}"
    match = re.search(pattern, file_content, re.DOTALL)
    if match:
        return match.group(1).strip()
    return ""


def create_sqlserver_macro(macro_name: str, content: str) -> str:
    """Create a SQL Server macro with the given name and content."""
    return f"""{{%- macro {macro_name}() -%}}
{content}
{{%- endmacro %}}"""


def main():
    # Read the Databricks file
    databricks_file = Path(__file__).parent.parent / "macros" / "_internal" / "_sql_databricks.sql"
    sqlserver_file = Path(__file__).parent.parent / "macros" / "_internal" / "_sql_sqlserver.sql"

    with open(databricks_file, 'r') as f:
        databricks_content = f.read()

    # Macros to convert
    macros_to_convert = [
        # Shop baseline data
        ('_get_databricks_baseline_shop_orders', '_get_sqlserver_baseline_shop_orders', 'jaffle_shop'),
        ('_get_databricks_baseline_shop_order_items', '_get_sqlserver_baseline_shop_order_items', 'jaffle_shop'),
        # Day 01 deltas
        ('_get_databricks_deltas_day_01_shop_customers', '_get_sqlserver_deltas_day_01_shop_customers', 'jaffle_shop'),
        ('_get_databricks_deltas_day_01_shop_orders', '_get_sqlserver_deltas_day_01_shop_orders', 'jaffle_shop'),
        ('_get_databricks_deltas_day_01_shop_orders_updates', '_get_sqlserver_deltas_day_01_shop_orders_updates', 'jaffle_shop'),
        ('_get_databricks_deltas_day_01_shop_order_items', '_get_sqlserver_deltas_day_01_shop_order_items', 'jaffle_shop'),
        ('_get_databricks_deltas_day_01_shop_payments', '_get_sqlserver_deltas_day_01_shop_payments', 'jaffle_shop'),
        ('_get_databricks_deltas_day_01_crm_email_activity', '_get_sqlserver_deltas_day_01_crm_email_activity', 'jaffle_crm'),
        ('_get_databricks_deltas_day_01_crm_web_sessions', '_get_sqlserver_deltas_day_01_crm_web_sessions', 'jaffle_crm'),
        # Day 02 deltas
        ('_get_databricks_deltas_day_02_shop_customers', '_get_sqlserver_deltas_day_02_shop_customers', 'jaffle_shop'),
        ('_get_databricks_deltas_day_02_shop_orders', '_get_sqlserver_deltas_day_02_shop_orders', 'jaffle_shop'),
        ('_get_databricks_deltas_day_02_shop_orders_updates', '_get_sqlserver_deltas_day_02_shop_orders_updates', 'jaffle_shop'),
        ('_get_databricks_deltas_day_02_shop_order_items', '_get_sqlserver_deltas_day_02_shop_order_items', 'jaffle_shop'),
        ('_get_databricks_deltas_day_02_shop_payments', '_get_sqlserver_deltas_day_02_shop_payments', 'jaffle_shop'),
        ('_get_databricks_deltas_day_02_shop_products_updates', '_get_sqlserver_deltas_day_02_shop_products_updates', 'jaffle_shop'),
        ('_get_databricks_deltas_day_02_crm_email_activity', '_get_sqlserver_deltas_day_02_crm_email_activity', 'jaffle_crm'),
        ('_get_databricks_deltas_day_02_crm_web_sessions', '_get_sqlserver_deltas_day_02_crm_web_sessions', 'jaffle_crm'),
        # Day 03 deltas
        ('_get_databricks_deltas_day_03_shop_customers', '_get_sqlserver_deltas_day_03_shop_customers', 'jaffle_shop'),
        ('_get_databricks_deltas_day_03_shop_orders', '_get_sqlserver_deltas_day_03_shop_orders', 'jaffle_shop'),
        ('_get_databricks_deltas_day_03_shop_orders_updates', '_get_sqlserver_deltas_day_03_shop_orders_updates', 'jaffle_shop'),
        ('_get_databricks_deltas_day_03_shop_order_items', '_get_sqlserver_deltas_day_03_shop_order_items', 'jaffle_shop'),
        ('_get_databricks_deltas_day_03_shop_payments', '_get_sqlserver_deltas_day_03_shop_payments', 'jaffle_shop'),
        ('_get_databricks_deltas_day_03_crm_email_activity', '_get_sqlserver_deltas_day_03_crm_email_activity', 'jaffle_crm'),
        ('_get_databricks_deltas_day_03_crm_web_sessions', '_get_sqlserver_deltas_day_03_crm_web_sessions', 'jaffle_crm'),
    ]

    output_macros = []

    for databricks_name, sqlserver_name, database in macros_to_convert:
        content = extract_macro_content(databricks_content, databricks_name)
        if content:
            converted = convert_databricks_to_sqlserver(content, database)
            output_macros.append(create_sqlserver_macro(sqlserver_name, converted))
            print(f"Converted {databricks_name} -> {sqlserver_name}")
        else:
            print(f"Warning: Could not find macro {databricks_name}")

    # Write to output file (append mode)
    output_content = "\n\n".join(output_macros)

    # Read existing content
    with open(sqlserver_file, 'r') as f:
        existing_content = f.read()

    # Append new macros
    with open(sqlserver_file, 'a') as f:
        f.write("\n\n{# ============================================================================\n")
        f.write("   GENERATED BASELINE AND DELTA MACROS\n")
        f.write("   Auto-generated from Databricks macros\n")
        f.write("   ============================================================================ #}\n\n")
        f.write(output_content)
        f.write("\n")

    print(f"\nAppended {len(output_macros)} macros to {sqlserver_file}")


if __name__ == '__main__':
    main()
