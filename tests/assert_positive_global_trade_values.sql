select *
from {{ ref('stg_global_oil_trade') }}
where total_value_usd < 0
   or quantity < 0

