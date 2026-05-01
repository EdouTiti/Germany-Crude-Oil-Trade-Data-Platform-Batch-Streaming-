with source as (
    select *
    from {{ source('oil_trade_warehouse', 'crude_oil_prices_clean') }}
)

select
    date,
    cast(year as int64) as year,
    trim(entity) as entity,
    trim(entity_code) as entity_code,
    cast(price_usd as float64) as price_usd
from source

