with prices as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_oil_prices`
)

select
    date,
    year,
    entity,
    entity_code,
    price_usd
from prices