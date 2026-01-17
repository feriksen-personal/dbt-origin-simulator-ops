#!/usr/bin/env python3
"""
SQL to DBML Converter

Parses SQL DDL files and generates DBML (Database Markup Language) format
for creating Entity-Relationship Diagrams.

Usage:
    python scripts/sql_to_dbml.py data/duckdb/baseline/shop_schema.sql > docs/generated/jaffle-shop.dbml
    python scripts/sql_to_dbml.py data/duckdb/baseline/crm_schema.sql > docs/generated/jaffle-crm.dbml
"""

import re
import sys
from pathlib import Path
from typing import List, Dict, Optional, Tuple


class Column:
    """Represents a table column with its properties."""

    def __init__(self, name: str, data_type: str, is_pk: bool = False,
                 is_nullable: bool = True, default: Optional[str] = None,
                 comment: Optional[str] = None):
        self.name = name
        self.data_type = data_type
        self.is_pk = is_pk
        self.is_nullable = is_nullable
        self.default = default
        self.comment = comment

    def to_dbml(self) -> str:
        """Convert column to DBML format."""
        # Clean up type (remove trailing commas from SQL parsing)
        clean_type = self.data_type.rstrip(',')

        # Build column definition with type
        column_def = f"  {self.name} {clean_type}"

        # Build attributes list (all go in ONE bracket set)
        attributes = []

        if self.is_pk:
            attributes.append("pk")
        elif not self.is_nullable:
            attributes.append("not null")

        if self.default:
            attributes.append(f"default: {self.default}")

        if self.comment:
            attributes.append(f"note: '{self.comment}'")

        # Combine into single bracket set if there are attributes
        if attributes:
            column_def += f" [{', '.join(attributes)}]"

        return column_def


class ForeignKey:
    """Represents a foreign key relationship."""

    def __init__(self, from_table: str, from_column: str,
                 to_table: str, to_column: str):
        self.from_table = from_table
        self.from_column = from_column
        self.to_table = to_table
        self.to_column = to_column

    def to_dbml(self) -> str:
        """Convert foreign key to DBML format."""
        return f"Ref: {self.from_table}.{self.from_column} > {self.to_table}.{self.to_column}"


class Table:
    """Represents a database table."""

    def __init__(self, schema: str, name: str, comment: Optional[str] = None):
        self.schema = schema
        self.name = name
        self.full_name = f"{schema}.{name}"
        self.comment = comment
        self.columns: List[Column] = []
        self.foreign_keys: List[ForeignKey] = []

    def add_column(self, column: Column):
        """Add a column to the table."""
        self.columns.append(column)

    def add_foreign_key(self, fk: ForeignKey):
        """Add a foreign key to the table."""
        self.foreign_keys.append(fk)

    def to_dbml(self) -> str:
        """Convert table to DBML format."""
        lines = []

        # Table definition
        table_def = f"Table {self.full_name}"
        if self.comment:
            table_def += f" [note: '{self.comment}']"
        table_def += " {"
        lines.append(table_def)

        # Columns
        for col in self.columns:
            lines.append(col.to_dbml())

        lines.append("}")
        lines.append("")

        return "\n".join(lines)


class SQLParser:
    """Parses SQL DDL files to extract schema information."""

    def __init__(self):
        self.tables: List[Table] = []
        self.foreign_keys: List[ForeignKey] = []

    def parse_file(self, filepath: Path) -> None:
        """Parse a SQL DDL file."""
        content = filepath.read_text()

        # Extract table comments (lines starting with --)
        table_comment_pattern = r'--\s*(.+)\s*\nCREATE TABLE'

        # Match CREATE TABLE statements
        create_table_pattern = r'CREATE TABLE IF NOT EXISTS\s+([a-z_]+)\.([a-z_]+)\s*\((.*?)\);'

        matches = re.finditer(create_table_pattern, content, re.DOTALL | re.IGNORECASE)

        for match in matches:
            schema = match.group(1)
            table_name = match.group(2)
            table_def = match.group(3)

            # Extract table comment
            table_comment = None
            table_start = match.start()
            preceding_text = content[:table_start].strip().split('\n')
            if preceding_text:
                last_line = preceding_text[-1].strip()
                if last_line.startswith('--'):
                    table_comment = last_line[2:].strip()

            table = Table(schema, table_name, table_comment)

            # Parse columns and constraints
            self._parse_table_definition(table, table_def)

            self.tables.append(table)

    def _parse_table_definition(self, table: Table, definition: str) -> None:
        """Parse table column and constraint definitions."""
        lines = [line.strip() for line in definition.split('\n') if line.strip()]

        for line in lines:
            # Skip FOREIGN KEY lines (we'll handle them separately)
            if line.upper().startswith('FOREIGN KEY'):
                self._parse_foreign_key(table, line)
                continue

            # Remove trailing comma
            line = line.rstrip(',')

            # Parse column definition
            self._parse_column(table, line)

    def _parse_column(self, table: Table, line: str) -> None:
        """Parse a column definition."""
        # Extract inline comment
        comment = None
        if '--' in line:
            line, comment_part = line.split('--', 1)
            comment = comment_part.strip()
            line = line.strip()

        # Skip empty lines or foreign key lines
        if not line or line.upper().startswith('FOREIGN KEY'):
            return

        # Parse column parts
        parts = line.split()
        if len(parts) < 2:
            return

        col_name = parts[0]
        col_type = parts[1]

        # Check for PRIMARY KEY
        is_pk = 'PRIMARY KEY' in line.upper()

        # Check for NOT NULL
        is_nullable = 'NOT NULL' not in line.upper() or is_pk

        # Extract default value
        default = None
        if 'DEFAULT' in line.upper():
            default_match = re.search(r'DEFAULT\s+([^,\s]+)', line, re.IGNORECASE)
            if default_match:
                default = default_match.group(1)

        column = Column(col_name, col_type, is_pk, is_nullable, default, comment)
        table.add_column(column)

    def _parse_foreign_key(self, table: Table, line: str) -> None:
        """Parse a FOREIGN KEY constraint."""
        # Pattern: FOREIGN KEY (column) REFERENCES schema.table(column)
        fk_pattern = r'FOREIGN KEY\s*\(([a-z_]+)\)\s*REFERENCES\s+([a-z_]+)\.([a-z_]+)\(([a-z_]+)\)'
        match = re.search(fk_pattern, line, re.IGNORECASE)

        if match:
            from_col = match.group(1)
            to_schema = match.group(2)
            to_table = match.group(3)
            to_col = match.group(4)

            fk = ForeignKey(
                from_table=table.full_name,
                from_column=from_col,
                to_table=f"{to_schema}.{to_table}",
                to_column=to_col
            )

            self.foreign_keys.append(fk)

    def to_dbml(self) -> str:
        """Convert parsed schema to DBML format."""
        lines = []

        # Add header comment
        lines.append("// Auto-generated DBML from SQL DDL")
        lines.append("// Generated by scripts/sql_to_dbml.py")
        lines.append("")

        # Add tables
        for table in self.tables:
            lines.append(table.to_dbml())

        # Add foreign key relationships
        if self.foreign_keys:
            lines.append("// Relationships")
            for fk in self.foreign_keys:
                lines.append(fk.to_dbml())
            lines.append("")

        return "\n".join(lines)


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("Usage: python scripts/sql_to_dbml.py <sql_file>", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  python scripts/sql_to_dbml.py data/duckdb/baseline/shop_schema.sql > docs/generated/jaffle-shop.dbml", file=sys.stderr)
        sys.exit(1)

    sql_file = Path(sys.argv[1])

    if not sql_file.exists():
        print(f"Error: File not found: {sql_file}", file=sys.stderr)
        sys.exit(1)

    # Parse SQL file
    parser = SQLParser()
    parser.parse_file(sql_file)

    # Output DBML
    print(parser.to_dbml())


if __name__ == "__main__":
    main()
