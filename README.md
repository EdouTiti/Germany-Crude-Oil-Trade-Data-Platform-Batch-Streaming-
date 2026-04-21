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

![alt text](image.png)

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

Status: next

After the local pandas prototype, the project will add a Spark batch-processing
layer that can rerun the pipeline from raw data to curated outputs.

Planned actions:

- Add a PySpark batch job for raw CSV ingestion
- Recreate the current cleaning logic in Spark DataFrames
- Validate required columns, row counts, ID fields, and numeric fields
- Write repeatable curated outputs
- Keep the existing processed schemas stable for downstream loading

Planned script:

```text
src/spark_batch_pipeline.py
```

Planned outputs:

```text
data/processed/germany_crude_oil_imports_clean.csv
data/processed/global_oil_trade_clean.csv
data/processed/country_name_mapping_clean.csv
data/processed/wdi_fuel_trade_long.csv
```

## Step 4: BigQuery Warehouse Layer

Status: planned

After the Spark batch layer is stable, the cleaned datasets will be prepared for
loading into Google BigQuery.

Planned actions:

- Define BigQuery dataset and table names
- Create table schemas for curated outputs
- Add a loading script or documented `bq` commands
- Validate loaded row counts against local processed outputs

Planned tables:

```text
germany_crude_oil_imports_clean
global_oil_trade_clean
country_name_mapping_clean
wdi_fuel_trade_long
```

## Step 5: dbt Analytics Modeling Layer

Status: planned

dbt will be used after the warehouse layer to build analytics-friendly models
on top of the curated BigQuery tables.

Planned actions:

- Add a dbt project structure
- Define source tables from BigQuery
- Build staging models
- Build marts for Germany imports, global trade records, and WDI fuel indicators
- Add dbt tests for unique IDs, not-null fields, and accepted values

## Step 6: Orchestration Layer

Status: planned

An orchestration tool such as Airflow or Prefect can run the pipeline
end-to-end.

Planned actions:

- Schedule Spark batch processing
- Load processed outputs into BigQuery
- Run dbt models and tests
- Produce run logs and failure notifications

## Step 7: Power BI Dashboard Layer

Status: planned

Power BI will connect to the curated BigQuery/dbt models for analytical
reporting.

Planned dashboard themes:

- Germany crude oil imports by partner country
- Trade value and quantity trends over time
- Global trade transaction summaries
- WDI fuel import/export percentage trends by country and region

# DTAMODEL IN pOWER bi
![alt text](image-1.png)

## Verification Commands

Check Python syntax:

```bash
python3 -m py_compile src/load_datasets.py
```

Run the current loader:

```bash
python3 src/load_datasets.py
```

Run the current cleaner:

```bash
python3 src/clean_datasets.py
```
