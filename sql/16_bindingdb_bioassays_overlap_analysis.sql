Use hdd_project; 

-- 1. Create overlap view/query
Select bin.compound_id, bin.target_name, bin.binding_value_numeric, bio.assay_name, bio.activity_flag
from clean_bindingdb_numeric bin
Inner Join clean_bioassays_activity bio
on bin.compound_id = bio.compound_id;

-- 2. Count joined records

with joining_tables as (Select bin.compound_id, bin.target_name, bin.binding_value_numeric, bio.assay_name, bio.activity_flag
from clean_bindingdb_numeric bin
Inner Join clean_bioassays_activity bio
on bin.compound_id = bio.compound_id)

Select count(*) as total_joined_records, count(distinct compound_id) as distinct_compounds, count(distinct target_name) as distinct_targets, count(distinct assay_name) as distinct_assays
from joining_tables;

-- 3. Compare binding values by activity flag

with joining_tables as (Select bin.compound_id, bin.target_name, bin.binding_value_numeric, bio.assay_name, bio.activity_flag
from clean_bindingdb_numeric bin
Inner Join clean_bioassays_activity bio
on bin.compound_id = bio.compound_id)

Select activity_flag, count(*) as record_count, count(distinct compound_id) as distinct_compounds, avg(binding_value_numeric) as average_binding_value, min(binding_value_numeric) as minimum_binding_value, max(binding_value_numeric) as maximum_binding_value
from joining_tables
group by activity_flag;


--- The joined BindingDB-Bioassays dataset is heavily weighted toward active assay records, and binding value averages are affected by extreme outliers.


-- The BindingDB-Bioassays join creates a many-to-many result because compounds can have multiple targets and multiple assays.
-- Joined row counts are therefore much larger than distinct compound counts.
-- Average binding values should be interpreted carefully because Bioassays is imbalanced toward Active records and BindingDB contains high-value outliers.