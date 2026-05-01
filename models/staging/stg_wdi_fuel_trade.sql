with source as (
    select *
    from {{ source('oil_trade_warehouse', 'wdi_fuel_trade_long') }}
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
from source

