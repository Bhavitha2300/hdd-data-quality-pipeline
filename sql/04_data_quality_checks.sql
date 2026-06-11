USE hdd_project;

SELECT 'raw_bindingdb' AS table_name, COUNT(*) AS row_count 
FROM raw_bindingdb
where target_name is null OR TRIM(target_name) = ''
Union ALL
SELECT 'raw_bioassays', COUNT(*) 
FROM raw_bioassays
WHERE assay_name is null OR TRIM(assay_name) = ''
Union ALL
SELECT 'raw_clintox', COUNT(*) 
FROM raw_clintox
WHERE toxicity_label is null or TRIM(toxicity_label) = ''
UNION ALL
SELECT 'raw_sider', COUNT(*)
FROM raw_sider
WHERE adverse_event IS NULL OR trim(adverse_event) = ''
UNION ALL
SELECT 'raw_tox21', COUNT(*)
FROM raw_tox21
WHERE tox21_assay IS NULL OR TRIM(tox21_assay) = ''
UNION ALL
SELECT 'raw_toxcast', COUNT(*)
FROM raw_toxcast
WHERE toxcast_assay IS NULL OR TRIM(toxcast_assay) = '';




SELECT 'raw_bindingdb' AS table_name, COUNT(*) AS row_count 
FROM raw_bindingdb
where binding_value is null OR TRIM(binding_value) = ''
Union ALL
SELECT 'raw_bioassays', COUNT(*) 
FROM raw_bioassays
WHERE assay_value is null OR TRIM(assay_value) = ''
Union ALL
SELECT 'raw_clintox', COUNT(*) 
FROM raw_clintox
WHERE toxicity_value is null or TRIM(toxicity_value) = ''
UNION ALL
SELECT 'raw_sider', COUNT(*)
FROM raw_sider
WHERE sider_value IS NULL OR trim(sider_value) = ''
UNION ALL
SELECT 'raw_tox21', COUNT(*)
FROM raw_tox21
WHERE tox21_value IS NULL OR TRIM(tox21_value) = ''
UNION ALL
SELECT 'raw_toxcast', COUNT(*)
FROM raw_toxcast
WHERE toxcast_value IS NULL OR TRIM(toxcast_value) = '';
