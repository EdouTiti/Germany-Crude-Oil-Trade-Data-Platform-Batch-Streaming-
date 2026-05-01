from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def read_csv_with_fallback(path: Path, **kwargs: Any) -> pd.DataFrame:
    errors: list[str] = []
    for encoding in ("utf-8-sig", "utf-8", "latin1", "iso-8859-1"):
        try:
            return pd.read_csv(path, encoding=encoding, **kwargs)
        except Exception as exc:  # pragma: no cover - diagnostic path
            errors.append(f"{encoding}: {exc}")
    raise RuntimeError(f"Unable to read {path}: {' | '.join(errors)}")


def snake_case(name: str) -> str:
    value = re.sub(r"[^0-9A-Za-z]+", "_", str(name).strip())
    value = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", value)
    return value.strip("_").lower()


def clean_columns(df: pd.DataFrame) -> pd.DataFrame:
    result = df.copy()
    result.columns = [snake_case(col) for col in result.columns]
    unnamed = [col for col in result.columns if col.startswith("unnamed")]
    if unnamed:
        result = result.drop(columns=unnamed)
    return result


def find_year_columns(df: pd.DataFrame) -> list[str]:
    return [col for col in df.columns if re.fullmatch(r"\d{4}", str(col))]


def profile_dataframe(df: pd.DataFrame) -> dict[str, Any]:
    return {
        "rows": int(len(df)),
        "columns": int(len(df.columns)),
        "column_names": list(df.columns),
        "dtypes": {col: str(dtype) for col, dtype in df.dtypes.items()},
        "missing_values": {col: int(df[col].isna().sum()) for col in df.columns},
    }


def load_raw_datasets(raw_dir: Path = RAW_DIR) -> dict[str, pd.DataFrame]:
    datasets: dict[str, pd.DataFrame] = {}
    datasets["germany_crude_oil_imports"] = read_csv_with_fallback(raw_dir / "GCO_Imports.csv")
    datasets["global_oil_trade"] = read_csv_with_fallback(raw_dir / "global_oil_trade.csv")
    datasets["country_name_mapping"] = read_csv_with_fallback(raw_dir / "Country_Name.csv", sep=";")
    datasets["fuel_imports_data"] = read_csv_with_fallback(raw_dir / "import1.csv", skiprows=4)
    datasets["fuel_imports_country_metadata"] = read_csv_with_fallback(raw_dir / "import2.csv")
    datasets["fuel_imports_indicator_metadata"] = read_csv_with_fallback(raw_dir / "import3.csv")
    datasets["fuel_exports_data"] = read_csv_with_fallback(raw_dir / "export1.csv", skiprows=4)
    datasets["fuel_exports_country_metadata"] = read_csv_with_fallback(raw_dir / "export2.csv")
    datasets["fuel_exports_indicator_metadata"] = read_csv_with_fallback(raw_dir / "export3.csv")
    prices_path = raw_dir / "crude-oil-prices.csv"
    if prices_path.exists():
        datasets["crude_oil_prices"] = read_csv_with_fallback(prices_path)
    return datasets


def load_known_country_ids() -> dict[str, Any]:
    mapping: dict[str, Any] = {}
    for file_name, name_col, id_col in [
        ("country_name_mapping_clean.csv", "country_name", "country_id"),
        ("germany_crude_oil_imports_clean.csv", "country", "country_id"),
        ("germany_crude_oil_imports_clean.csv", "partner", "partner_id"),
        ("global_oil_trade_clean.csv", "export_country", "export_country_id"),
        ("global_oil_trade_clean.csv", "origin_country", "origin_country_id"),
        ("wdi_fuel_trade_long.csv", "country_name", "country_id"),
    ]:
        path = PROCESSED_DIR / file_name
        if not path.exists():
            continue
        df = pd.read_csv(path)
        if name_col not in df.columns or id_col not in df.columns:
            continue
        for name, value in df[[name_col, id_col]].dropna().drop_duplicates().itertuples(index=False):
            mapping[str(name).strip().upper()] = value
    return mapping


def build_country_reference(raw_mapping: pd.DataFrame) -> pd.DataFrame:
    known_ids = load_known_country_ids()
    base = clean_columns(raw_mapping).rename(columns={"name": "country_name", "newname": "short_name"})
    base["country_name"] = base["country_name"].astype(str).str.strip()
    base["short_name"] = base["short_name"].astype(str).str.strip().str.upper()
    ids = []
    next_id = 1
    for country_name in base["country_name"]:
        key = country_name.strip().upper()
        existing = known_ids.get(key)
        if pd.notna(existing):
            ids.append(existing)
            if isinstance(existing, (int, float)) and int(existing) >= next_id:
                next_id = int(existing) + 1
        else:
            ids.append(None)
    base["country_id"] = ids
    for idx, value in base["country_id"].items():
        if pd.isna(value):
            while next_id in set(int(v) for v in base["country_id"].dropna() if float(v).is_integer()):
                next_id += 1
            base.at[idx, "country_id"] = next_id
            next_id += 1
    base["country_id"] = pd.to_numeric(base["country_id"], errors="coerce").astype(int)
    return base[["short_name", "country_name", "country_id"]].drop_duplicates().sort_values(["country_name", "short_name"]).reset_index(drop=True)


def build_name_to_id(country_mapping: pd.DataFrame) -> dict[str, Any]:
    mapping = load_known_country_ids()
    for row in country_mapping.itertuples(index=False):
        mapping[str(row.country_name).strip().upper()] = row.country_id
        mapping[str(row.short_name).strip().upper()] = row.country_id
    return mapping


def clean_germany_imports(df: pd.DataFrame, name_to_id: dict[str, Any]) -> pd.DataFrame:
    result = clean_columns(df)
    result["country"] = result["country"].astype(str).str.strip()
    result["partner"] = result["partner"].astype(str).str.strip()
    result["partner2"] = result["partner2"].astype(str).str.strip()
    result["country_id"] = result["country"].str.upper().map(name_to_id)
    result["partner_id"] = result["partner"].str.upper().map(name_to_id)
    result["quantity"] = pd.to_numeric(result["quantity"], errors="coerce")
    result["trade_value"] = pd.to_numeric(result["trade_value"], errors="coerce")
    result["year"] = pd.to_numeric(result["year"], errors="coerce").astype("Int64")
    result["quantity_unit"] = result["quantity_unit"].astype("string").str.strip()
    result["trade_direction"] = "import"
    return result[
        [
            "year",
            "country",
            "country_id",
            "partner",
            "partner_id",
            "partner2",
            "commodity_description",
            "quantity",
            "quantity_unit",
            "trade_value",
            "trade_direction",
        ]
    ]


def clean_global_trade(df: pd.DataFrame, name_to_id: dict[str, Any]) -> pd.DataFrame:
    result = clean_columns(df)
    result["date"] = pd.to_datetime(result["date"], errors="coerce", dayfirst=True).dt.strftime("%Y-%m-%d")
    for col in ("importer_name", "supplier_name", "export_country", "origin_country", "package_unit_name", "unit", "currency", "delivery_terms", "mode_of_transport", "port_of_unloading", "product_description", "month"):
        result[col] = result[col].astype("string").str.strip()
    result["unit"] = result["unit"].str.replace(r"\s+", " ", regex=True)
    result["export_country_id"] = result["export_country"].str.upper().map(name_to_id)
    result["origin_country_id"] = result["origin_country"].str.upper().map(name_to_id)
    for col in ("hs_code", "total_packages", "quantity", "gross_weight_kg", "net_weight_kg", "total_value_usd", "chapter", "heading", "sub_heading", "year"):
        result[col] = pd.to_numeric(result[col], errors="coerce")
    result["hs_code"] = result["hs_code"].astype("Int64")
    result["year"] = result["year"].astype("Int64")
    result["chapter"] = result["chapter"].astype("Int64")
    result["heading"] = result["heading"].astype("Int64")
    result["sub_heading"] = result["sub_heading"].astype("Int64")
    return result[
        [
            "date",
            "importer_name",
            "supplier_name",
            "export_country",
            "export_country_id",
            "origin_country",
            "origin_country_id",
            "hs_code",
            "product_description",
            "package_unit_name",
            "unit",
            "total_packages",
            "quantity",
            "gross_weight_kg",
            "net_weight_kg",
            "currency",
            "total_value_usd",
            "delivery_terms",
            "mode_of_transport",
            "port_of_unloading",
            "chapter",
            "heading",
            "sub_heading",
            "month",
            "year",
        ]
    ]


def melt_wdi(data_df: pd.DataFrame, metadata_df: pd.DataFrame, trade_direction: str, name_to_id: dict[str, Any]) -> pd.DataFrame:
    data = clean_columns(data_df)
    meta = clean_columns(metadata_df).rename(columns={"table_name": "country_name"})
    year_columns = find_year_columns(data)
    melted = data.melt(
        id_vars=["country_name", "country_code", "indicator_name", "indicator_code"],
        value_vars=year_columns,
        var_name="year",
        value_name="fuel_trade_percent",
    )
    melted["fuel_trade_percent"] = pd.to_numeric(melted["fuel_trade_percent"], errors="coerce")
    melted = melted.dropna(subset=["fuel_trade_percent"]).copy()
    melted["year"] = melted["year"].astype(int)
    meta = meta[["country_code", "region", "income_group", "country_name"]]
    merged = melted.merge(meta, on="country_code", how="left", suffixes=("", "_meta"))
    merged["country_name"] = merged["country_name_meta"].fillna(merged["country_name"])
    merged = merged.drop(columns=["country_name_meta"])
    merged["country_id"] = merged["country_name"].astype(str).str.upper().map(name_to_id)
    merged["country_id"] = merged["country_id"].fillna(merged["country_code"])
    merged["trade_direction"] = trade_direction
    return merged[
        [
            "country_name",
            "country_id",
            "country_code",
            "indicator_name",
            "indicator_code",
            "trade_direction",
            "year",
            "fuel_trade_percent",
            "region",
            "income_group",
        ]
    ]


def clean_crude_oil_prices(df: pd.DataFrame) -> pd.DataFrame:
    result = clean_columns(df).rename(columns={"code": "entity_code", "oil_price_crude_prices_since_1861": "price_usd", "entity": "entity"})
    result["year"] = pd.to_numeric(result["year"], errors="coerce").astype("Int64")
    result["price_usd"] = pd.to_numeric(result["price_usd"], errors="coerce")
    result["date"] = result["year"].astype(str) + "-01-01"
    return result[["date", "year", "entity", "entity_code", "price_usd"]]


def clean_project_datasets(raw_datasets: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    country_mapping = build_country_reference(raw_datasets["country_name_mapping"])
    name_to_id = build_name_to_id(country_mapping)
    cleaned = {
        "country_name_mapping_clean": country_mapping,
        "germany_crude_oil_imports_clean": clean_germany_imports(raw_datasets["germany_crude_oil_imports"], name_to_id),
        "global_oil_trade_clean": clean_global_trade(raw_datasets["global_oil_trade"], name_to_id),
    }
    wdi_imports = melt_wdi(
        raw_datasets["fuel_imports_data"],
        raw_datasets["fuel_imports_country_metadata"],
        "import",
        name_to_id,
    )
    wdi_exports = melt_wdi(
        raw_datasets["fuel_exports_data"],
        raw_datasets["fuel_exports_country_metadata"],
        "export",
        name_to_id,
    )
    cleaned["wdi_fuel_trade_long"] = pd.concat([wdi_imports, wdi_exports], ignore_index=True)
    if "crude_oil_prices" in raw_datasets:
        cleaned["crude_oil_prices_clean"] = clean_crude_oil_prices(raw_datasets["crude_oil_prices"])
    return cleaned


def write_csv_outputs(outputs: dict[str, pd.DataFrame], base_dir: Path = PROCESSED_DIR) -> dict[str, dict[str, Any]]:
    ensure_dir(base_dir)
    report: dict[str, dict[str, Any]] = {}
    for name, df in outputs.items():
        path = base_dir / f"{name}.csv"
        df.to_csv(path, index=False)
        report[name] = {
            "path": str(path),
            "rows": int(len(df)),
            "columns": int(len(df.columns)),
        }
    return report


def write_json(path: Path, payload: dict[str, Any]) -> None:
    ensure_dir(path.parent)
    path.write_text(json.dumps(payload, indent=2, default=str))
