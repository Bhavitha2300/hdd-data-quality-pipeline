# Clean Tables Summary

## Purpose

This document summarizes the clean analysis-ready tables created for the Harmonized Drug Dataset project.

After inspecting the raw HDD files, several datasets were transformed from wide matrix format into long format so they could be loaded into MySQL. The long-format files were then ingested into MySQL raw/staging tables. After ingestion, row counts, missing identifiers, duplicate records, and value distributions were validated.

The clean tables described below were created to make the data easier to analyze, validate, and visualize in Spotfire.

## Clean Tables Created

| Clean Table | Source Table(s) | Purpose |
|---|---|---|
| `clean_compound_measurements` | All six raw tables | Combined overview table for all source datasets |
| `clean_bindingdb_numeric` | `raw_bindingdb` | Numeric BindingDB analysis table |
| `clean_bioassays_activity` | `raw_bioassays` | Standardized Bioassays Active/Inactive analysis table |
| `clean_binary_outcomes` | `raw_clintox`, `raw_sider`, `raw_tox21`, `raw_toxcast` | Standardized binary outcome table |

## Why Separate Clean Tables Were Needed

The source datasets use different types of measurement values.

| Dataset | Value Type | Example Values |
|---|---|---|
| BindingDB | Numeric | `1000`, `1200`, `5000` |
| Bioassays | Categorical | `Active`, `Inactive` |
| ClinTox | Binary | `0`, `1` |
| SIDER | Binary | `0`, `1` |
| Tox21 | Binary | `0`, `1` |
| ToxCast | Binary | `0`, `1` |

Because the values have different meanings, a single combined table is useful for high-level reporting, but separate clean tables are safer for analysis.

For example, the value `1000` in BindingDB, `Active` in Bioassays, and `1` in Tox21 do not represent the same type of measurement. Separating the cleaned tables helps prevent incorrect analysis.

## Table Descriptions

### `clean_compound_measurements`

This table combines all six source datasets into one standardized structure.

Main columns:

| Column | Description |
|---|---|
| `source_dataset` | Name of the original dataset |
| `measurement_name` | Target, assay, endpoint, adverse event, or outcome name |
| `compound_id` | Compound identifier |
| `measurement_value` | Original measurement value from the source table |
| `measurement_type` | Type of value: numeric, categorical, or binary |

This table is useful for:

- dataset overview
- row count summaries
- compound coverage analysis
- Spotfire dashboard overview pages
- data lineage reporting

### `clean_bindingdb_numeric`

This table was created from `raw_bindingdb`.

Main columns:

| Column | Description |
|---|---|
| `source_dataset` | Fixed value: BindingDB |
| `target_name` | BindingDB target name |
| `compound_id` | Compound identifier |
| `binding_value_raw` | Original binding value as loaded from the source |
| `binding_value_numeric` | Binding value converted to a numeric field |

Validation performed:

- Confirmed that all `binding_value` records matched a numeric pattern before conversion.
- Created a numeric version of the binding value using SQL casting.
- Validated that row counts matched between `raw_bindingdb` and `clean_bindingdb_numeric`.

Additional finding:

- BindingDB values are numeric, but the distribution is highly skewed.
- Extreme high values were found.
- Future BindingDB analysis should use median, percentile-based summaries, filtered views, or log-scale visualizations instead of relying only on the mean.

### `clean_bioassays_activity`

This table was created from `raw_bioassays`.

Main columns:

| Column | Description |
|---|---|
| `source_dataset` | Fixed value: Bioassays |
| `assay_name` | Bioassay identifier or assay name |
| `compound_id` | Compound identifier |
| `assay_value_raw` | Original assay value |
| `activity_flag` | Standardized activity indicator |

Value standardization:

| Raw Value | Standardized Value |
|---|---:|
| `Active` | `1` |
| `Inactive` | `0` |

Validation performed:

- Confirmed that Bioassays contained only `Active` and `Inactive` values.
- Created `activity_flag` using a SQL `CASE` statement.
- Validated that row counts matched between `raw_bioassays` and `clean_bioassays_activity`.

### `clean_binary_outcomes`

This table combines binary outcome datasets from ClinTox, SIDER, Tox21, and ToxCast.

Main columns:

| Column | Description |
|---|---|
| `source_dataset` | Dataset name: ClinTox, SIDER, Tox21, or ToxCast |
| `outcome_name` | Toxicity label, adverse event, or assay name |
| `compound_id` | Compound identifier |
| `outcome_value_raw` | Original binary value |
| `outcome_flag` | Standardized binary outcome indicator |

Value standardization:

| Raw Value | Standardized Value |
|---|---:|
| `1` | `1` |
| `0` | `0` |

Interpretation:

- `1` means positive, present, active, or associated depending on the source dataset.
- `0` means negative, absent, inactive, or not associated depending on the source dataset.

Validation performed:

- Confirmed that all binary source values were limited to `0` and `1`.
- Created `outcome_flag` using SQL `CASE` statements.
- Validated row counts overall and by source dataset.

## Validation Summary

| Validation Check | Result |
|---|---|
| Raw-to-clean row counts for `clean_compound_measurements` | Passed |
| BindingDB numeric pattern validation | Passed |
| BindingDB raw-to-clean row count validation | Passed |
| Bioassays allowed value validation | Passed |
| Bioassays raw-to-clean row count validation | Passed |
| Binary source allowed value validation | Passed |
| Binary outcomes raw-to-clean row count validation | Passed |

## Analysis Notes

The clean table design supports two types of analysis:

1. **Overview analysis** using `clean_compound_measurements`
2. **Dataset-specific analysis** using the separate clean tables

This design preserves traceability from raw/staging tables to cleaned analysis-ready tables while reducing the risk of misinterpreting mixed measurement value types.