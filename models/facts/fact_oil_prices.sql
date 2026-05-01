with prices as (
    select *
    from {{ ref('stg_oil_prices') }}
)

select
    date,
    year,
    entity,
    entity_code,
    price_usd
from prices

