with imports as (
    select *
    from {{ ref('stg_germany_crude_oil_imports') }}
)

select
    year,
    date(year, 1, 1) as date,
    country_id,
    country_id as country_code,
    partner_id,
    partner_id as partner_code,
    to_hex(md5(to_json_string(struct(
        '',
        coalesce(commodity_description, '')
    )))) as commodity_id,
    quantity_unit,
    trade_direction,
    count(*) as import_record_count,
    sum(quantity) as total_quantity,
    sum(trade_value) as total_trade_value,
    safe_divide(sum(trade_value), nullif(sum(quantity), 0)) as trade_value_per_unit
from imports
group by
    year,
    date,
    country_id,
    country_code,
    partner_id,
    partner_code,
    commodity_id,
    quantity_unit,
    trade_direction

