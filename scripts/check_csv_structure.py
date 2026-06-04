from pathlib import Path
import pandas as pd
import csv

RAW_DATA_DIR = Path("data/raw")

files_to_check = [
    "BindingDB.csv",
    "Bioassays.csv",
    "ClinTox.csv",
    "colData.csv",
    "SIDER.csv",
    "Tox21.csv",
    "ToxCast.csv",
]

for file_name in files_to_check:
    file_path = RAW_DATA_DIR / file_name

    print("=" * 80)
    print(f"File: {file_name}")

    with open(file_path, "r", encoding="utf-8", errors="replace") as f:
        sample = f.read(5000)

    try:
        dialect = csv.Sniffer().sniff(sample)
        delimiter = dialect.delimiter
    except Exception:
        delimiter = ","

    print(f"Detected delimiter: {repr(delimiter)}")

    try:
        df = pd.read_csv(file_path, sep=delimiter, nrows=5)
        print(f"Column count: {len(df.columns)}")
        print("Column names:")
        for col in df.columns:
            print(f"- {col}")
        print("\nPreview:")
        print(df.head())
    except Exception as e:
        print(f"Could not read file: {e}")