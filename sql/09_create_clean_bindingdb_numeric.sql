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

-- step 5: Outlier analysis

select *
from clean_bindingdb_numeric
order by binding_value_numeric desc
limit 20;

select count(*) as above_10000
from clean_bindingdb_numeric
where binding_value_numeric > 10000;

select count(*) as above_100000
from clean_bindingdb_numeric
where binding_value_numeric > 100000;

select count(*) as above_1000000
from clean_bindingdb_numeric
where binding_value_numeric > 1000000;

select count(*) as total_row_count
from clean_bindingdb_numeric

Select avg(binding_value_numeric) as average_overall_value
from clean_bindingdb_numeric;

select avg(binding_value_numeric) as average_overall_value
from clean_bindingdb_numeric
where binding_value_numeric <= 100000;

-- | Check                                    |     Result |
-- | ---------------------------------------- | ---------: |
-- | Total BindingDB rows                     |      8,281 |
-- | Rows above 10,000                        |        458 |
-- | Rows above 100,000                       |        157 |
-- | Rows above 1,000,000                     |         59 |
-- | Overall average                          | 132,772.97 |
-- | Average after excluding values > 100,000 |   2,855.92 |


-- BindingDB binding values are numeric and complete, but the distribution is highly skewed. 
-- Extreme high values substantially increase the overall average. 
-- I think for analysis, median, percentile-based summaries, or filtered views may be more appropriate than relying only on the mean.