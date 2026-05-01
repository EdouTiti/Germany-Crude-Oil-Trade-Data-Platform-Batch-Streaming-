with germany_commodities as (
    select distinct
        cast(null as string) as hs_code,
        commodity_description,
        'germany_imports' as commodity_source
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_germany_crude_oil_imports`
    where commodity_description is not null
),

global_commodities as (
    select distinct
        hs_code,
        product_description as commodity_description,
        'global_trade' as commodity_source
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`
    where hs_code is not null
       or product_description is not null
),

unioned as (
    select * from germany_commodities
    union distinct
    select * from global_commodities
)

select
    to_hex(md5(to_json_string(struct(
        coalesce(hs_code, ''),
        coalesce(commodity_description, '')
    )))) as commodity_id,
    commodity_description,
    hs_code,
    string_agg(distinct commodity_source, ', ' order by commodity_source) as commodity_sources
from unioned
group by
    commodity_id,
    commodity_description,
    hs_code