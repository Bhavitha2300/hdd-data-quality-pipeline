Use hdd_project;

SELECT 
    source_dataset, 
    (select count(*) from clean_compound_measurements) as total_records, 
    