#!/usr/bin/env bash
set -euo pipefail
PROJECT_ID="${GCP_PROJECT_ID:-zoomcampde2026}"
SERVICE_ACCOUNT_ID="${SERVICE_ACCOUNT_ID:-spark-bq}"
echo "Grant the BigQuery roles your service account needs before running the load script."
echo "Example account: ${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"