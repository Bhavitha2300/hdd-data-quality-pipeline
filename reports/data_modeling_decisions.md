# Data Modeling Decisions

## Problem Found

During value validity checks, we found that the measurement value columns are not all the same data type. Some datasets contain numeric-like values, while others contain categorical or binary values.

For example:

- BindingDB contains numeric-like binding values such as 1000, 1200, and 1300.
- Bioassays contains categorical values such as Active and Inactive.
- ClinTox, SIDER, Tox21, and ToxCast contain binary values such as 0 and 1.

This means the values cannot all be interpreted the same way. A value of `1000`, `Active`, and `1` represent different kinds of information.

## Design Decision

To address this issue, we decided to create both:

1. One combined clean measurement table.
2. Separate analysis-specific clean tables.

The combined table will standardize the raw datasets into a common structure and will be useful for dashboarding, data coverage summaries, and overall data exploration.

The separate clean tables will be safer for analysis because each table can preserve the correct meaning of the measurement values.

## Reasoning

A single combined table is useful for high-level Spotfire dashboards, such as row counts by dataset, compound coverage, and data quality summaries. However, it is not ideal for detailed analysis because the measurement values have different meanings across datasets.

Creating separate tables helps prevent incorrect analysis. Numeric binding values, categorical assay activity values, and binary toxicity/adverse-event values should be analyzed differently.