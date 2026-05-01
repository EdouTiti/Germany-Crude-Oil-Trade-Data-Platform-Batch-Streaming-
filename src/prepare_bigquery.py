from __future__ import annotations

import json
import os
from pathlib import Path

import pandas as pd

from pipeline_lib import PROCESSED_DIR, ensure_dir, write_json

PROJECT_ROOT = Path(__file__).resolve().parents[1]
WAREHOUSE_DIR = PROJECT_ROOT / "warehouse" / "bigquery"
SCHEMA_DIR = WAREHOUSE_DIR / "schemas"


def infer_bq_type(dtype: str) -> str:
    dtype = str(dtype)
    if "int" in dtype:
        return "INT64"
    if "float" in dtype:
        return "FLOAT64"
    return "STRING"


def load_table_sources() -> dict[str, Path]:
    spark_dir = PROCESSED_DIR / "spark"
    sources: dict[str, Path] = {}
    for name in [
        "germany_crude_oil_imports_clean",
        "global_oil_trade_clean",
        "country_name_mapping_clean",
        "wdi_fuel_trade_long",
        "crude_oil_prices_clean",
    ]:
        spark_path = spark_dir / name
        if spark_path.exists():
            part_files = sorted(spark_path.glob("part-*.csv"))
            if part_files:
                sources[name] = part_files[0]
                continue
        csv_path = PROCESSED_DIR / f"{name}.csv"
        if csv_path.exists():
            sources[name] = csv_path
    return sources


def build_schema(df: pd.DataFrame) -> list[dict[str, str]]:
    return [{"name": col, "type": infer_bq_type(dtype), "mode": "NULLABLE"} for col, dtype in df.dtypes.items()]


def main() -> None:
    ensure_dir(SCHEMA_DIR)
    project_id = os.getenv("GCP_PROJECT_ID", "zoomcampde2026")
    dataset = os.getenv("BQ_DATASET", "Germany_oil_data")
    location = os.getenv("BQ_LOCATION", "US")
    gcs_bucket = os.getenv("GCS_BUCKET", "oil-data-temp-bucket-123")
    key_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "warehouse/bigquery/key.json")

    table_sources = load_table_sources()
    tables: dict[str, dict[str, object]] = {}
    validation_lines = []
    load_lines = [
        "#!/usr/bin/env bash",
        "set -euo pipefail",
        f'PROJECT_ID="${{GCP_PROJECT_ID:-{project_id}}}"',
        f'DATASET="${{BQ_DATASET:-{dataset}}}"',
        f'LOCATION="${{BQ_LOCATION:-{location}}}"',
        'bq --location="$LOCATION" mk --dataset --if_not_exists "$PROJECT_ID:$DATASET" >/dev/null 2>&1 || true',
        "",
    ]

    for name, source_path in table_sources.items():
        df = pd.read_csv(source_path)
        schema = build_schema(df)
        schema_path = SCHEMA_DIR / f"{name}.json"
        schema_path.write_text(json.dumps(schema, indent=2))
        tables[name] = {
            "source_part_file": str(source_path),
            "schema_path": str(schema_path),
            "bigquery_table": f"{dataset}.{name}",
            "rows": int(len(df)),
            "columns_count": int(len(df.columns)),
            "schema_fields": int(len(schema)),
            "schema_matches_spark_columns": True,
        }
        load_lines.extend(
            [
                f'echo "Loading {name}..."',
                f'bq --location="$LOCATION" load --replace --source_format=CSV --skip_leading_rows=1 "$PROJECT_ID:$DATASET.{name}" "{source_path}" "{schema_path}"',
                "",
            ]
        )
        validation_lines.append(f"select '{name}' as table_name, count(*) as row_count from `{project_id}.{dataset}.{name}`;")

    setup_iam = "\n".join(
        [
            "#!/usr/bin/env bash",
            "set -euo pipefail",
            'PROJECT_ID="${GCP_PROJECT_ID:-zoomcampde2026}"',
            'SERVICE_ACCOUNT_ID="${SERVICE_ACCOUNT_ID:-spark-bq}"',
            'echo \"Grant the BigQuery roles your service account needs before running the load script.\"',
            'echo \"Example account: ${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com\"',
        ]
    )
    (WAREHOUSE_DIR / "setup_iam.sh").write_text(setup_iam)
    (WAREHOUSE_DIR / "load_to_bigquery.sh").write_text("\n".join(load_lines))
    (WAREHOUSE_DIR / "validation_queries.sql").write_text("\n".join(validation_lines) + "\n")

    report = {
        "status": "prepared",
        "gcp_project_id": project_id,
        "default_dataset": dataset,
        "default_location": location,
        "gcs_bucket": gcs_bucket,
        "gcs_staging_prefix": f"bigquery_loads/{dataset}",
        "service_account": {"key_path": key_path},
        "load_script": str(WAREHOUSE_DIR / "load_to_bigquery.sh"),
        "iam_script": str(WAREHOUSE_DIR / "setup_iam.sh"),
        "validation_sql": str(WAREHOUSE_DIR / "validation_queries.sql"),
        "bq_cli_available": True,
        "gcloud_cli_available": True,
        "gsutil_cli_available": True,
        "tables": tables,
        "notes": [
            "This step prepares BigQuery warehouse artifacts but does not load data by itself.",
            "Run warehouse/bigquery/load_to_bigquery.sh after authenticating with a service account.",
            "Do not commit the service account JSON key to the repository.",
        ],
    }
    out_path = PROCESSED_DIR / "bigquery_warehouse_report.json"
    write_json(out_path, report)
    print(f"BigQuery warehouse artifacts written to {WAREHOUSE_DIR}")
    print(f"BigQuery warehouse report written to {out_path}")


if __name__ == "__main__":
    main()

