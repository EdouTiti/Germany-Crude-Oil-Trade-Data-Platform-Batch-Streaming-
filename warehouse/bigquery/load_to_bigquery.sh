#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${GCP_PROJECT_ID:-zoomcampde2026}"
DATASET="${BQ_DATASET:-Germany_oil_data}"
LOCATION="${BQ_LOCATION:-US}"
bq --location="$LOCATION" mk --dataset --if_not_exists "$PROJECT_ID:$DATASET" >/dev/null 2>&1 || true

echo "Loading germany_crude_oil_imports_clean..."
bq --location="$LOCATION" load --replace --source_format=CSV --skip_leading_rows=1 "$PROJECT_ID:$DATASET.germany_crude_oil_imports_clean" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/data/processed/spark/germany_crude_oil_imports_clean/part-00000-0161234d-4426-4207-b00c-d86063aa6fa4-c000.csv" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/warehouse/bigquery/schemas/germany_crude_oil_imports_clean.json"

echo "Loading global_oil_trade_clean..."
bq --location="$LOCATION" load --replace --source_format=CSV --skip_leading_rows=1 "$PROJECT_ID:$DATASET.global_oil_trade_clean" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/data/processed/spark/global_oil_trade_clean/part-00000-872fcb2b-c6ba-4309-b0f2-3e74a5615686-c000.csv" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/warehouse/bigquery/schemas/global_oil_trade_clean.json"

echo "Loading country_name_mapping_clean..."
bq --location="$LOCATION" load --replace --source_format=CSV --skip_leading_rows=1 "$PROJECT_ID:$DATASET.country_name_mapping_clean" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/data/processed/spark/country_name_mapping_clean/part-00000-9bc1a25a-e1f8-4568-8852-cc20594db3dd-c000.csv" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/warehouse/bigquery/schemas/country_name_mapping_clean.json"

echo "Loading wdi_fuel_trade_long..."
bq --location="$LOCATION" load --replace --source_format=CSV --skip_leading_rows=1 "$PROJECT_ID:$DATASET.wdi_fuel_trade_long" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/data/processed/spark/wdi_fuel_trade_long/part-00000-222dc032-9274-4e9b-a050-45195169aee1-c000.csv" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/warehouse/bigquery/schemas/wdi_fuel_trade_long.json"

echo "Loading crude_oil_prices_clean..."
bq --location="$LOCATION" load --replace --source_format=CSV --skip_leading_rows=1 "$PROJECT_ID:$DATASET.crude_oil_prices_clean" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/data/processed/spark/crude_oil_prices_clean/part-00000-b1dce4b7-1305-404a-a819-46a42136b9b8-c000.csv" "/workspaces/Germany-Crude-Oil-Trade-Data-Platform-Batch-Streaming-/warehouse/bigquery/schemas/crude_oil_prices_clean.json"
