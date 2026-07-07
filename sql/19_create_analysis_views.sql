USE hdd_project;

-- View 1: Compound coverage by source dataset
-- Purpose:
-- Shows total records, distinct compounds, and records per compound
-- for each source dataset.

DROP VIEW IF EXISTS vw_compound_coverage;

CREATE VIEW vw_compound_coverage AS
SELECT
    source_dataset,
    COUNT(*) AS total_records,
    COUNT(DISTINCT compound_id) AS distinct_compounds,
    ROUND(COUNT(*) / COUNT(DISTINCT compound_id), 2) AS records_per_compound
FROM clean_compound_measurements
GROUP BY source_dataset;


-- View 2: Compound overlap depth
-- Purpose:
-- Shows how many compounds appear in 1, 2, 3, 4, 5, or 6 datasets.

DROP VIEW IF EXISTS vw_compound_overlap_depth;

CREATE VIEW vw_compound_overlap_depth AS
SELECT
    number_of_datasets,
    COUNT(*) AS compound_count
FROM (
    SELECT
        compound_id,
        COUNT(DISTINCT source_dataset) AS number_of_datasets
    FROM clean_compound_measurements
    GROUP BY compound_id
) AS compound_dataset_counts
GROUP BY number_of_datasets;


-- View 3: Dataset combination overlap
-- Purpose:
-- Shows which exact dataset combinations are most common.

DROP VIEW IF EXISTS vw_dataset_combination_overlap;

CREATE VIEW vw_dataset_combination_overlap AS
SELECT
    dataset_list,
    number_of_datasets,
    COUNT(*) AS compound_count
FROM (
    SELECT
        compound_id,
        GROUP_CONCAT(
            DISTINCT source_dataset
            ORDER BY source_dataset
            SEPARATOR ', '
        ) AS dataset_list,
        COUNT(DISTINCT source_dataset) AS number_of_datasets
    FROM clean_compound_measurements
    GROUP BY compound_id
) AS compound_dataset_combinations
GROUP BY dataset_list, number_of_datasets;


-- View 4: BindingDB-Bioassays compound-level summary
-- Purpose:
-- Summarizes BindingDB and Bioassays data at the compound level
-- to avoid many-to-many join distortion.

DROP VIEW IF EXISTS vw_bindingdb_bioassays_compound_summary;

CREATE VIEW vw_bindingdb_bioassays_compound_summary AS
SELECT
    bin.compound_id,
    bin.binding_record_count,
    bin.target_count,
    bin.avg_binding_value,
    bin.min_binding_value,
    bin.max_binding_value,
    bio.bioassay_record_count,
    bio.assay_count,
    bio.active_record_count,
    bio.inactive_record_count,
    bio.activity_rate,
    CASE
        WHEN bio.activity_rate = 1 THEN 'Fully active'
        WHEN bio.activity_rate > 0 AND bio.activity_rate < 1 THEN 'Mixed activity'
        WHEN bio.activity_rate = 0 THEN 'No active records'
        ELSE 'Unknown'
    END AS activity_category
FROM (
    SELECT
        compound_id,
        COUNT(*) AS binding_record_count,
        COUNT(DISTINCT target_name) AS target_count,
        AVG(binding_value_numeric) AS avg_binding_value,
        MIN(binding_value_numeric) AS min_binding_value,
        MAX(binding_value_numeric) AS max_binding_value
    FROM clean_bindingdb_numeric
    GROUP BY compound_id
) AS bin
INNER JOIN (
    SELECT
        compound_id,
        COUNT(*) AS bioassay_record_count,
        COUNT(DISTINCT assay_name) AS assay_count,
        SUM(CASE WHEN activity_flag = 1 THEN 1 ELSE 0 END) AS active_record_count,
        SUM(CASE WHEN activity_flag = 0 THEN 1 ELSE 0 END) AS inactive_record_count,
        SUM(CASE WHEN activity_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS activity_rate
    FROM clean_bioassays_activity
    GROUP BY compound_id
) AS bio
    ON bin.compound_id = bio.compound_id;


-- View 5: Binding value bucket analysis
-- Purpose:
-- Groups BindingDB-Bioassays overlapping compounds into binding
-- value buckets and activity categories.

DROP VIEW IF EXISTS vw_binding_value_bucket_analysis;

CREATE VIEW vw_binding_value_bucket_analysis AS
SELECT
    activity_category,
    binding_value_bucket,
    bucket_order,
    COUNT(*) AS compound_count
FROM (
    SELECT
        compound_id,
        activity_category,
        avg_binding_value,
        CASE
            WHEN avg_binding_value <= 100 THEN '0-100'
            WHEN avg_binding_value > 100 AND avg_binding_value <= 1000 THEN '101-1,000'
            WHEN avg_binding_value > 1000 AND avg_binding_value <= 10000 THEN '1,001-10,000'
            WHEN avg_binding_value > 10000 AND avg_binding_value <= 100000 THEN '10,001-100,000'
            WHEN avg_binding_value > 100000 THEN '>100,000'
            ELSE 'Unknown'
        END AS binding_value_bucket,
        CASE
            WHEN avg_binding_value <= 100 THEN 1
            WHEN avg_binding_value > 100 AND avg_binding_value <= 1000 THEN 2
            WHEN avg_binding_value > 1000 AND avg_binding_value <= 10000 THEN 3
            WHEN avg_binding_value > 10000 AND avg_binding_value <= 100000 THEN 4
            WHEN avg_binding_value > 100000 THEN 5
            ELSE 99
        END AS bucket_order
    FROM vw_bindingdb_bioassays_compound_summary
) AS bucketed_compounds
GROUP BY activity_category, binding_value_bucket, bucket_order;



-- Rechecking
SELECT * FROM vw_compound_coverage
ORDER BY distinct_compounds DESC;

SELECT * FROM vw_compound_overlap_depth
ORDER BY number_of_datasets;

SELECT * FROM vw_dataset_combination_overlap
ORDER BY compound_count DESC;

SELECT * FROM vw_bindingdb_bioassays_compound_summary
LIMIT 20;

SELECT * FROM vw_binding_value_bucket_analysis
ORDER BY activity_category, bucket_order;

SELECT * FROM vw_bindingdb_bioassays_compound_summary 
LIMIT 20;

SELECT * FROM vw_binding_value_bucket_analysis 
ORDER BY activity_category, bucket_order;