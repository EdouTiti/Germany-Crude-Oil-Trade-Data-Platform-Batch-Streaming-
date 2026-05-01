with country_aliases as (
    select
        country_id,
        cast(null as string) as country_code,
        country_name,
        short_name,
        1 as source_priority
    from {{ ref('stg_country_name_mapping') }}
),

wdi_countries as (
    select distinct
        country_id,
        country_code,
        country_name,
        cast(null as string) as short_name,
        2 as source_priority
    from {{ ref('stg_wdi_fuel_trade') }}
),

trade_countries as (
    select distinct
        country_id,
        cast(null as string) as country_code,
        country as country_name,
        cast(null as string) as short_name,
        3 as source_priority
    from {{ ref('stg_germany_crude_oil_imports') }}
    where country_id is not null
      and country is not null

    union distinct

    select distinct
        partner_id as country_id,
        cast(null as string) as country_code,
        partner as country_name,
        cast(null as string) as short_name,
        3 as source_priority
    from {{ ref('stg_germany_crude_oil_imports') }}
    where partner_id is not null
      and partner is not null

    union distinct

    select distinct
        export_country_id as country_id,
        cast(null as string) as country_code,
        export_country as country_name,
        cast(null as string) as short_name,
        3 as source_priority
    from {{ ref('stg_global_oil_trade') }}
    where export_country_id is not null
      and export_country is not null

    union distinct

    select distinct
        origin_country_id as country_id,
        cast(null as string) as country_code,
        origin_country as country_name,
        cast(null as string) as short_name,
        3 as source_priority
    from {{ ref('stg_global_oil_trade') }}
    where origin_country_id is not null
      and origin_country is not null
),

country_sources as (
    select * from country_aliases
    union distinct
    select * from wdi_countries
    union distinct
    select * from trade_countries
),

country_enrichment as (
    select
        country_id,
        array_agg(country_code ignore nulls order by country_code limit 1)[safe_offset(0)] as iso_country_code,
        array_agg(region ignore nulls order by region limit 1)[safe_offset(0)] as region,
        array_agg(income_group ignore nulls order by income_group limit 1)[safe_offset(0)] as income_group
    from {{ ref('stg_wdi_fuel_trade') }}
    group by country_id
),

ranked_countries as (
    select
        country_id,
        country_code,
        country_name,
        short_name,
        row_number() over (
            partition by country_id
            order by
                source_priority,
                length(country_name),
                country_name,
                short_name
        ) as country_name_rank,
        count(*) over (partition by country_id) as alias_count
    from country_sources
)

select
    ranked_countries.country_id,
    ranked_countries.country_id as country_code,
    coalesce(ranked_countries.country_code, country_enrichment.iso_country_code) as iso_country_code,
    ranked_countries.country_name,
    ranked_countries.short_name as primary_short_name,
    country_enrichment.region,
    country_enrichment.income_group,
    ranked_countries.alias_count
from ranked_countries
left join country_enrichment
    on ranked_countries.country_id = country_enrichment.country_id
where country_name_rank = 1

