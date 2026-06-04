USE hdd_project;

DROP TABLE IF EXISTS raw_bindingdb;
CREATE TABLE raw_bindingdb (
    target_name TEXT,
    compound_id VARCHAR(50),
    binding_value DOUBLE
);

DROP TABLE IF EXISTS raw_bioassays;
CREATE TABLE raw_bioassays (
    assay_name TEXT,
    compound_id VARCHAR(50),
    assay_value DOUBLE
);

DROP TABLE IF EXISTS raw_clintox;
CREATE TABLE raw_clintox (
    toxicity_label TEXT,
    compound_id VARCHAR(50),
    toxicity_value DOUBLE
);

DROP TABLE IF EXISTS raw_sider;
CREATE TABLE raw_sider (
    adverse_event TEXT,
    compound_id VARCHAR(50),
    sider_value DOUBLE
);

DROP TABLE IF EXISTS raw_tox21;
CREATE TABLE raw_tox21 (
    tox21_assay TEXT,
    compound_id VARCHAR(50),
    tox21_value DOUBLE
);

DROP TABLE IF EXISTS raw_toxcast;
CREATE TABLE raw_toxcast (
    toxcast_assay TEXT,
    compound_id VARCHAR(50),
    toxcast_value DOUBLE
);

SHOW TABLES;