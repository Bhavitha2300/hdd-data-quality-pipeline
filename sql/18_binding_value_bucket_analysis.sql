Use hdd_project;

WITH bindingdb_compound_summary AS (
    SELECT
        compound_id,
        COUNT(*) AS binding_record_count,
        COUNT(DISTINCT target_name) AS target_count,
        AVG(binding_value_numeric) AS avg_binding_value,
        MIN(binding_value_numeric) AS min_binding_value,
        MAX(binding_value_numeric) AS max_binding_value
    FROM clean_bindingdb_numeric
    GROUP BY compound_id
),

bioassays_compound_summary AS (
    SELECT
        compound_id,
        COUNT(*) AS bioassay_record_count,
        COUNT(DISTINCT assay_name) AS assay_count,
        SUM(CASE WHEN activity_flag = 1 THEN 1 ELSE 0 END) AS active_record_count,
        SUM(CASE WHEN activity_flag = 0 THEN 1 ELSE 0 END) AS inactive_record_count,
        MAX(activity_flag) AS any_active_flag
    FROM clean_bioassays_activity
    GROUP BY compound_id
),

compound_level_overlap AS (
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
        bio.any_active_flag,
        bio.active_record_count / bio.bioassay_record_count AS activity_rate
    FROM bindingdb_compound_summary bin
    INNER JOIN bioassays_compound_summary bio
        ON bin.compound_id = bio.compound_id
),

activity_categories AS (
    SELECT
        compound_id,
        avg_binding_value,
        min_binding_value,
        max_binding_value,
        activity_rate,
        CASE
            WHEN activity_rate = 1 THEN 'Fully active'
            WHEN activity_rate > 0 AND activity_rate < 1 THEN 'Mixed activity'
            WHEN activity_rate = 0 THEN 'No active records'
            ELSE 'Unknown'
        END AS activity_category
    FROM compound_level_overlap
)

SELECT 
    activity_category, 
    CASE
        WHEN avg_binding_value <= 100 THEN '0-100'
        WHEN avg_binding_value > 100 AND avg_binding_value <= 1000 THEN '101-1,000'
        WHEN avg_binding_value > 1000 AND avg_binding_value <= 10000 THEN '1,001-10,000'
        WHEN avg_binding_value > 10000 AND avg_binding_value <= 100000 THEN '10,001-100,000'
        WHEN avg_binding_value > 100000 THEN '>100,000'
    END AS binding_value_bucket,
    COUNT(*) AS compound_count
FROM activity_categories
GROUP BY activity_category, binding_value_bucket
ORDER BY activity_category, binding_value_bucket;


-- Binding value bucket analysis showed that fully active compounds were more common in lower and mid-range BindingDB value buckets, while mixed-activity compounds had a larger count in the highest value bucket. This suggests that the earlier average comparison was influenced by extreme outliers and should not be interpreted alone.