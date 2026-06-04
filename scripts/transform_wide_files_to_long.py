from pathlib import Path
import pandas as pd

RAW_DATA_DIR = Path("data/raw")
PROCESSED_DATA_DIR = Path("data/processed")

files_to_transform = {
    "BindingDB.csv": {
        "output": "bindingdb_long.csv",
        "feature_col": "target_name",
        "value_col": "binding_value",
    },
    "Bioassays.csv": {
        "output": "bioassays_long.csv",
        "feature_col": "assay_name",
        "value_col": "assay_value",
    },
    "ClinTox.csv": {
        "output": "clintox_long.csv",
        "feature_col": "toxicity_label",
        "value_col": "toxicity_value",
    },
    "SIDER.csv": {
        "output": "sider_long.csv",
        "feature_col": "adverse_event",
        "value_col": "sider_value",
    },
    "Tox21.csv": {
        "output": "tox21_long.csv",
        "feature_col": "tox21_assay",
        "value_col": "tox21_value",
    },
    "ToxCast.csv": {
        "output": "toxcast_long.csv",
        "feature_col": "toxcast_assay",
        "value_col": "toxcast_value",
    },
}

PROCESSED_DATA_DIR.mkdir(parents=True, exist_ok=True)

for input_file, config in files_to_transform.items():
    input_path = RAW_DATA_DIR / input_file
    output_path = PROCESSED_DATA_DIR / config["output"]

    print("=" * 80)
    print(f"Reading {input_file}...")

    df = pd.read_csv(input_path)
    print(f"Original shape: {df.shape[0]} rows, {df.shape[1]} columns")

    first_col = df.columns[0]
    df = df.rename(columns={first_col: config["feature_col"]})

    print("Transforming from wide format to long format...")

    long_df = df.melt(
        id_vars=[config["feature_col"]],
        var_name="compound_id",
        value_name=config["value_col"],
    )

    print(f"Long shape before removing missing values: {long_df.shape[0]} rows")

    long_df = long_df.dropna(subset=[config["value_col"]])

    print(f"Long shape after removing missing values: {long_df.shape[0]} rows")

    long_df["compound_id"] = long_df["compound_id"].astype(str)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    long_df.to_csv(output_path, index=False)

    print(f"Saved: {output_path}")
    print(long_df.head())