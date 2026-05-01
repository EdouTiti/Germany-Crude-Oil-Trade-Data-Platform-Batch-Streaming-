

  create or replace view `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
  OPTIONS()
  as with source as (
    select *
    from `zoomcampde2026`.`Germany_oil_data`.`wdi_fuel_trade_long`
)

select
    to_hex(md5(to_json_string(struct(
        country_id,
        indicator_code,
        trade_direction,
        year
    )))) as wdi_fuel_trade_record_id,
    country_name,
    cast(country_id as int64) as country_id,
    upper(country_code) as country_code,
    indicator_name,
    indicator_code,
    trade_direction,
    year,
    fuel_trade_percent,
    region,
    income_group
from source;

