USE hdd_project;

DROP TABLE IF EXISTS raw_bindingdb;

CREATE TABLE raw_bindingdb (
    target_name TEXT,
    compound_id VARCHAR(50),
    binding_value DOUBLE
);

SHOW TABLES;