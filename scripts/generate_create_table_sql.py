from pathlib import Path
import pandas as pd
import re

RAW_DATA_DIR = Path("data/raw")
SQL_OUTPUT_PATH = Path("sql/04_create_remaining_raw_tables.sql")

files_to_tables = {
    "Bioassays.csv": "raw_bioassays",
    "ClinTox.csv": "raw_clintox",
    "colData.csv": "raw_coldata",
    "SIDER.csv": "raw_sider",
    "Tox21.csv": "raw_tox21",
    "ToxCast.csv": "raw_toxcast",
}

def clean_column_name(column_name):
    column_name = column_name.strip().lower()
    column_name = re.sub(r"[^a-z0-9]+", "_", column_name)
    column_name = column_name.strip("_")

    if column_name == "":
        column_name = "unnamed_column"

    if column_name[0].isdigit():
        column_name = "col_" + column_name

    return column_name

def infer_mysql_type(series):
    if pd.api.types.is_integer_dtype(series):
        return "BIGINT"
    elif pd.api.types.is_float_dtype(series):
        return "DOUBLE"
    else:
        return "TEXT"

sql_lines = [
    "USE hdd_project;",
    "",
]

for file_name, table_name in files_to_tables.items():
    file_path = RAW_DATA_DIR / file_name

    print(f"Reading {file_name}...")

    df = pd.read_csv(file_path, nrows=1000)

    original_columns = list(df.columns)
    cleaned_columns = [clean_column_name(col) for col in original_columns]

    # Handle duplicate cleaned column names
    seen = {}
    final_columns = []

    for col in cleaned_columns:
        if col not in seen:
            seen[col] = 1
            final_columns.append(col)
        else:
            seen[col] += 1
            final_columns.append(f"{col}_{seen[col]}")

    sql_lines.append(f"DROP TABLE IF EXISTS {table_name};")
    sql_lines.append(f"CREATE TABLE {table_name} (")

    column_definitions = []
    for col in final_columns:
        mysql_type = "TEXT"
        column_definitions.append(f"    `{col}` {mysql_type}")

    sql_lines.append(",\n".join(column_definitions))
    sql_lines.append(");")
    sql_lines.append("")

SQL_OUTPUT_PATH.write_text("\n".join(sql_lines))

print(f"SQL file created: {SQL_OUTPUT_PATH}")