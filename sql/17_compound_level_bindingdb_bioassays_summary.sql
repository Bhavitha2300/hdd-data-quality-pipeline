USE hdd_project;

-- Step 1: Summarize BindingDB at the compound level

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

-- Step 2: Summarize Bioassays at the compound level

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

-- Step 3: Join the compound-level summaries

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
        bio.any_active_flag
    FROM bindingdb_compound_summary bin
    INNER JOIN bioassays_compound_summary bio
        ON bin.compound_id = bio.compound_id
)

-- Step 4: Count compound-level overlap

SELECT
    COUNT(*) AS total_compounds,
    SUM(CASE WHEN any_active_flag = 1 THEN 1 ELSE 0 END) AS compounds_with_any_active,
    SUM(CASE WHEN any_active_flag = 0 THEN 1 ELSE 0 END) AS compounds_with_no_active
FROM compound_level_overlap;


-- Step 5: Compare compound-level binding values by activity group

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
        bio.any_active_flag
    FROM bindingdb_compound_summary bin
    INNER JOIN bioassays_compound_summary bio
        ON bin.compound_id = bio.compound_id
)

SELECT
    any_active_flag,
    COUNT(*) AS compound_count,
    AVG(avg_binding_value) AS avg_of_compound_avg_binding_value,
    MIN(avg_binding_value) AS min_compound_avg_binding_value,
    MAX(avg_binding_value) AS max_compound_avg_binding_value
FROM compound_level_overlap
GROUP BY any_active_flag
ORDER BY any_active_flag DESC;

-- Step 6: Compare compound-level binding values by activity rate category

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
    COUNT(*) AS compound_count,
    AVG(avg_binding_value) AS avg_of_compound_avg_binding_value,
    MIN(avg_binding_value) AS min_compound_avg_binding_value,
    MAX(avg_binding_value) AS max_compound_avg_binding_value
FROM activity_categories
GROUP BY activity_category
ORDER BY compound_count DESC;


-- Activity category analysis showed that overlapping BindingDB-Bioassays compounds were either fully active or mixed activity.
-- No compounds in the overlap set had only inactive Bioassays records.
-- Fully active compounds had a higher average compound-level BindingDB value, but averages should be interpreted cautiously because BindingDB contains extreme high-value outliers.