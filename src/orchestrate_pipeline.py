from __future__ import annotations

import argparse
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from pipeline_lib import PROCESSED_DIR, write_json

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def step(name: str, description: str, command: list[str]) -> dict[str, object]:
    return {"name": name, "description": description, "command": command}


def default_steps() -> list[dict[str, object]]:
    python = sys.executable
    return [
        step("spark_batch", "Run PySpark batch processing from raw CSVs to curated outputs.", [python, "src/spark_batch_pipeline.py"]),
        step("prepare_bigquery", "Regenerate BigQuery schemas, load script, and validation SQL.", [python, "src/prepare_bigquery.py"]),
        step("dbt_debug", "Validate the dbt BigQuery profile.", ["dbt", "debug", "--profiles-dir", "."]),
        step("dbt_build", "Build dbt staging views, marts, and tests.", ["dbt", "build", "--profiles-dir", "."]),
    ]


def run_step(defn: dict[str, object]) -> dict[str, object]:
    started_at = utc_now()
    proc = subprocess.run(
        defn["command"],
        cwd=PROJECT_ROOT,
        text=True,
        capture_output=True,
        env={**os.environ, "DBT_SEND_ANONYMOUS_USAGE_STATS": "false"},
    )
    finished_at = utc_now()
    output = (proc.stdout + "\n" + proc.stderr).strip()
    return {
        **defn,
        "status": "success" if proc.returncode == 0 else "failed",
        "started_at": started_at,
        "finished_at": finished_at,
        "returncode": proc.returncode,
        "output_tail": output[-4000:],
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--only", nargs="*", default=None)
    parser.add_argument("--skip-dbt", action="store_true")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    steps = default_steps()
    if args.skip_dbt:
        steps = [s for s in steps if not str(s["name"]).startswith("dbt_")]
    if args.only:
        selected = set(args.only)
        steps = [s for s in steps if s["name"] in selected]

    if args.dry_run:
        for item in steps:
            print(f"{item['name']}: {' '.join(item['command'])}")
        return

    results = []
    started_at = utc_now()
    overall_status = "success"
    for item in steps:
        result = run_step(item)
        results.append(result)
        if result["status"] != "success":
            overall_status = "failed"
            break
    finished_at = utc_now()

    report = {
        "status": overall_status,
        "started_at": started_at,
        "finished_at": finished_at,
        "project_root": str(PROJECT_ROOT),
        "dry_run": False,
        "environment": {
            "GCP_PROJECT_ID": os.getenv("GCP_PROJECT_ID", "zoomcampde2026"),
            "BQ_DATASET": os.getenv("BQ_DATASET", "Germany_oil_data"),
            "DBT_DATASET": os.getenv("DBT_DATASET", "Germany_oil_analytics"),
            "BQ_LOCATION": os.getenv("BQ_LOCATION", "US"),
            "GOOGLE_APPLICATION_CREDENTIALS": os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "warehouse/bigquery/key.json"),
        },
        "steps": results,
    }
    out_path = PROCESSED_DIR / "orchestration_report.json"
    write_json(out_path, report)
    print(f"Orchestration report written to {out_path}")
    if overall_status != "success":
        raise SystemExit(1)


if __name__ == "__main__":
    main()

