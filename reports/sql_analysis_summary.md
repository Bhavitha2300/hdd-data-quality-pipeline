1. Compound coverage analysis
- This analysis showed that Bioassays table has broad coverage with highest total number of records and highest number of distinct coumpound with 9.09 records per compound
- Toxcast has very narrow compund coverage with only 25 distinct compounds but highest records per compound of 321.04

source_dataset, total_records, distinct_compounds, records_per_compound
'Bioassays','22569','2484','9.09'
'SIDER','8748','324','27.00'
'BindingDB','8281','1183','7.00'
'ToxCast','8026','25','321.04'
'Tox21','320','31','10.32'
'ClinTox','236','118','2.00'

2. Compound overlap analysis
- Most compounds appeared in only one or two datasets.
- No compound appeared in all six datasets.
- Only four compounds appeared in five datasets.

number_of_datasets, Compound_count
'5','4'
'4','24'
'3','190'
'2','916'
'1','1647'

3. Dataset combination analysis
- Bioassays was the most central dataset.
- The largest overlap was BindingDB + Bioassays.

Bioassays only: 1,368 compounds
BindingDB + Bioassays: 729 compounds
BindingDB + Bioassays + SIDER: 128 compounds

4. BindingDB + Bioassays overlap analysis
- The direct join created many more rows than distinct compounds because of a many-to-many relationship.
- The compound-level summary reduced this distortion.

Direct join: 49,410 records
Distinct shared compounds: 914
Distinct targets: 767
Distinct assays: 20

5. Binding value bucket analysis
- Averages were affected by outliers.
- Bucketed analysis showed a clearer distribution.
- Fully active compounds were more common in lower/mid binding-value buckets.
- Mixed-activity compounds had more compounds in the highest bucket.

Fully active: 518 compounds
Mixed activity: 396 compounds
Fully active >100,000 bucket: 20 compounds
Mixed activity >100,000 bucket: 52 compounds