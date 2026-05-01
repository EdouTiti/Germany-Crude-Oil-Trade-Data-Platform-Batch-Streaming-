with source as (
    select *
    from `zoomcampde2026`.`Germany_oil_data`.`crude_oil_prices_clean`
)

select
    date,
    cast(year as int64) as year,
    trim(entity) as entity,
    trim(entity_code) as entity_code,
    cast(price_usd as float64) as price_usd
from source