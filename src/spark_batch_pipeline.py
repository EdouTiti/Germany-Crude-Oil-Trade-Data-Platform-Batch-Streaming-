from __future__ import annotations

import json
from pathlib import Path

import pandas as pd

from pipeline_lib import PROCESSED_DIR, clean_project_datasets, ensure_dir, load_raw_datasets, write_json

try:
    from pyspark.sql import SparkSession
except Exception:  # pragma: no cover - optional dependency
    SparkSession = None


def write_pandas_fallback(df: pd.DataFrame, output_dir: Path) -> None:
    ensure_dir(output_dir)
    df.to_csv(output_dir / "part-00000.csv", index=False)
    (output_dir / "_SUCCESS").write_text("")


def main() -> None:
    raw = load_raw_datasets()
    cleaned = clean_project_datasets(raw)
    spark_outputs = PROCESSED_DIR / "spark"
    ensure_dir(spark_outputs)

    spark_version = None
    spark = None
    if SparkSession is not None:
        try:
            spark = (
                SparkSession.builder.appName("germany-crude-oil-batch")
                .master("local[*]")
                .getOrCreate()
            )
            spark_version = spark.version
        except Exception:
            spark = None
            spark_version = "pandas-fallback"

    outputs: dict[str, dict[str, object]] = {}
    pandas_comparison: dict[str, dict[str, object]] = {}
    for name, df in cleaned.items():
        output_dir = spark_outputs / name
        if spark is not None:
            sdf = spark.createDataFrame(df.astype(object).where(pd.notna(df), None))
            sdf.coalesce(1).write.mode("overwrite").option("header", True).csv(str(output_dir))
            row_count = sdf.count()
        else:
            write_pandas_fallback(df, output_dir)
            row_count = len(df)
        outputs[name] = {
            "path": str(output_dir),
            "rows": int(row_count),
            "columns": int(len(df.columns)),
        }
        pandas_comparison[name] = {
            "pandas_rows": int(len(df)),
            "spark_rows": int(row_count),
            "match": int(len(df)) == int(row_count),
        }

    if spark is not None:
        spark.stop()

    report = {
        "spark_version": spark_version or "pandas-fallback",
        "outputs": outputs,
        "pandas_comparison": pandas_comparison,
    }
    out_path = PROCESSED_DIR / "spark_batch_report.json"
    write_json(out_path, report)
    print(json.dumps(report, indent=2))
    print(f"Spark batch report written to {out_path}")


if __name__ == "__main__":
    main()
