# Germany Crude Oil Trade Data Platform (Batch)

## Project Overview
This project implements a batch data platform designed to ingest, process, and analyze Germany’s crude oil trade data (imports/exports) using a modern data stack.
The objective is to transform raw CSV datasets into structured, analytics-ready data models and deliver business intelligence dashboards for decision-making.

## Problem Statement
Crude oil trade data is often available as raw files but not structured for analytics or real-time monitoring.  
This project transforms historical data into a structured format to support:  
- Trend analysis
- Country-level insights
- Real-time monitoring

## Solution
This project builds a scalable batch pipeline that:
1. Ingests raw CSV trade data
2. Automates workflows using orchestration
3. Processes and cleans data using distributed computing
4. Stores structured data in a warehouse
5. Applies transformation logic for analytics
6. Visualizes insights via dashboards

## Architecture
Batch Pipeline:

CSV Data
→ Python (Ingestion)
→ Bruin (Orchestration)
→ Spark (Processing)
→ PostgreSQL (Data Warehouse)
→ dbt (Transformations)
→ Power BI (Visualization)

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/5ef4d244-0121-45f8-981d-e0fe7ea6b10a" />



## Technology Stack

| Layer          | Tool         | Role                            |
| -------------- | ------------ | ------------------------------- |
| Ingestion      | Python       | Load CSV data into warehouse    |
| Orchestration  | Bruin        | Pipeline scheduling & execution |
| Processing     | Apache Spark | Data cleaning & transformation  |
| Storage        | PostgreSQL   | Central data warehouse          |
| Transformation | dbt          | Analytics modeling              |
| Visualization  | Power BI     | Dashboards & reporting          |

## Data Flow
### 1. CSV Data
- Source: Trade datasets (e.g. Destatis / Eurostat)
- Format: Raw structured files (CSV)
- Link: https://www.kaggle.com/datasets/bhushandivekar/germany-crude-oil-trade
### 2. Python Ingestion
- Loads data into PostgreSQL (raw schema)
### 3. Bruin
- Orchestrates full pipeline execution
### 4. Spark**
- Cleans and enriches datasets
- Handles larger-scale transformations
### 5. PostgreSQL**
- Stores:
    --> Raw data (raw)
    --> Processed data (analytics)
### 6. dbt**
- Builds:
    --> Fact tables (trade volumes, values)
    --> Dimension tables (country, product, time)
### 7. Power BI**
- Dashboards:
    --> Import/export trends
    --> Country-level analysis
    --> Price evolution


## Dashboard
## Dataset
## Project Structure
## Reproducing This Project
# Prerequisites
# Step 1 - clone the repo
#  step 2 - Set up GCP credentials
# Step 3 - Provision infrastructure with Terraform
# step 4 - Configure Bruin
# step 5 - Run the pipeline
# step 6 - View the dashboard

## Data Pipeline Details
# Layer 1 — Ingestion (raw.cms_telehealth_trends)
# Layer 2 — Staging (staging.stg_telehealth_trends)
# Layer 3 — Analytics (analytics.telehealth_by_state)

## Data Quality Checks

