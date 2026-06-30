Use hdd_project;

-- 1. To check which compounds appear in the most datasets
Select compound_id, COUNT(Distinct source_dataset) as number_of_datasets, Group_Concat(Distinct source_dataset order by source_dataset separator ', ') as dataset_list, Count(compound_id) as total_records
from clean_compound_measurements
Group by compound_id
Order by number_of_datasets DESC, total_records DESC; 

-- 2. To count how many compounds appear in each data set

With compound_coverage as (Select compound_id, COUNT(Distinct source_dataset) as number_of_datasets, Group_Concat(Distinct source_dataset order by source_dataset separator ', ') as dataset_list, Count(compound_id) as total_records
from clean_compound_measurements
Group by compound_id
Order by number_of_datasets DESC, total_records DESC)
Select number_of_datasets, count(*) as Compound_count
from compound_coverage
group by number_of_datasets;

-- Compound overlap analysis showed that most compounds appeared in only one or two source datasets. 
-- Only four compounds appeared across five datasets, and no compounds appeared across all six datasets. 
