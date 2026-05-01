select *
from {{ ref('stg_germany_crude_oil_imports') }}
where trade_value < 0
   or quantity < 0

