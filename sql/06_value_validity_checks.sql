USE hdd_project;

SELECT 
    'raw_bindingdb_binding_value' AS table_and_measurement_name,
    binding_value AS measurement_value,
    COUNT(*) AS row_count
FROM raw_bindingdb
GROUP BY binding_value
ORDER BY row_count DESC
LIMIT 20;


SELECT 
    'raw_bioassays_assay_value' AS table_and_measurement_name,
    assay_value AS measurement_value,
    COUNT(*) AS row_count
FROM raw_bioassays
GROUP BY assay_value
ORDER BY row_count DESC
LIMIT 20;


SELECT 
    'raw_clintox_toxicity_value' AS table_and_measurement_name,
    toxicity_value AS measurement_value,
    COUNT(*) AS row_count
FROM raw_clintox
GROUP BY toxicity_value
ORDER BY row_count DESC
LIMIT 20;


SELECT 
    'raw_sider_sider_value' AS table_and_measurement_name,
    sider_value AS measurement_value,
    COUNT(*) AS row_count
FROM raw_sider
GROUP BY sider_value
ORDER BY row_count DESC
LIMIT 20;


SELECT 
    'raw_tox21_tox21_value' AS table_and_measurement_name,
    tox21_value AS measurement_value,
    COUNT(*) AS row_count
FROM raw_tox21
GROUP BY tox21_value
ORDER BY row_count DESC
LIMIT 20;


SELECT 
    'raw_toxcast_toxcast_value' AS table_and_measurement_name,
    toxcast_value AS measurement_value,
    COUNT(*) AS row_count
FROM raw_toxcast
GROUP BY toxcast_value
ORDER BY row_count DESC
LIMIT 20;