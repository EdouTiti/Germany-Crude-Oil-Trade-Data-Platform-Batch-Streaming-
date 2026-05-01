from __future__ import annotations

from pipeline_lib import PROCESSED_DIR, load_raw_datasets, profile_dataframe, write_json


def main() -> None:
    datasets = load_raw_datasets()
    report = {
        "source_format": "mixed_project_sources",
        "raw_dir": str((PROCESSED_DIR.parent / "raw").resolve()),
        "datasets": {name: profile_dataframe(df) for name, df in datasets.items()},
    }
    out_path = PROCESSED_DIR / "dataset_load_report.json"
    write_json(out_path, report)
    print(f"Dataset load report written to {out_path}")


if __name__ == "__main__":
    main()

