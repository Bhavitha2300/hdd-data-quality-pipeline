USE hdd_project;

-- Step 1: Validate that binding_value contains only numeric values

SELECT 
    binding_value, 
    COUNT(*) AS count_of_rows
FROM raw_bindingdb
WHERE binding_value NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
GROUP BY binding_value
ORDER BY count_of_rows DESC;


-- Step 2: Create clean BindingDB numeric table

DROP TABLE IF EXISTS clean_bindingdb_numeric;

CREATE TABLE clean_bindingdb_numeric AS
SELECT
    'BindingDB' AS source_dataset,
    target_name,
    compound_id,
    binding_value AS binding_value_raw,
    CAST(binding_value AS DECIMAL(15,2)) AS binding_value_numeric
FROM raw_bindingdb;


-- Step 3: Validate raw-to-clean row count

SELECT 
    (SELECT COUNT(*) FROM raw_bindingdb) AS raw_count,
    (SELECT COUNT(*) FROM clean_bindingdb_numeric) AS clean_count,
    (SELECT COUNT(*) FROM raw_bindingdb) - 
    (SELECT COUNT(*) FROM clean_bindingdb_numeric) AS difference,
    CASE 
        WHEN (SELECT COUNT(*) FROM raw_bindingdb) = 
             (SELECT COUNT(*) FROM clean_bindingdb_numeric)
        THEN 'Passed'
        ELSE 'Failed'
    END AS validation_status;


-- Step 4: Summary statistics for numeric BindingDB values

SELECT
    COUNT(*) AS total_rows,
    MIN(binding_value_numeric) AS min_binding_value,
    MAX(binding_value_numeric) AS max_binding_value,
    AVG(binding_value_numeric) AS avg_binding_value
FROM clean_bindingdb_numeric;

-- Note: BindingDB values are numeric, but the maximum value is much larger than the most common values.
-- This suggests that outlier analysis is needed before using averages or visual summaries.