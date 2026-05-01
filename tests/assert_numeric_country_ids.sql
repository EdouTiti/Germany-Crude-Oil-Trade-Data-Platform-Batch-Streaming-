select *
from {{ ref('dim_country') }}
where safe_cast(country_id as int64) is null

