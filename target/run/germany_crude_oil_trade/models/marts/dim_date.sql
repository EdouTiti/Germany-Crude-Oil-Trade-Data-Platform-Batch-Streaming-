
  
    

    create or replace table `zoomcampde2026`.`Germany_oil_analytics`.`dim_date`
      
    
    

    
    OPTIONS()
    as (
      with dates as (
    select date
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_global_oil_trade`

    union distinct

    select date
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_oil_prices`

    union distinct

    select date(year, 1, 1) as date
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_germany_crude_oil_imports`

    union distinct

    select date(year, 1, 1) as date
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
)

select
    date,
    extract(year from date) as year,
    extract(month from date) as month,
    extract(quarter from date) as quarter,
    format_date('%B', date) as month_name
from dates
where date is not null
    );
  