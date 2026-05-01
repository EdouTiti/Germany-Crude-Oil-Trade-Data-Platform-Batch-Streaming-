
  
    

    create or replace table `zoomcampde2026`.`Germany_oil_analytics`.`fct_wdi_fuel_trade_by_country_year`
      
    
    

    
    OPTIONS()
    as (
      with fuel_trade as (
    select *
    from `zoomcampde2026`.`Germany_oil_analytics`.`stg_wdi_fuel_trade`
)

select
    country_id,
    country_code,
    country_name,
    region,
    income_group,
    year,
    max(case when trade_direction = 'import' then fuel_trade_percent end) as fuel_import_percent,
    max(case when trade_direction = 'export' then fuel_trade_percent end) as fuel_export_percent,
    max(case when trade_direction = 'import' then indicator_name end) as import_indicator_name,
    max(case when trade_direction = 'export' then indicator_name end) as export_indicator_name
from fuel_trade
group by
    country_id,
    country_code,
    country_name,
    region,
    income_group,
    year
    );
  