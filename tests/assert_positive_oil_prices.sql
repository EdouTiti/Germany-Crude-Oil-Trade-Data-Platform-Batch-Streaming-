select *
from {{ ref('stg_oil_prices') }}
where price_usd <= 0

