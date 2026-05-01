with indicators as (
    select distinct
        indicator_code,
        indicator_name,
        trade_direction
    from {{ ref('stg_wdi_fuel_trade') }}
)

select
    to_hex(md5(indicator_code)) as indicator_id,
    indicator_code,
    indicator_name,
    trade_direction
from indicators

