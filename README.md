# Germany Crude Oil Trade Data Platform

This repository is being built step by step as a data platform for Germany and
global crude oil and fuel trade data. Each step is documented here as a project
report, so the work stays clear and reproducible.

## Project Goal

Build a batch and streaming data platform that can load, validate, clean,
transform, and analyze oil trade datasets from multiple raw sources.

The current project starts with three source groups:

- Germany crude oil import records
- Global trade transaction records
- World Bank WDI fuel import/export indicators

## Architecture

This project follows a modern data engineering architecture:

- Data sources: CSV files for Germany trade data, global trade data, and World
  Bank WDI indicators
- Batch processing: Apache Spark with PySpark for ingestion, validation, and
  transformation
- Transformation layer: dbt, planned for data modeling and analytics tables
- Data warehouse: Google BigQuery for storing curated datasets
- Orchestration: planned with a tool such as Airflow or Prefect
- BI and visualization: Power BI for dashboards and analytical reporting

Target data flow:

```text
Raw data -> Spark processing -> Cleaned datasets -> BigQuery -> dbt -> Power BI dashboards
```
<img width="667" height="335" alt="image" src="https://github.com/user-attachments/assets/31597530-4a13-4aaf-8f63-1b85522ac3bf" />

Current implementation note:

The first completed steps use local Python and pandas to prototype the loading,
validation, and cleaning logic. The next engineering step is to move the batch
processing layer to PySpark while preserving the same output schemas.

## Current Raw Data Inventory

Raw files are stored in `data/raw/`.

| File | Source group | Current use |
| --- | --- | --- |
| `GCO_Imports.csv` | Germany crude oil | Germany crude oil import trade records |
| `global_oil_trade.csv` | Global trade records | Detailed transaction-style trade records |
| `Country_Name.csv` | Reference data | Country name and country code mapping |
| `import1.csv` | World Bank WDI | Fuel imports time-series data |
| `import2.csv` | World Bank WDI | Country metadata for the imports dataset |
| `import3.csv` | World Bank WDI | Indicator metadata for the imports dataset |
| `export1.csv` | World Bank WDI | Fuel exports time-series data |
| `export2.csv` | World Bank WDI | Country metadata for the exports dataset |
| `export3.csv` | World Bank WDI | Indicator metadata for the exports dataset |

There is also an `Untitled.ipynb` file in `data/raw/`. It is not used by the
pipeline.

## Step 1: Load And Validate Raw Datasets

Status: completed

Script:

```text
src/load_datasets.py
```

Command:

```bash
python3 src/load_datasets.py
```

Generated output:

```text
data/processed/dataset_load_report.json
```

What this step does:

- Loads all available starting CSV datasets from `data/raw/`
- Supports the Germany crude oil imports file
- Supports the global trade records file
- Supports the semicolon-separated country mapping file
- Supports the World Bank WDI split-file format
- Handles UTF-8 BOM characters in CSV headers
- Falls back to ISO-8859-1 when needed
- Skips the WDI metadata rows at the top of `import1.csv` and `export1.csv`
- Creates a JSON profile with row counts, column counts, column names, dtypes,
  and missing-value counts

Step 1 result:

| Dataset name in report | Source file | Source group | Rows | Columns |
| --- | --- | --- | ---: | ---: |
| `germany_crude_oil_imports` | `data/raw/GCO_Imports.csv` | Germany crude oil | 612 | 8 |
| `global_oil_trade` | `data/raw/global_oil_trade.csv` | Global trade records | 20 | 40 |
| `country_name_mapping` | `data/raw/Country_Name.csv` | Reference data | 138 | 3 |
| `fuel_imports_data` | `data/raw/import1.csv` | World Bank WDI | 266 | 70 |
| `fuel_imports_country_metadata` | `data/raw/import2.csv` | World Bank WDI | 265 | 5 |
| `fuel_imports_indicator_metadata` | `data/raw/import3.csv` | World Bank WDI | 1 | 4 |
| `fuel_exports_data` | `data/raw/export1.csv` | World Bank WDI | 266 | 70 |
| `fuel_exports_country_metadata` | `data/raw/export2.csv` | World Bank WDI | 265 | 5 |
| `fuel_exports_indicator_metadata` | `data/raw/export3.csv` | World Bank WDI | 1 | 4 |

Important columns by dataset:

| Dataset | Important columns |
| --- | --- |
| `germany_crude_oil_imports` | `Year`, `Country`, `Partner`, `Commodity Description`, `Quantity`, `Quantity Unit`, `Trade Value` |
| `global_oil_trade` | `DATE`, `IMPORTER NAME`, `EXPORT COUNTRY`, `ORIGIN COUNTRY`, `HS CODE`, `PRODUCT DESCRIPTION`, `QUANTITY`, `TOTAL VALUE USD`, `YEAR` |
| `country_name_mapping` | `ShortName`, `Name`, `NewName` |
| WDI import/export data | `Country Name`, `Country Code`, `Indicator Name`, `Indicator Code`, `1960` through `2025` |

## Step 2: Cleaning And Standardization

Status: completed

Script:

```text
src/clean_datasets.py
```

Command:

```bash
python3 src/clean_datasets.py
```

Generated report:

```text
data/processed/cleaning_report.json
```

This step creates cleaned, analysis-ready datasets in `data/processed/`.

What this step does:

- Standardize column names to snake case
- Parse dates and years into consistent types
- Standardize country names and country codes
- Use `Country_Name.csv` as a reference mapping where useful
- Clean Germany crude oil import records
- Clean global trade transaction records
- Convert WDI year columns from wide format to long format
- Add a `trade_direction` field for WDI import/export indicators
- Remove rows that do not contain useful analytical values

Step 2 outputs:

| Output file | Rows | Columns | Notes |
| --- | ---: | ---: | --- |
| `data/processed/germany_crude_oil_imports_clean.csv` | 612 | 11 | Germany crude oil import records with country and partner IDs |
| `data/processed/global_oil_trade_clean.csv` | 20 | 25 | Global trade transaction records with country IDs and preserved HS-code leading zeroes |
| `data/processed/country_name_mapping_clean.csv` | 137 | 3 | Country reference mapping after duplicate cleanup |
| `data/processed/wdi_fuel_trade_long.csv` | 19445 | 10 | WDI fuel import/export indicators converted from wide to long format |

Clean Germany crude oil import columns:

```text
year
country
country_id
partner
partner_id
partner2
commodity_description
quantity
quantity_unit
trade_value
trade_direction
```

Clean global trade columns:

```text
date
importer_name
supplier_name
export_country
export_country_id
origin_country
origin_country_id
hs_code
product_description
package_unit_name
unit
total_packages
quantity
gross_weight_kg
net_weight_kg
currency
total_value_usd
delivery_terms
mode_of_transport
port_of_unloading
chapter
heading
sub_heading
month
year
```

Clean WDI long-format columns:

```text
country_name
country_id
country_code
indicator_name
indicator_code
trade_direction
year
fuel_trade_percent
region
income_group
```

Data quality notes:

- Country IDs are derived from `Country_Name.csv` where possible.
- `World` and `Other Asia, nes` are aggregate partner values, so the cleaner
  assigns stable pseudo IDs: `WORLD` and `OTHER_ASIA_NES`.
- WDI rows use the mapped country ID when available and fall back to the WDI
  `country_code` when a country is not present in `Country_Name.csv`.
- `germany_crude_oil_imports_clean.csv` has 6 missing `quantity_unit` values.
- `wdi_fuel_trade_long.csv` has missing `region` and `income_group` values for
  some aggregate World Bank entries, such as regional groups.
- `global_oil_trade_clean.csv` has complete values for the selected key fields
  in the current 20-row sample.

## Step 3: PySpark Batch Processing Layer

Status: completed

Script:

```text
src/spark_batch_pipeline.py
```

Command:

```bash
python3 src/spark_batch_pipeline.py
```

Generated report:

```text
data/processed/spark_batch_report.json
```

This step adds the Spark batch-processing layer that reruns the pipeline from
raw data to curated outputs. The local environment uses PySpark `4.1.1`; the
script automatically prefers the installed Java 21 runtime because the default
Java 25 runtime is not compatible with local Spark/Hadoop file access.

What this step does:

- Reads the raw CSV files with PySpark
- Recreates the pandas cleaning logic with Spark DataFrames
- Standardizes columns, country IDs, partner IDs, dates, HS codes, and numeric
  fields
- Converts WDI fuel import/export year columns from wide format to long format
- Writes Spark-managed CSV output directories
- Compares Spark row counts against the pandas prototype outputs

Step 3 outputs:

| Spark output directory | Rows | Columns | Pandas row-count match |
| --- | ---: | ---: | --- |
| `data/processed/spark/germany_crude_oil_imports_clean` | 612 | 11 | yes |
| `data/processed/spark/global_oil_trade_clean` | 20 | 25 | yes |
| `data/processed/spark/country_name_mapping_clean` | 137 | 3 | yes |
| `data/processed/spark/wdi_fuel_trade_long` | 19445 | 10 | yes |

Data quality notes:

- Spark row counts match the pandas prototype for all four curated outputs.
- `germany_crude_oil_imports_clean` has 6 missing `quantity_unit` values.
- `wdi_fuel_trade_long` has 3977 missing `region` values and 4127 missing
  `income_group` values, matching the expected World Bank aggregate entries.
- Spark writes each output as a directory containing a `part-*.csv` file and a
  `_SUCCESS` marker.

## Step 4: BigQuery Warehouse Layer

Status: completed and loaded to BigQuery

Script:

```text
src/prepare_bigquery.py
```

Command:

```bash
python3 src/prepare_bigquery.py
```

Generated report:

```text
data/processed/bigquery_warehouse_report.json
```

This step prepares and loads the cleaned Spark outputs into Google BigQuery. It
creates table schemas, a reusable `bq` load script, and validation SQL.

Generated artifacts:

| Artifact | Purpose |
| --- | --- |
| `warehouse/bigquery/schemas/germany_crude_oil_imports_clean.json` | BigQuery schema for Germany crude oil imports |
| `warehouse/bigquery/schemas/global_oil_trade_clean.json` | BigQuery schema for global trade records |
| `warehouse/bigquery/schemas/country_name_mapping_clean.json` | BigQuery schema for country mapping |
| `warehouse/bigquery/schemas/wdi_fuel_trade_long.json` | BigQuery schema for WDI fuel trade indicators |
| `warehouse/bigquery/setup_iam.sh` | Shell script for service-account IAM setup |
| `warehouse/bigquery/load_to_bigquery.sh` | Shell script for creating the dataset and loading all tables |
| `warehouse/bigquery/validation_queries.sql` | SQL checks for row counts and key missing-value checks |

Default warehouse settings:

```text
BigQuery dataset: Germany_oil_data
GCP project ID: zoomcampde2026
BigQuery location: US
GCS staging bucket: oil-data-temp-bucket-123
GCS staging path: gs://oil-data-temp-bucket-123/bigquery_loads/Germany_oil_data/
Default load mode: direct local bq load from Spark CSV part files
Service account name: spark-bq
Service account ID: spark-bq
Service account email: spark-bq@zoomcampde2026.iam.gserviceaccount.com
Service account key path: warehouse/bigquery/key.json
```

Prepared tables:

| BigQuery table | Source | Rows | Schema fields |
| --- | --- | ---: | ---: |
| `Germany_oil_data.germany_crude_oil_imports_clean` | `data/processed/spark/germany_crude_oil_imports_clean/part-*.csv` | 612 | 11 |
| `Germany_oil_data.global_oil_trade_clean` | `data/processed/spark/global_oil_trade_clean/part-*.csv` | 20 | 25 |
| `Germany_oil_data.country_name_mapping_clean` | `data/processed/spark/country_name_mapping_clean/part-*.csv` | 137 | 3 |
| `Germany_oil_data.wdi_fuel_trade_long` | `data/processed/spark/wdi_fuel_trade_long/part-*.csv` | 19445 | 10 |

Load command:

```bash
export GCP_PROJECT_ID="zoomcampde2026"
export BQ_DATASET="Germany_oil_data"
export BQ_LOCATION="US"
export GCS_BUCKET="oil-data-temp-bucket-123"
export SERVICE_ACCOUNT_ID="spark-bq"
export SERVICE_ACCOUNT_NAME="spark-bq"
export GOOGLE_APPLICATION_CREDENTIALS="warehouse/bigquery/key.json"
warehouse/bigquery/load_to_bigquery.sh
```

Step 4 load result:

- Google Cloud CLI was installed in the working container.
- Service-account authentication succeeded with `warehouse/bigquery/key.json`.
- All four curated Spark outputs were loaded to BigQuery with direct local
  `bq load`.
- The load script defaults to `USE_GCS_STAGING=false`.
- Set `USE_GCS_STAGING=true` only after the service account has object access on
  `gs://oil-data-temp-bucket-123`.
- `warehouse/bigquery/setup_iam.sh` was not completed from the service account
  because Cloud Resource Manager and IAM APIs are disabled or inaccessible for
  that identity.
- `GOOGLE_APPLICATION_CREDENTIALS` should point to the real local JSON key file
  for the `spark-bq` service account. This project now uses
  `warehouse/bigquery/key.json` as the default local key path.
- Do not store or commit the service account JSON key in this repository.

BigQuery validation result:

| Table | Expected rows | BigQuery rows | Match |
| --- | ---: | ---: | --- |
| `Germany_oil_data.germany_crude_oil_imports_clean` | 612 | 612 | yes |
| `Germany_oil_data.global_oil_trade_clean` | 20 | 20 | yes |
| `Germany_oil_data.country_name_mapping_clean` | 137 | 137 | yes |
| `Germany_oil_data.wdi_fuel_trade_long` | 19445 | 19445 | yes |

Validation notes:

- Germany import records have 0 missing `country_id`, 0 missing `partner_id`,
  and 6 missing `quantity_unit` values.
- Global trade records have 0 missing `export_country_id`, 0 missing
  `origin_country_id`, and 0 missing `hs_code` values.
- WDI records have 0 missing `country_id`, 3977 missing `region` values, and
  4127 missing `income_group` values for World Bank aggregate entries.

## Step 5: dbt Analytics Modeling Layer
<img width="954" height="449" alt="4-dbt-Tables   views" src="https://github.com/user-attachments/assets/6c8ffb69-f1d2-4951-8965-c1160cde1ea1" />

<img width="931" height="427" alt="3- dbt_dat Lineage" src="https://github.com/user-attachments/assets/3bde763a-1289-4a9c-a45f-6c636aea28a8" />


dbt will be used after the warehouse layer to build analytics-friendly models
on top of the curated BigQuery tables.

Project files:

```text
dbt_project.yml
profiles.yml
models/sources.yml
models/staging/
models/marts/
models/facts/
tests/
```
Default dbt settings:

```text
dbt profile: germany_crude_oil_trade
BigQuery source dataset: Germany_oil_data
BigQuery analytics dataset: Germany_oil_analytics
GCP project ID: zoomcampde2026
BigQuery location: US
Service account key path: warehouse/bigquery/key.json
```

Environment variables can override the defaults:

```bash
export GCP_PROJECT_ID="zoomcampde2026"
export BQ_DATASET="Germany_oil_data"
export DBT_DATASET="Germany_oil_analytics"
export BQ_LOCATION="US"
export GOOGLE_APPLICATION_CREDENTIALS="warehouse/bigquery/key.json"
```

Commands:

```bash
dbt debug --profiles-dir .
dbt parse --profiles-dir .
dbt build --profiles-dir .
```

Current source definitions:

| Source table | dbt source |
| --- | --- |
| `Germany_oil_data.germany_crude_oil_imports_clean` | `source('oil_trade_warehouse', 'germany_crude_oil_imports_clean')` |
| `Germany_oil_data.global_oil_trade_clean` | `source('oil_trade_warehouse', 'global_oil_trade_clean')` |
| `Germany_oil_data.country_name_mapping_clean` | `source('oil_trade_warehouse', 'country_name_mapping_clean')` |
| `Germany_oil_data.wdi_fuel_trade_long` | `source('oil_trade_warehouse', 'wdi_fuel_trade_long')` |
| `Germany_oil_data.crude_oil_prices_clean` | `source('oil_trade_warehouse', 'crude_oil_prices_clean')` |

Current staging models:

| Model | Purpose |
| --- | --- |
| `stg_germany_crude_oil_imports` | Germany import records with stable dbt record IDs |
| `stg_global_oil_trade` | Global trade records with stable dbt record IDs |
| `stg_country_name_mapping` | Country reference data exposed through dbt |
| `stg_wdi_fuel_trade` | WDI fuel import/export indicators with stable dbt record IDs |
| `stg_oil_prices` | Annual crude oil price time series |

Current dimensions:

| Model | Purpose |
| --- | --- |
| `dim_country` | Deduplicated country dimension with one row per numeric country ID |
| `dim_commodity` | Commodity descriptions and HS codes |
| `dim_date` | Calendar attributes for trade, WDI, and prices |
| `dim_indicator` | WDI indicator metadata |

Current facts:

| Model | Grain |
| --- | --- |
| `fact_oil_trade_germany` | year, Germany, partner, commodity, quantity unit |
| `fact_oil_trade_global` | source transaction |
| `fact_wdi_energy` | country, year, indicator |
| `fact_oil_prices` | annual price date |

Data model design:

The datasets have different grains, so the analytics layer uses a dimensional
star schema instead of one wide table.

| Source dataset | Natural grain | dbt fact model |
| --- | --- | --- |
| `germany_crude_oil_imports_clean` | country, year, partner, commodity | `fact_oil_trade_germany` |
| `global_oil_trade_clean` | transaction record | `fact_oil_trade_global` |
| `wdi_fuel_trade_long` | country, year, WDI indicator | `fact_wdi_energy` |
| `crude_oil_prices_clean` | price date | `fact_oil_prices` |

Dimension tables:

| Dimension | Purpose |
| --- | --- |
| `dim_country` | Numeric country codes, names, WDI/ISO alpha codes, region, and income group |
| `dim_commodity` | Germany commodity descriptions and global HS-code products |
| `dim_date` | Shared date attributes for trade, WDI, and price facts |
| `dim_indicator` | WDI fuel import/export indicator metadata |

Relationship rules:

- `fact_oil_trade_germany.country_code` and `partner_code` relate to
  `dim_country.country_code`.
- `fact_oil_trade_global.export_country_code` and `origin_country_code` relate
  to `dim_country.country_code`.
- `fact_wdi_energy.country_code` relates to `dim_country.country_code`.
- All facts relate to `dim_date` through `date`; annual datasets use January 1
  of the reporting year.
- Commodity facts relate to `dim_commodity` through `commodity_id`.
- WDI facts relate to `dim_indicator` through `indicator_id`.

`fact_oil_trade_global.importer_name` and `supplier_name` are organization
names in the source data, not country IDs. They are retained as transaction
attributes and are not linked to `dim_country`.

Current tests:

- Source and model not-null checks for keys, years, and value fields
- Unique checks for generated staging record IDs and country IDs
- Accepted-value checks for `trade_direction`
- Singular data tests for positive trade values, positive oil prices, and WDI year ranges

Step 5 build result:

- dbt Core `1.11.8` and dbt BigQuery adapter `1.11.1` are installed.
- `dbt debug --profiles-dir .` passed with service-account authentication.
- `dbt build --profiles-dir .` completed successfully.
- Build summary: star-schema dbt graph with staging, dimension, and fact models.
- Current dbt result: PASS=120, WARN=0, ERROR=0, SKIP=0.
- Result summary: see the latest `data/processed/orchestration_report.json`.

Created BigQuery analytics objects in `Germany_oil_analytics`:

| Object | Type | Build result |
| --- | --- | --- |
| `stg_country_name_mapping` | view | created |
| `stg_germany_crude_oil_imports` | view | created |
| `stg_global_oil_trade` | view | created |
| `stg_wdi_fuel_trade` | view | created |
| `stg_oil_prices` | view | created |
| `dim_country` | table | one row per country ID |
| `dim_commodity` | table | one row per commodity ID |
| `dim_date` | table | one row per date |
| `dim_indicator` | table | one row per WDI indicator ID |
| `fact_oil_trade_germany` | table | Germany import fact |
| `fact_oil_trade_global` | table | global transaction fact |
| `fact_wdi_energy` | table | WDI country-year-indicator fact |
| `fact_oil_prices` | table | annual crude price fact |

Modeling notes:

- `country_id` is not unique in `country_name_mapping_clean` because some
  country IDs map to multiple names or aliases. Use `dim_country` for a unique
  country dimension.
- `dim_country` includes the country reference mapping, WDI country metadata,
  and observed trade countries from the Germany and global trade facts, so fact
  foreign keys have complete dimension coverage.
- For Power BI, use numeric `country_code` and `partner_code` fields for
  country relationships. Legacy `country_id` and `partner_id` fields remain in
  the dbt facts for compatibility, and WDI alpha codes are exposed as
  `iso_country_code` in `dim_country`.
- Germany crude oil import records can contain duplicate business-grain rows.
  The staging model creates a stable synthetic record ID using a row-grain key
  plus duplicate sequence.

## Step 6: Orchestration Layer


The project now includes a dependency-light local orchestration runner that can
run the pipeline end-to-end. It is designed so the same command can later be
called from cron, GitHub Actions, Airflow, or Prefect.

Script:

```text
src/orchestrate_pipeline.py
```

Command:

```bash
python3 src/orchestrate_pipeline.py
```

Generated report:

```text
data/processed/orchestration_report.json
```

What this step does:

- Run Spark batch processing from raw CSV files to curated outputs
- Regenerate BigQuery schemas, load script, and validation SQL
- Load Spark output files into BigQuery warehouse tables
- Run `dbt debug` to validate the BigQuery/dbt connection
- Run `dbt build` to create analytics views/tables and execute tests
- Write step-level status, timing, command metadata, and output tails to an
  orchestration report

Useful command variants:

```bash
python3 src/orchestrate_pipeline.py --dry-run
python3 src/orchestrate_pipeline.py --skip-bigquery-load
python3 src/orchestrate_pipeline.py --skip-dbt
python3 src/orchestrate_pipeline.py --only dbt_debug dbt_build
```

Default orchestration environment:

```text
GCP_PROJECT_ID=zoomcampde2026
BQ_DATASET=Germany_oil_data
DBT_DATASET=Germany_oil_analytics
BQ_LOCATION=US
GOOGLE_APPLICATION_CREDENTIALS=warehouse/bigquery/key.json
DBT_SEND_ANONYMOUS_USAGE_STATS=false
```

Scheduling example:

```cron
0 6 * * * cd /path/to/project && python3 src/orchestrate_pipeline.py
```

Step 6 run result:

- `python3 -m py_compile src/orchestrate_pipeline.py` passed.
- `python3 src/orchestrate_pipeline.py --dry-run` passed and listed the planned
  steps.
- `python3 src/orchestrate_pipeline.py` completed successfully.
- Spark batch output row counts matched the pandas prototype outputs.
- BigQuery direct local loads completed for all four warehouse tables.
- `dbt debug --profiles-dir .` passed.
- `dbt build --profiles-dir .` completed successfully.
- Final dbt summary: PASS=120, WARN=0, ERROR=0, SKIP=0.

Orchestrated run timings:

| Step | Result | Duration |
| --- | --- | ---: |
| `spark_batch` | success | 73.7 seconds |
| `prepare_bigquery` | success | 0.1 seconds |
| `load_bigquery` | success | 32.7 seconds |
| `dbt_debug` | success | 6.9 seconds |
| `dbt_build` | success | 30.9 seconds |

Run notes:

- Google Cloud authentication succeeded with
  `spark-bq@zoomcampde2026.iam.gserviceaccount.com`.
- The load step still reports that the Cloud Resource Manager API is disabled
  or inaccessible for the service account, but this warning does not block the
  direct local BigQuery loads.

Planned production hardening:

- Move local service-account credentials to a secret manager
- Add notification hooks for failed runs
- Run the orchestration command from a managed scheduler

## dbt structure
<img width="299" height="212" alt="image" src="https://github.com/user-attachments/assets/d2554eb4-d7c6-4348-b099-b30e5287d63b" />

## Step 7: Power BI Dashboard Layer

<img width="664" height="346" alt="6- Data Model in Power BI" src="https://github.com/user-attachments/assets/a72fd731-eaf5-4dcc-b3f4-5bfa0be3601e" />


Status: completed

Power BI will connect to the curated BigQuery/dbt models for analytical
reporting.

Power BI source dataset:

```text
GCP project: zoomcampde2026
BigQuery dataset: Germany_oil_analytics
```

Power BI tables:

| BigQuery table | Power BI table name | Grain |
| --- | --- | --- |
| `Germany_oil_analytics.fact_oil_trade_germany` | `Germany Imports` | year, partner, commodity, quantity unit |
| `Germany_oil_analytics.fact_oil_trade_global` | `Global Oil Trade` | source transaction |
| `Germany_oil_analytics.fact_wdi_energy` | `WDI Fuel Trade` | country, year, indicator |
| `Germany_oil_analytics.fact_oil_prices` | `Oil Prices` | annual price date |
| `Germany_oil_analytics.dim_country` | `Country Dimension` | one row per country ID |
| `Germany_oil_analytics.dim_commodity` | `Commodity Dimension` | one row per commodity ID |
| `Germany_oil_analytics.dim_date` | `Date Dimension` | one row per date |
| `Germany_oil_analytics.dim_indicator` | `Indicator Dimension` | one row per WDI indicator ID |

# Generated Dashboard
<img width="520" height="335" alt="image" src="https://github.com/user-attachments/assets/987cd338-83cf-40b2-a1e9-e2dae1d75acf" />


- Germany crude oil imports by partner country
- Trade value and quantity trends over time
- WDI fuel import/export percentage trends by country and region

Step 7 validation result:

- `powerbi/theme.json` passed JSON validation.
- BigQuery smoke query confirms the dbt fact and dimension tables are available.

| Reporting table | Grain |
| --- | ---: |
| `fact_oil_trade_germany` | Germany import fact |
| `fact_oil_trade_global` | global transaction fact |
| `fact_wdi_energy` | WDI country-year-indicator fact |
| `fact_oil_prices` | annual crude price fact |
