-- 1. Row counts for each raw table

SELECT 'raw_bindingdb' AS table_name, COUNT(*) AS row_count FROM raw_bindingdb
UNION ALL
SELECT 'raw_bioassays', COUNT(*) FROM raw_bioassays
UNION ALL
SELECT 'raw_clintox', COUNT(*) FROM raw_clintox
UNION ALL
SELECT 'raw_sider', COUNT(*) FROM raw_sider
UNION ALL
SELECT 'raw_tox21', COUNT(*) FROM raw_tox21
UNION ALL
SELECT 'raw_toxcast', COUNT(*) FROM raw_toxcast;

-- 2. Distinct compound counts

SELECT 'raw_bindingdb' AS table_name, COUNT(DISTINCT compound_id) AS distinct_compounds FROM raw_bindingdb
UNION ALL
SELECT 'raw_bioassays', COUNT(DISTINCT compound_id) FROM raw_bioassays
UNION ALL
SELECT 'raw_clintox', COUNT(DISTINCT compound_id) FROM raw_clintox
UNION ALL
SELECT 'raw_sider', COUNT(DISTINCT compound_id) FROM raw_sider
UNION ALL
SELECT 'raw_tox21', COUNT(DISTINCT compound_id) FROM raw_tox21
UNION ALL
SELECT 'raw_toxcast', COUNT(DISTINCT compound_id) FROM raw_toxcast;

-- 3. Missing compound IDs

SELECT 'raw_bindingdb' AS Table name, COUNT (*) AS Missing coumpound count FROM raw_bindingdb
WHERE compound_id IS NULL OR compound_id = ''
UNION ALL
SELECT 'raw_bioassays', COUNT(*)
FROM raw_bioassays
WHERE compound_id IS NULL OR TRIM(compound_id) = ''
UNION ALL
SELECT 'raw_clintox', COUNT(*)
FROM raw_clintox
WHERE compound_id IS NULL OR TRIM(compound_id) = ''
UNION ALL
SELECT 'raw_sider', COUNT(*)
FROM raw_sider
WHERE compound_id IS NULL OR TRIM(compound_id) = ''
UNION ALL
SELECT 'raw_tox21', COUNT(*)
FROM raw_tox21
WHERE compound_id IS NULL OR TRIM(compound_id) = ''
UNION ALL
SELECT 'raw_toxcast', COUNT(*)
FROM raw_toxcast
WHERE compound_id IS NULL OR TRIM(compound_id) = '';

-- 4. Duplicate record checks

USE hdd_project;

SELECT 
    'raw_bindingdb' AS table_name,
    target_name AS measurement_name,
    compound_id,
    binding_value AS measurement_value,
    COUNT(*) AS duplicate_count
FROM raw_bindingdb
GROUP BY target_name, compound_id, binding_value
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'raw_bioassays' AS table_name,
    assay_name AS measurement_name,
    compound_id,
    assay_value AS measurement_value,
    COUNT(*) AS duplicate_count
FROM raw_bioassays
GROUP BY assay_name, compound_id, assay_value
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'raw_clintox' AS table_name,
    toxicity_label AS measurement_name,
    compound_id,
    toxicity_value AS measurement_value,
    COUNT(*) AS duplicate_count
FROM raw_clintox
GROUP BY toxicity_label, compound_id, toxicity_value
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'raw_sider' AS table_name,
    adverse_event AS measurement_name,
    compound_id,
    sider_value AS measurement_value,
    COUNT(*) AS duplicate_count
FROM raw_sider
GROUP BY adverse_event, compound_id, sider_value
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'raw_tox21' AS table_name,
    tox21_assay AS measurement_name,
    compound_id,
    tox21_value AS measurement_value,
    COUNT(*) AS duplicate_count
FROM raw_tox21
GROUP BY tox21_assay, compound_id, tox21_value
HAVING COUNT(*) > 1

UNION ALL

SELECT 
    'raw_toxcast' AS table_name,
    toxcast_assay AS measurement_name,
    compound_id,
    toxcast_value AS measurement_value,
    COUNT(*) AS duplicate_count
FROM raw_toxcast
GROUP BY toxcast_assay, compound_id, toxcast_value
HAVING COUNT(*) > 1

ORDER BY duplicate_count DESC
LIMIT 50;