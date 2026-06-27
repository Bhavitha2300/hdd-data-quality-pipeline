Use hdd_project;

-- Step 1: validation to check if there are any values other than "active" and "inactive"

select assay_value, count(*) as count_of_rows
from raw_bioassays
where assay_value NOT IN ('Active', 'Inactive');

-- Step 2: create clean table

Drop table if exists clean_bioassays_activity

create table clean_bioassays_activity AS
    select 'Bioassays' as source_dataset,
    assay_name,
    compound_id,
    assay_value AS assay_value_raw,
    CASE 
        WHEN assay_value is 'Active' then 1 
        when assay_value is 'Inactive' then 0
        ELSE NULL
    END AS activity_flag
FROM raw_bioassays;

-- step 3: Validation to check if the cleaned table count is matching the raw table

Select 
    (select count(*) from raw_bioassays) as raw_table_row_count,
    (select count(*) from clean_bioassays_activity) as cleaned_table_row_count,
    (select count(*) from raw_bioassays) - (select count(*) from clean_bioassays_activity) as difference, 
    case 
        when (select count(*) from raw_bioassays) - (select count(*) from clean_bioassays_activity) is 0 
            then 'passed'
            ELSE 'failed'
        END AS validation;

-- step 4: summary stats

SELECT
    activity_flag,
    COUNT(*) AS row_count
FROM clean_bioassays_activity
GROUP BY activity_flag
ORDER BY activity_flag DESC;


-- Bioassays values were standardized from Active/Inactive into a numeric activity_flag.
-- activity_flag = 1 means Active.
-- activity_flag = 0 means Inactive.
-- Raw-to-clean row count validation passed.