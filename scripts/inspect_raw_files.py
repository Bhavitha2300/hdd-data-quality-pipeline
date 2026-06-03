from pathlib import Path
import pandas as pd

RAW_DATA_DIR = Path("data/raw")

files_to_inspect = [
    "BindingDB.csv",
    "Bioassays.csv",
    "ClinTox.csv",
    "colData.csv",
    "SIDER.csv",
    "Tox21.csv",
    "ToxCast.csv",
]

for file_name in files_to_inspect:
    file_path = RAW_DATA_DIR / file_name

    print("=" * 80)
    print(f"File: {file_name}")

    try:
        df = pd.read_csv(file_path)

        print(f"Rows: {df.shape[0]}")
        print(f"Columns: {df.shape[1]}")
        print(f"Duplicate rows: {df.duplicated().sum()}")

        print("\nColumn names:")
        for col in df.columns:
            print(f"- {col}")

        print("\nMissing values by column:")
        missing = df.isna().sum()
        missing = missing[missing > 0]

        if missing.empty:
            print("No missing values found.")
        else:
            print(missing)

        print("\nFirst 5 rows:")
        print(df.head())

    except Exception as e:
        print(f"Error reading {file_name}: {e}")