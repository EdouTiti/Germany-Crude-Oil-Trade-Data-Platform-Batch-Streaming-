with source as (
    select *
    from {{ source('oil_trade_warehouse', 'country_name_mapping_clean') }}
)

select
    cast(country_id as int64) as country_id,
    trim(country_name) as country_name,
    trim(short_name) as short_name
from source

