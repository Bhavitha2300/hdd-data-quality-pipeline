USE hdd_project;

DROP TABLE IF EXISTS clean_compound_measurements;

CREATE TABLE clean_compound_measurements AS

SELECT 
    'BindingDB' AS source_dataset,
    target_name AS measurement_name,
    compound_id,
    binding_value AS measurement_value,
    'numeric' AS measurement_type
FROM raw_bindingdb

UNION ALL

SELECT 
    'Bioassays' AS source_dataset,
    assay_name AS measurement_name,
    compound_id,
    assay_value AS measurement_value,
    'categorical' AS measurement_type
FROM raw_bioassays

UNION ALL

SELECT 
    'ClinTox' AS source_dataset,
    toxicity_label AS measurement_name,
    compound_id,
    toxicity_value AS measurement_value,
    'binary' AS measurement_type
FROM raw_clintox

UNION ALL

SELECT 
    'SIDER' AS source_dataset,
    adverse_event AS measurement_name,
    compound_id,
    sider_value AS measurement_value,
    'binary' AS measurement_type
FROM raw_sider

UNION ALL

SELECT 
    'Tox21' AS source_dataset,
    tox21_assay AS measurement_name,
    compound_id,
    tox21_value AS measurement_value,
    'binary' AS measurement_type
FROM raw_tox21

UNION ALL

SELECT 
    'ToxCast' AS source_dataset,
    toxcast_assay AS measurement_name,
    compound_id,
    toxcast_value AS measurement_value,
    'binary' AS measurement_type
FROM raw_toxcast;

--- The MySQL raw tables were loaded from long-format processed CSV files. 
--- They represent the first database layer after file transformation and are used as staging/raw input for downstream cleaned tables.