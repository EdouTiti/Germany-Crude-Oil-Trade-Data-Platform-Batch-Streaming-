from __future__ import annotations

from pipeline_lib import PROCESSED_DIR, clean_project_datasets, load_raw_datasets, write_csv_outputs, write_json


def main() -> None:
    raw = load_raw_datasets()
    outputs = clean_project_datasets(raw)
    report = {"outputs": write_csv_outputs(outputs, PROCESSED_DIR)}
    out_path = PROCESSED_DIR / "cleaning_report.json"
    write_json(out_path, report)
    print(f"Cleaning report written to {out_path}")


if __name__ == "__main__":
    main()

