with imports as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_germany_crude_oil_imports`
)

select
    year,
    country_id,
    country,
    partner_id,
    partner,
    commodity_description,
    quantity_unit,
    count(*) as import_record_count,
    sum(quantity) as total_quantity,
    sum(trade_value) as total_trade_value,
    safe_divide(sum(trade_value), nullif(sum(quantity), 0)) as trade_value_per_unit
from imports
group by
    year,
    country_id,
    country,
    partner_id,
    partner,
    commodity_description,
    quantity_unit