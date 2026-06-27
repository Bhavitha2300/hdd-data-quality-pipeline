USE hdd_project;

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
        'BindingDB' AS source_dataset,
        (SELECT COUNT(*) FROM raw_bindingdb) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_compound_measurements WHERE source_dataset = 'BindingDB') AS clean_row_count

    UNION ALL

    SELECT
        'Bioassays' AS source_dataset,
        (SELECT COUNT(*) FROM raw_bioassays) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_compound_measurements WHERE source_dataset = 'Bioassays') AS clean_row_count

    UNION ALL

    SELECT
        'ClinTox' AS source_dataset,
        (SELECT COUNT(*) FROM raw_clintox) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_compound_measurements WHERE source_dataset = 'ClinTox') AS clean_row_count

    UNION ALL

    SELECT
        'SIDER' AS source_dataset,
        (SELECT COUNT(*) FROM raw_sider) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_compound_measurements WHERE source_dataset = 'SIDER') AS clean_row_count

    UNION ALL

    SELECT
        'Tox21' AS source_dataset,
        (SELECT COUNT(*) FROM raw_tox21) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_compound_measurements WHERE source_dataset = 'Tox21') AS clean_row_count

    UNION ALL

    SELECT
        'ToxCast' AS source_dataset,
        (SELECT COUNT(*) FROM raw_toxcast) AS raw_row_count,
        (SELECT COUNT(*) FROM clean_compound_measurements WHERE source_dataset = 'ToxCast') AS clean_row_count
) AS validation_counts
ORDER BY source_dataset;