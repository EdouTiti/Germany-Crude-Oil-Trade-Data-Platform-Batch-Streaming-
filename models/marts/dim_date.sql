with dates as (
    select date
    from {{ ref('stg_global_oil_trade') }}

    union distinct

    select date
    from {{ ref('stg_oil_prices') }}

    union distinct

    select date(year, 1, 1) as date
    from {{ ref('stg_germany_crude_oil_imports') }}

    union distinct

    select date(year, 1, 1) as date
    from {{ ref('stg_wdi_fuel_trade') }}
)

select
    date,
    extract(year from date) as year,
    extract(month from date) as month,
    extract(quarter from date) as quarter,
    format_date('%B', date) as month_name
from dates
where date is not null

