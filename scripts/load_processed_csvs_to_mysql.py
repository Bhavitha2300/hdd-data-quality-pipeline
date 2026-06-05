from pathlib import Path
import os
import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus

PROJECT_ROOT = Path(__file__).resolve().parents[1]
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
REPORTS_DIR = PROJECT_ROOT / "reports"
REPORTS_DIR.mkdir(exist_ok=True)

TABLE_LOAD_CONFIG = {
    "bindingdb_long.csv": {
        "table": "raw_bindingdb",
        "columns": ["target_name", "compound_id", "binding_value"],
    },
    "bioassays_long.csv": {
        "table": "raw_bioassays",
        "columns": ["assay_name", "compound_id", "assay_value"],
    },
    "clintox_long.csv": {
        "table": "raw_clintox",
        "columns": ["toxicity_label", "compound_id", "toxicity_value"],
    },
    "sider_long.csv": {
        "table": "raw_sider",
        "columns": ["adverse_event", "compound_id", "sider_value"],
    },
    "tox21_long.csv": {
        "table": "raw_tox21",
        "columns": ["tox21_assay", "compound_id", "tox21_value"],
    },
    "toxcast_long.csv": {
        "table": "raw_toxcast",
        "columns": ["toxcast_assay", "compound_id", "toxcast_value"],
    },
}


def load_env_file(env_path: Path) -> None:
    """Load key=value pairs from a local .env file into environment variables."""
    if not env_path.exists():
        raise FileNotFoundError("Missing .env file in project root.")

    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue

        key, value = line.split("=", 1)
        os.environ[key.strip()] = value.strip()


def get_mysql_engine():
    """Create a SQLAlchemy connection engine for MySQL."""
    host = os.environ["MYSQL_HOST"]
    port = os.environ["MYSQL_PORT"]
    user = os.environ["MYSQL_USER"]
    password = quote_plus(os.environ["MYSQL_PASSWORD"])
    database = os.environ["MYSQL_DATABASE"]

    connection_url = (
        f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}?charset=utf8mb4"
    )

    return create_engine(connection_url)


def count_mysql_rows(engine, table_name: str) -> int:
    """Return row count from a MySQL table."""
    with engine.connect() as connection:
        result = connection.execute(text(f"SELECT COUNT(*) FROM {table_name};"))
        return result.scalar()


def clear_table(engine, table_name: str) -> None:
    """Delete existing rows before reloading."""
    with engine.begin() as connection:
        connection.execute(text(f"TRUNCATE TABLE {table_name};"))


def main():
    load_env_file(PROJECT_ROOT / ".env")
    engine = get_mysql_engine()

    log_lines = []
    log_lines.append("HDD Processed CSV to MySQL Load Report")
    log_lines.append("=" * 60)

    for file_name, config in TABLE_LOAD_CONFIG.items():
        csv_path = PROCESSED_DIR / file_name
        table_name = config["table"]
        expected_columns = config["columns"]

        log_lines.append("")
        log_lines.append(f"File: {file_name}")
        log_lines.append(f"Target table: {table_name}")

        if not csv_path.exists():
            log_lines.append("Status: FAILED - file not found")
            continue

        df = pd.read_csv(csv_path)

        csv_row_count = len(df)
        csv_columns = list(df.columns)

        log_lines.append(f"CSV rows: {csv_row_count}")
        log_lines.append(f"CSV columns: {csv_columns}")

        if csv_columns != expected_columns:
            log_lines.append("Status: FAILED - column mismatch")
            log_lines.append(f"Expected columns: {expected_columns}")
            continue

        clear_table(engine, table_name)

        df.to_sql(
            name=table_name,
            con=engine,
            if_exists="append",
            index=False,
            chunksize=5000,
        )

        mysql_row_count = count_mysql_rows(engine, table_name)

        log_lines.append(f"MySQL rows: {mysql_row_count}")

        if csv_row_count == mysql_row_count:
            log_lines.append("Status: PASSED - row counts match")
        else:
            log_lines.append("Status: FAILED - row counts do not match")

    report_path = REPORTS_DIR / "mysql_load_report.txt"
    report_path.write_text("\n".join(log_lines))

    print("\n".join(log_lines))
    print(f"\nReport saved to: {report_path}")


if __name__ == "__main__":
    main()