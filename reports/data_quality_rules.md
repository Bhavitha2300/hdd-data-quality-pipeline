# Data Quality Rules

## Project Context

This document defines the data quality rules used to evaluate the Harmonized Drug Dataset after transformation and ingestion into MySQL.

The purpose of these rules is to determine whether the ingested raw tables are complete, unique, valid, consistent, and ready for downstream analysis and Spotfire visualization.

## Data Quality Dimensions

| Dimension | Meaning in This Project |
|---|---|
| Completeness | Required fields should not be missing or blank |
| Uniqueness | The same compound-measurement record should not appear more than once |
| Validity | Measurement values should follow expected formats or allowed values |
| Consistency | Similar concepts should use standardized column names and source labels |
| Integrity | Records should maintain a valid link to a compound identifier |

## Initial Data Quality Rules

| Rule ID | Dimension | Rule Description | Tables Checked | Status |
|---|---|---|---|---|
| DQ001 | Completeness | compound_id should not be NULL or blank | All raw tables | Passed |
| DQ002 | Uniqueness | compound-measurement-value combinations should not be duplicated | All raw tables | Passed |
| DQ003 | Completeness | measurement name should not be NULL or blank | All raw tables | Passed |
| DQ004 | Completeness | measurement value should not be NULL or blank | All raw tables | Passed |
| DQ005 | Integrity | each raw table should contain at least one record after ingestion | All raw tables | Passed |
| DQ006 | Consistency | source dataset names should be standardized in the clean combined table | clean_compound_measurements | To be checked |

## Notes From Current Profiling

- Raw table row counts matched the ingestion validation report.
- No missing compound IDs were found in any raw table.
- Duplicate checks returned 0 rows.
- `raw_bioassays` had the highest distinct compound coverage.
- `raw_tox21` and `raw_toxcast` had smaller compound coverage than other datasets.
- Value validity checks showed that measurement values differ by dataset type.
- BindingDB values appear numeric and may be suitable for numeric analysis after type conversion.
- Bioassays values are categorical, with values Active and Inactive.
- ClinTox, SIDER, Tox21, and ToxCast values are binary, using 0 and 1.
- Because measurement values have different meanings across source datasets, future cleaned tables should preserve source_dataset and may require dataset-specific value standardization.