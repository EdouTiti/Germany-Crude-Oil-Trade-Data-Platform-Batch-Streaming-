select *
from {{ ref('stg_wdi_fuel_trade') }}
where year < 1960
   or year > 2025

