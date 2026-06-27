USE hdd_project;

SELECT
    source_dataset,
    COUNT(*) AS total_records,
    COUNT(DISTINCT compound_id) AS distinct_compounds,
    ROUND(COUNT(*) / COUNT(DISTINCT compound_id), 2) AS records_per_compound
FROM clean_compound_measurements
GROUP BY source_dataset
ORDER BY distinct_compounds DESC;

-- Compound coverage analysis showed that Bioassays had the broadest compound coverage with 2,484 distinct compounds, 
-- while ToxCast had only 25 distinct compounds but the highest measurement density, with 321.04 records per compound.