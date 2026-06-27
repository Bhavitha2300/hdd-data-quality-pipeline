USE hdd_project;

-- Step 1: Validate that binary source values contain only 0 and 1

SELECT 
    'ClinTox' AS source_dataset,
    toxicity_value AS raw_value,
    COUNT(*) AS count_of_rows
FROM raw_clintox
WHERE toxicity_value NOT IN ('0', '1')
GROUP BY toxicity_value

UNION ALL

SELECT 
    'SIDER' AS source_dataset,
    sider_value AS raw_value,
    COUNT(*) AS count_of_rows
FROM raw_sider
WHERE sider_value NOT IN ('0', '1')
GROUP BY sider_value

UNION ALL

SELECT 
    'Tox21' AS source_dataset,
    tox21_value AS raw_value,
    COUNT(*) AS count_of_rows
FROM raw_tox21
WHERE tox21_value NOT IN ('0', '1')
GROUP BY tox21_value

UNION ALL

SELECT 
    'ToxCast' AS source_dataset,
    toxcast_value AS raw_value,
    COUNT(*) AS count_of_rows
FROM raw_toxcast
WHERE toxcast_value NOT IN ('0', '1')
GROUP BY toxcast_value;


-- Step 2: Create clean binary outcomes table

DROP TABLE IF EXISTS clean_binary_outcomes;

CREATE TABLE clean_binary_outcomes AS

SELECT
    'ClinTox' AS source_dataset,
    toxicity_label AS outcome_name,
    compound_id,
    toxicity_value AS outcome_value_raw,
    CASE
        WHEN toxicity_value = '1' THEN 1
        WHEN toxicity_value = '0' THEN 0
        ELSE NULL
    END AS outcome_flag
FROM raw_clintox

UNION ALL

SELECT
    'SIDER' AS source_dataset,
    adverse_event AS outcome_name,
    compound_id,
    sider_value AS outcome_value_raw,
    CASE
        WHEN sider_value = '1' THEN 1
        WHEN sider_value = '0' THEN 0
        ELSE NULL
    END AS outcome_flag
FROM raw_sider

UNION ALL

SELECT
    'Tox21' AS source_dataset,
    tox21_assay AS outcome_name,
    compound_id,
    tox21_value AS outcome_value_raw,
    CASE
        WHEN tox21_value = '1' THEN 1
        WHEN tox21_value = '0' THEN 0
        ELSE NULL
    END AS outcome_flag
FROM raw_tox21

UNION ALL

SELECT
    'ToxCast' AS source_dataset,
    toxcast_assay AS outcome_name,
    compound_id,
    toxcast_value AS outcome_value_raw,
    CASE
        WHEN toxcast_value = '1' THEN 1
        WHEN toxcast_value = '0' THEN 0
        ELSE NULL
    END AS outcome_flag
FROM raw_toxcast;


-- Step 3: Validate raw-to-clean row count

SELECT
    raw_total_count,
    clean_total_count,
    raw_total_count - clean_total_count AS difference,
    CASE
        WHEN raw_total_count - clean_total_count = 0 THEN 'Passed'
        ELSE 'Failed'
    END AS validation_status
FROM (
    SELECT
        (
            (SELECT COUNT(*) FROM raw_clintox) +
            (SELECT COUNT(*) FROM raw_sider) +
            (SELECT COUNT(*) FROM raw_tox21) +
            (SELECT COUNT(*) FROM raw_toxcast)
        ) AS raw_total_count,
        (SELECT COUNT(*) FROM clean_binary_outcomes) AS clean_total_count
) AS validation_counts;


-- Step 4: Validate raw-to-clean row count by source dataset

SELECT
    source_dataset,
    raw_row_count,
    clean_row_count,
    raw_row_count - clean_row_count AS difference,
    CASE
        WHEN raw_row_count - clean_row_count = 0 THEN 'Passed'
        ELSE 'Failed'
    END AS validation_status
FROM (
    SELECT
        'ClinTox' AS source_dataset,
        (SELECT COUNT(*) FROM raw_clintox) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_binary_outcomes WHERE source_dataset = 'ClinTox') AS clean_row_count

    UNION ALL

    SELECT
        'SIDER' AS source_dataset,
        (SELECT COUNT(*) FROM raw_sider) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_binary_outcomes WHERE source_dataset = 'SIDER') AS clean_row_count

    UNION ALL

    SELECT
        'Tox21' AS source_dataset,
        (SELECT COUNT(*) FROM raw_tox21) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_binary_outcomes WHERE source_dataset = 'Tox21') AS clean_row_count

    UNION ALL

    SELECT
        'ToxCast' AS source_dataset,
        (SELECT COUNT(*) FROM raw_toxcast) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_binary_outcomes WHERE source_dataset = 'ToxCast') AS clean_row_count
) AS validation_by_source;


-- Step 5: Summary of binary outcome values

SELECT
    source_dataset,
    outcome_flag,
    COUNT(*) AS row_count
FROM clean_binary_outcomes
GROUP BY source_dataset, outcome_flag
ORDER BY source_dataset, outcome_flag DESC;


-- Binary values were standardized into a numeric outcome_flag.
-- outcome_flag = 1 means positive/present/active/associated depending on the source dataset.
-- outcome_flag = 0 means negative/absent/inactive/not associated depending on the source dataset.
-- ClinTox, SIDER, Tox21, and ToxCast were combined because they share the same binary 0/1 value structure.
-- Raw-to-clean row count validation should pass overall and by source dataset.

-- Result: 0 rows
-- This confirms that all binary source values are limited to 0 and 1 before standardization.