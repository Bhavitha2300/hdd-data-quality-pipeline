Use hdd_project;

With compound_coverage as (Select compound_id, Group_Concat(distinct source_dataset order by source_dataset Separator ', ') as dataset_list, count(Distinct source_dataset) as number_of_datasets
From clean_compound_measurements
Group by compound_id)
Select dataset_list, number_of_datasets, count(distinct compound_id) as compound_count
from compound_coverage
group by dataset_list, number_of_datasets
order by compound_count DESC


-- Most combinations include Bioassays, and the largest overlap is: BindingDB + Bioassays = 729 compounds

-- Tox21 and ToxCast appear in smaller, more limited combinations. 

-- Dataset combination analysis showed that Bioassays was the most central dataset in the HDD project. 
-- The most common overlap was between BindingDB and Bioassays, with 729 shared compounds. 
-- This suggests that BindingDB-Bioassays overlap is the strongest candidate for cross-source analysis, while Tox21 and ToxCast have narrower compound overlap and should be interpreted more cautiously.